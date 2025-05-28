import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../utils/internet_checker.dart';
import '../database_helper.dart';

class ChatStorageService {
  final AppDatabase _database;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final InternetChecker _internetChecker = InternetChecker();
  final Logger _logger = Logger();
  final Uuid _uuid = Uuid();

  ChatStorageService(this._database);

  // التحقق من حالة الاتصال
  Future<bool> isOnline() async {
    return await _internetChecker.hasInternet;
  }

  // الحصول على تدفق حالة الاتصال
  Stream<bool> get connectivityStream => _internetChecker.onStatusChange;

  // ===== وظائف المحادثات =====

  // إنشاء محادثة جديدة
  Future<String> createChat(int customerId, int ownerId) async {
    _logger.i("إنشاء محادثة جديدة بين العميل $customerId والمتجر $ownerId");

    try {
      final bool online = await isOnline();
      final String chatId = _uuid.v4();

      // إنشاء كائن المحادثة
      final chat = Chat(
        id: chatId,
        customerId: customerId,
        ownerId: ownerId,
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        synced: false,
      );

      // حفظ المحادثة محلياً
      await _database.insertChat(chat);

      if (online) {
        // إنشاء المحادثة في Firestore
        await _firestore.collection('chats').doc(chatId).set({
          'customerId': customerId,
          'ownerId': ownerId,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // تحديث حالة المزامنة
        await _database.markChatAsSynced(chatId);
      }

      _logger.i("تم إنشاء المحادثة بنجاح: $chatId");
      return chatId;
    } catch (e) {
      _logger.e("خطأ في إنشاء المحادثة: $e");
      throw e;
    }
  }

  // جلب محادثات المستخدم
  Future<List<Chat>> getUserChats(int userId) async {
    _logger.i("جلب محادثات المستخدم: $userId");

    try {
      final bool online = await isOnline();

      if (online) {
        // جلب محادثات العميل من Firestore
        final customerSnapshot = await _firestore
            .collection('chats')
            .where('customerId', isEqualTo: userId)
            .get();

        // جلب محادثات المالك من Firestore
        final ownerSnapshot = await _firestore
            .collection('chats')
            .where('ownerId', isEqualTo: userId)
            .get();

        // تخزين المحادثات محلياً
        for (var doc in customerSnapshot.docs) {
          await _database.insertChatFromFirestore(
            doc.data(),
            doc.id,
          );
        }

        for (var doc in ownerSnapshot.docs) {
          await _database.insertChatFromFirestore(
            doc.data(),
            doc.id,
          );
        }
      }

      // جلب المحادثات من قاعدة البيانات المحلية
      final chats = await _database.getChatsByUserId(userId);
      _logger.i("تم جلب ${chats.length} محادثة للمستخدم $userId");

      return chats;
    } catch (e) {
      _logger.e("خطأ في جلب محادثات المستخدم: $e");

      // في حالة الخطأ، محاولة جلب المحادثات من قاعدة البيانات المحلية
      try {
        final chats = await _database.getChatsByUserId(userId);
        return chats;
      } catch (innerError) {
        _logger
            .e("خطأ في جلب المحادثات من قاعدة البيانات المحلية: $innerError");
        return [];
      }
    }
  }

  // تحديث حالة المحادثة
  Future<void> updateChatStatus(String chatId, String status) async {
    _logger.i("تحديث حالة المحادثة $chatId إلى $status");

    try {
      final bool online = await isOnline();

      // تحديث الحالة محلياً
      await _database.updateChatStatus(chatId, status);

      if (online) {
        // تحديث الحالة في Firestore
        await _firestore.collection('chats').doc(chatId).update({
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // تحديث حالة المزامنة
        await _database.markChatAsSynced(chatId);
      }

      _logger.i("تم تحديث حالة المحادثة بنجاح");
    } catch (e) {
      _logger.e("خطأ في تحديث حالة المحادثة: $e");
      throw e;
    }
  }

  // ===== وظائف الرسائل =====

  // إرسال رسالة جديدة
  Future<String> sendMessage(String chatId, int senderId, String content,
      {String messageType = 'text'}) async {
    _logger.i("إرسال رسالة جديدة في المحادثة $chatId");

    try {
      final bool online = await isOnline();
      final String messageId = _uuid.v4();

      // إنشاء كائن الرسالة
      final message = Message(
        id: messageId,
        chatId: chatId,
        senderId: senderId,
        content: content,
        messageType: messageType,
        createdAt: DateTime.now(),
        read: false,
        synced: false,
      );

      // حفظ الرسالة محلياً
      await _database.insertMessage(message);

      if (online) {
        // إرسال الرسالة إلى Firestore
        await _firestore.collection('messages').doc(messageId).set({
          'chatId': chatId,
          'senderId': senderId,
          'content': content,
          'messageType': messageType,
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });

        // تحديث وقت آخر تحديث للمحادثة في Firestore
        await _firestore.collection('chats').doc(chatId).update({
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // تحديث حالة المزامنة
        await _database.markMessageAsSynced(messageId);
      }

      _logger.i("تم إرسال الرسالة بنجاح: $messageId");
      return messageId;
    } catch (e) {
      _logger.e("خطأ في إرسال الرسالة: $e");
      throw e;
    }
  }

  // جلب رسائل محادثة معينة
  Future<List<Message>> getChatMessages(String chatId) async {
    _logger.i("جلب رسائل المحادثة: $chatId");

    try {
      final bool online = await isOnline();

      if (online) {
        // جلب الرسائل من Firestore
        final snapshot = await _firestore
            .collection('messages')
            .where('chatId', isEqualTo: chatId)
            .orderBy('createdAt', descending: false)
            .get();

        // تخزين الرسائل محلياً
        for (var doc in snapshot.docs) {
          await _database.insertMessageFromFirestore(
            doc.data(),
            doc.id,
          );
        }
      }

      // جلب الرسائل من قاعدة البيانات المحلية
      final messages = await _database.getMessagesByChatId(chatId);
      _logger.i("تم جلب ${messages.length} رسالة للمحادثة $chatId");

      return messages;
    } catch (e) {
      _logger.e("خطأ في جلب رسائل المحادثة: $e");

      // في حالة الخطأ، محاولة جلب الرسائل من قاعدة البيانات المحلية
      try {
        final messages = await _database.getMessagesByChatId(chatId);
        return messages;
      } catch (innerError) {
        _logger.e("خطأ في جلب الرسائل من قاعدة البيانات المحلية: $innerError");
        return [];
      }
    }
  }

  // تحديث حالة قراءة الرسائل
  Future<void> markMessagesAsRead(String chatId, int userId) async {
    _logger.i("تحديث حالة قراءة الرسائل في المحادثة $chatId للمستخدم $userId");

    try {
      final bool online = await isOnline();

      // تحديث حالة القراءة محلياً
      await _database.markMessagesAsRead(chatId, userId);

      if (online) {
        // جلب الرسائل غير المقروءة من Firestore
        final snapshot = await _firestore
            .collection('messages')
            .where('chatId', isEqualTo: chatId)
            .where('senderId', isNotEqualTo: userId)
            .where('read', isEqualTo: false)
            .get();

        // تحديث حالة القراءة في Firestore
        final batch = _firestore.batch();
        for (var doc in snapshot.docs) {
          batch.update(doc.reference, {'read': true});
        }
        await batch.commit();
      }

      _logger.i("تم تحديث حالة قراءة الرسائل بنجاح");
    } catch (e) {
      _logger.e("خطأ في تحديث حالة قراءة الرسائل: $e");
    }
  }

  // الحصول على عدد الرسائل غير المقروءة
  Future<int> getUnreadMessagesCount(String chatId, int userId) async {
    try {
      return await _database.getUnreadMessagesCount(chatId, userId);
    } catch (e) {
      _logger.e("خطأ في جلب عدد الرسائل غير المقروءة: $e");
      return 0;
    }
  }

  // الحصول على إجمالي عدد الرسائل غير المقروءة للمستخدم
  Future<int> getTotalUnreadMessagesCount(int userId) async {
    try {
      return await _database.getTotalUnreadMessagesCount(userId);
    } catch (e) {
      _logger.e("خطأ في جلب إجمالي عدد الرسائل غير المقروءة: $e");
      return 0;
    }
  }

  // ===== وظائف المزامنة =====

  // مزامنة البيانات غير المتزامنة
  Future<void> syncOfflineData() async {
    _logger.i("بدء مزامنة البيانات غير المتزامنة");

    try {
      final bool online = await isOnline();

      if (!online) {
        _logger.i("لا يمكن المزامنة: غير متصل بالإنترنت");
        return;
      }

      // مزامنة المحادثات غير المتزامنة
      await _syncChats();

      // مزامنة الرسائل غير المتزامنة
      await _syncMessages();

      _logger.i("تمت مزامنة البيانات بنجاح");
    } catch (e) {
      _logger.e("خطأ في مزامنة البيانات: $e");
    }
  }

  // مزامنة المحادثات غير المتزامنة
  Future<void> _syncChats() async {
    try {
      final unSyncedChats = await _database.getUnSyncedChats();
      _logger.i("وجدت ${unSyncedChats.length} محادثة غير متزامنة");

      for (var chat in unSyncedChats) {
        try {
          // التحقق مما إذا كانت المحادثة موجودة في Firestore
          final docSnapshot =
              await _firestore.collection('chats').doc(chat.id).get();

          if (docSnapshot.exists) {
            // تحديث المحادثة الموجودة
            await _firestore.collection('chats').doc(chat.id).update({
              'status': chat.status,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } else {
            // إنشاء محادثة جديدة
            await _firestore.collection('chats').doc(chat.id).set({
              'customerId': chat.customerId,
              'ownerId': chat.ownerId,
              'status': chat.status,
              'createdAt': chat.createdAt.millisecondsSinceEpoch,
              'updatedAt': DateTime.now().millisecondsSinceEpoch,
            });
          }

          // تحديث حالة المزامنة
          await _database.markChatAsSynced(chat.id);
          _logger.i("تمت مزامنة المحادثة: ${chat.id}");
        } catch (e) {
          _logger.e("خطأ في مزامنة المحادثة ${chat.id}: $e");
        }
      }
    } catch (e) {
      _logger.e("خطأ في مزامنة المحادثات: $e");
    }
  }

  // مزامنة الرسائل غير المتزامنة
  Future<void> _syncMessages() async {
    try {
      final unSyncedMessages = await _database.getUnSyncedMessages();
      _logger.i("وجدت ${unSyncedMessages.length} رسالة غير متزامنة");

      for (var message in unSyncedMessages) {
        try {
          // التحقق مما إذا كانت الرسالة موجودة في Firestore
          final docSnapshot =
              await _firestore.collection('messages').doc(message.id).get();

          if (docSnapshot.exists) {
            // تحديث الرسالة الموجودة
            await _firestore.collection('messages').doc(message.id).update({
              'read': message.read,
            });
          } else {
            // إنشاء رسالة جديدة
            await _firestore.collection('messages').doc(message.id).set({
              'chatId': message.chatId,
              'senderId': message.senderId,
              'content': message.content,
              'messageType': message.messageType,
              'createdAt': message.createdAt.millisecondsSinceEpoch,
              'read': message.read,
            });

            // تحديث وقت آخر تحديث للمحادثة
            await _firestore.collection('chats').doc(message.chatId).update({
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }

          // تحديث حالة المزامنة
          await _database.markMessageAsSynced(message.id);
          _logger.i("تمت مزامنة الرسالة: ${message.id}");
        } catch (e) {
          _logger.e("خطأ في مزامنة الرسالة ${message.id}: $e");
        }
      }
    } catch (e) {
      _logger.e("خطأ في مزامنة الرسائل: $e");
    }
  }
}
