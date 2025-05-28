// firebase_message_service.dart
import 'dart:async';
import 'package:ain_frontend/viewmodels/Message_Provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class FirebaseMessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  Future<int?> getRecipientId(String chatId, int? currentUserId) async {
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
      if (currentUserId == ownerId) {
        return customerId;
      } else if (currentUserId == customerId) {
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

  Future<void> sendMessage(
      String chatId, Map<String, dynamic> messageData) async {
    try {
      final docRef = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData);

      // Update status to 'sent'
      await docRef.update({
        'status': MessageStatus.sent.toString().split('.').last, // 'sent'
      });
    } catch (e) {
      _logger.e('Error sending message: $e');
    }
  }

  Future<void> updateLastMessage(String chatId,
      Map<String, dynamic> messageData, int? currentUserId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': messageData['content'],
        'lastMessageTime': messageData['timestamp'],
        'lastMessageSenderId': currentUserId,
      });
    } catch (e) {
      _logger.w('Could not update last message info: $e');
    }
  }

  Future<void> markMessagesAsRead(String chatId, int? currentUserId) async {
    try {
      // Get all unread messages sent to the current user
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('recipientId', isEqualTo: currentUserId)
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
      _logger.e('Error marking messages as read: $e');
    }
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
    } catch (e) {
      _logger.e('Error deleting all messages: $e');
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).delete();
    } catch (e) {
      _logger.e('Error deleting chat: $e');
    }
  }

  Future<void> updateMessageStatus(
      String chatId, String messageId, MessageStatus status) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'status': status.toString().split('.').last});
    } catch (e) {
      _logger.e('Error updating message status: $e');
    }
  }
}
