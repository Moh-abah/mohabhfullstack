// Fixed MessageProvider.dart with permission error handling
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../utils/internet_checker.dart';
import '../utils/SecureStorageHelper.dart';

enum MessageStatus { sending, sent, delivered, read }

class MessageProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger _logger = Logger();
  final InternetChecker _internetChecker = InternetChecker();
  int? ownerId;
  int? storeId;

  int? _currentUserId;
  String _currentUserName = 'مستخدم';
  Color _backgroundColor = Colors.white;
  String? _backgroundImage;
  DocumentSnapshot? _repliedMessage;
  TextEditingController messageController = TextEditingController();

  // Map to track local messages that are being sent
  final Map<String, Map<String, dynamic>> _pendingMessages = {};
  // Subscription for internet status changes
  StreamSubscription? _internetSubscription;
  // Subscription for message status updates
  StreamSubscription? _messageStatusSubscription;

  // Flag to track if user presence is enabled
  bool _userPresenceEnabled = false;

  int? get currentUserId => _currentUserId;
  String get currentUserName => _currentUserName;
  Color get backgroundColor => _backgroundColor;
  String? get backgroundImage => _backgroundImage;
  DocumentSnapshot? get repliedMessage => _repliedMessage;
  Map<String, Map<String, dynamic>> get pendingMessages => _pendingMessages;

  MessageProvider() {
    // Listen to internet status changes
    _setupInternetListener();
  }

  @override
  void dispose() {
    _internetSubscription?.cancel();
    _messageStatusSubscription?.cancel();
    messageController.dispose();
    super.dispose();
  }

  void _setupInternetListener() {
    _internetSubscription =
        _internetChecker.onStatusChange.listen((isConnected) {
      if (isConnected) {
        // When internet is restored, try to send pending messages
        _retryPendingMessages();
      }
    });
  }

  // Listen for message status updates in a specific chat
  void listenForMessageStatusUpdates(String chatId) {
    try {
      // Cancel any existing subscription
      _messageStatusSubscription?.cancel();

      // Set up a new subscription
      _messageStatusSubscription = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isEqualTo: _currentUserId)
          .snapshots()
          .listen((snapshot) {
        // This will be called whenever there's a change to any message sent by the current user
        notifyListeners();
      }, onError: (error) {
        _logger.e('Error listening for message status updates: $error');
      });
    } catch (e) {
      _logger.e('Error setting up message status listener: $e');
    }
  }

  // Check if user presence feature is available
  // Future<bool> _checkUserPresencePermission() async {
  //   if (_userPresenceEnabled) return true;

  //   try {
  //     if (_currentUserId == null) return false;

  //     // Try to read the user document first to check permissions
  //     await _firestore.collection('users').doc(_currentUserId.toString()).get();
  //     _userPresenceEnabled = true;
  //     return true;
  //   } catch (e) {
  //     _logger.i('User presence feature not available: $e');
  //     _userPresenceEnabled = false;
  //     return false;
  //   }
  // }

  // Future<void> fetchOwnerId(String chatId) async {
  //   final doc = await _firestore.collection('chats').doc(chatId).get();
  //   if (doc.exists) {
  //     final data = doc.data();
  //     ownerId = data?['ownerId'] as int?;
  //     storeId = data?['storeId'] as int?;
  //     notifyListeners();
  //   }
  // }

  // Get the recipient ID based on the conversation details
  Future<int?> _getRecipientId(String chatId) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        _logger.e('Chat document does not exist: $chatId');
        return null;
      }

      final data = chatDoc.data();
      if (data == null) {
        _logger.e('Chat document data is null: $chatId');
        return null;
      }

      final int ownerId = data['ownerId'] as int;
      final int customerId = data['customerId'] as int;

      // If current user is the owner, recipient is the customer, and vice versa
      if (_currentUserId == ownerId) {
        return customerId;
      } else if (_currentUserId == customerId) {
        return ownerId;
      } else {
        _logger.e('Current user is neither owner nor customer of this chat');
        return null;
      }
    } catch (e) {
      _logger.e('Error getting recipient ID: $e');
      return null;
    }
  }

  Future<void> _retryPendingMessages() async {
    // Create a copy of pending messages to avoid modification during iteration
    final pendingMessagesCopy =
        Map<String, Map<String, dynamic>>.from(_pendingMessages);

    for (var entry in pendingMessagesCopy.entries) {
      final tempId = entry.key;
      final messageData = entry.value;
      final chatId = messageData['chatId'] as String?;

      if (chatId != null) {
        try {
          // Get the recipient ID if not already set
          if (messageData['recipientId'] == null) {
            final recipientId = await _getRecipientId(chatId);
            if (recipientId != null) {
              messageData['recipientId'] = recipientId;
            }
          }

          // Try to send the message
          final docRef = await _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .add(messageData);

          await docRef.update({
            'status': MessageStatus.sent.toString().split('.').last,
          });

          // Remove from pending messages
          _pendingMessages.remove(tempId);
          notifyListeners();
        } catch (e) {
          _logger.e('فشل إعادة إرسال الرسالة: $e');
        }
      }
    }
  }

  Future<void> loadBackground() async {
    final String? colorValue =
        await _secureStorage.read(key: 'chat_background_color');
    final String? imagePath =
        await _secureStorage.read(key: 'chat_background_image');

    _backgroundColor =
        colorValue != null ? Color(int.parse(colorValue)) : Colors.white;
    _backgroundImage = imagePath;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    try {
      final userId = await SecureStorageHelper.getUserId();
      final user = await SecureStorageHelper.getUser();

      _currentUserId = userId ?? 0;
      _currentUserName = user?.name ?? 'مستخدم';

      notifyListeners();
    } catch (e) {
      _logger.e('خطأ في تحميل بيانات المستخدم: $e');
    }
  }

  // Filter message content
  String _filterMessage(String message) {
    // Remove excessive whitespace
    message = message.trim().replaceAll(RegExp(r'\s+'), ' ');
    return message;
  }

  Future<void> sendMessage(String chatId) async {
    final message = _filterMessage(messageController.text);
    if (message.isEmpty) return;

    // Generate a temporary ID for the message
    final String tempId = DateTime.now().millisecondsSinceEpoch.toString();

    // Get the recipient ID based on the conversation
    final recipientId = await _getRecipientId(chatId);

    // Create message data
    final messageData = {
      'content': message,
      'senderId': _currentUserId,
      'senderName': _currentUserName,
      'timestamp': Timestamp.now(),
      'status': MessageStatus.sending.toString().split('.').last, // 'sending'
      'tempId': tempId,
      'chatId': chatId, // Store chatId for retry purposes
      'recipientId': recipientId, // Set the recipient ID
    };

    // Add to pending messages for immediate display
    _pendingMessages[tempId] = messageData;

    // Clear input field immediately
    messageController.clear();
    notifyListeners();

    try {
      // Check internet connectivity
      bool isConnected = await _internetChecker.hasInternet;
      if (!isConnected) {
        _logger.i(
            'لا يوجد اتصال بالإنترنت. سيتم إرسال الرسالة عند استعادة الاتصال.');
        return;
      }

      // Send to Firestore
      final docRef = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData);

      // Update status to 'sent'
      await docRef.update({
        'status': MessageStatus.sent.toString().split('.').last, // 'sent'
      });

      // Remove from pending messages
      _pendingMessages.remove(tempId);

      // Try to update chat's lastMessage field
      try {
        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': message,
          'lastMessageTime': Timestamp.now(),
          'lastMessageSenderId': _currentUserId,
        });
      } catch (e) {
        _logger.w('Could not update last message info: $e');
        // Continue anyway as this is not critical
      }

      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('فشل إرسال الرسالة', error: e, stackTrace: stackTrace);

      // Keep in pending messages with sending status
      if (_pendingMessages.containsKey(tempId)) {
        _pendingMessages[tempId]!['status'] =
            MessageStatus.sending.toString().split('.').last;
        notifyListeners();
      }
    }
  }

  // Called when the recipient opens the chat
  Future<void> markAllMessagesAsRead(String chatId) async {
    try {
      // Get all unread messages sent to the current user
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('recipientId', isEqualTo: _currentUserId)
          .where('status', whereIn: [
        MessageStatus.sent.toString().split('.').last,
        MessageStatus.delivered.toString().split('.').last
      ]).get();

      if (unreadMessages.docs.isEmpty) return;

      // Update all messages to read
      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'status': MessageStatus.read.toString().split('.').last,
        });
      }
      await batch.commit();
    } catch (e) {
      _logger.e('فشل تحديث حالة القراءة للرسائل: $e');
    }
  }

  // Method to be called when the chat screen is opened
  Future<void> onChatOpened(String chatId) async {
    try {
      // Mark all messages as delivered first
      final undeliveredMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('recipientId', isEqualTo: _currentUserId)
          .where('status',
              isEqualTo: MessageStatus.sent.toString().split('.').last)
          .get();

      if (undeliveredMessages.docs.isNotEmpty) {
        final deliveredBatch = _firestore.batch();
        for (var doc in undeliveredMessages.docs) {
          deliveredBatch.update(doc.reference, {
            'status': MessageStatus.delivered.toString().split('.').last,
          });
        }
        await deliveredBatch.commit();
      }

      // Then mark all as read
      await markAllMessagesAsRead(chatId);
    } catch (e) {
      _logger.e('فشل تحديث حالة الرسائل عند فتح المحادثة: $e');
    }
  }

  void setRepliedMessage(DocumentSnapshot? message) {
    _repliedMessage = message;
    notifyListeners();
  }

  Future<void> updateBackground(String? image, Color? color) async {
    await _secureStorage.write(
      key: 'chat_background_color',
      value: color?.value.toString(),
    );
    await _secureStorage.write(
      key: 'chat_background_image',
      value: image,
    );
    _backgroundImage = image;
    _backgroundColor = color ?? Colors.white;
    notifyListeners();
  }

  Future<void> deleteAllMessages(String chatId) async {
    try {
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Clear pending messages
      _pendingMessages.clear();
      notifyListeners();
    } catch (e) {
      throw Exception('فشل الحذف: ${e.toString()}');
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).delete();
      // Clear pending messages
      _pendingMessages.clear();
      notifyListeners();
    } catch (e) {
      throw Exception('فشل حذف المحادثة: ${e.toString()}');
    }
  }
}
