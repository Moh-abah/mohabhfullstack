import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

part 'database_helper.g.dart';

// تعريف جدول العروض
@DataClassName('Offer')
class Offers extends Table {
  TextColumn get id => text()();
  TextColumn get merchantId => text()();
  TextColumn get storeName => text()();
  TextColumn get description => text()();
  IntColumn get duration => integer()();
  TextColumn get images => text()(); // تخزين الصور كسلسلة JSON
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get likes => integer().withDefault(const Constant(0))();
  BoolColumn get viewed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id}; // تعريف المفتاح الرئيسي هنا فقط
}

// تعريف جدول الإجراءات غير المتصلة
@DataClassName('OfflineAction')
class OfflineActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionType => text()(); // 'like', 'comment', etc.
  TextColumn get offerId => text()();
  TextColumn get userId => text()();
  TextColumn get username => text()();
  TextColumn get data => text().nullable()(); // JSON string for additional data
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

// تعريف جدول التعليقات غير المتصلة
@DataClassName('OfferComment')
class OfflineComments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get offerId => text()();
  TextColumn get userId => text()();
  TextColumn get username => text()();
  TextColumn get comment => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// تعريف جدول المحادثات
@DataClassName('Chat')
class Chats extends Table {
  TextColumn get id => text()();
  IntColumn get customerId => integer()();
  IntColumn get ownerId => integer()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// تعريف جدول رسائل المحادثات
@DataClassName('Message')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text()();
  IntColumn get senderId => integer()();
  TextColumn get content => text()();
  TextColumn get messageType =>
      text().withDefault(const Constant('text'))(); // text, image, etc.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get read => boolean().withDefault(const Constant(false))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// تعريف قاعدة البيانات
@DriftDatabase(
    tables: [Offers, OfflineActions, OfflineComments, Chats, Messages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // إدراج عرض جديد أو تحديثه إذا كان موجوداً
  Future<void> insertOffer(Offer offer) async {
    await into(offers).insertOnConflictUpdate(offer);
  }

  // الحصول على العروض بالصفحات
  Future<List<Offer>> getPaginatedOffers({
    int offset = 0,
    int limit = 5,
    bool activeOnly = true,
    bool orderByDate = false,
    bool orderByExpiry = true,
    bool descending = false,
  }) async {
    final query = select(offers);

    if (activeOnly) {
      query.where((o) => o.isActive.equals(true)); // ✅ تعديل الشرط مباشرةً
    }

    if (orderByDate) {
      query.orderBy([
        (o) => descending
            ? OrderingTerm.desc(o.createdAt)
            : OrderingTerm.asc(o.createdAt)
      ]);
    } else if (orderByExpiry) {
      query.orderBy([
        (o) => descending
            ? OrderingTerm.desc(o.expiryDate)
            : OrderingTerm.asc(o.expiryDate)
      ]);
    }

    query.limit(limit, offset: offset); // ✅ لا تعيد تعيين `query`

    return query.get(); // ✅ تنفيذ الاستعلام بشكل صحيح
  }

  // تحديد عرض كمشاهد
  Future<void> markOfferAsViewed(String offerId) async {
    final offerToUpdate = await (select(offers)
          ..where((o) => o.id.equals(offerId)))
        .getSingleOrNull();

    if (offerToUpdate != null) {
      await update(offers).replace(offerToUpdate.copyWith(viewed: true));
    }
  }

  // الحصول على عدد العروض المشاهدة
  Future<int> getViewedOffersCount() async {
    final result = await customSelect(
      'SELECT COUNT(*) AS count FROM offers WHERE viewed = 1',
    ).getSingle();

    return result.read<int>('count') ?? 0;
  }

  // إدراج إجراء غير متصل
  Future<void> insertOfflineAction(OfflineActionsCompanion action) async {
    await into(offlineActions).insert(action);
  }

  // الحصول على الإجراءات غير المتزامنة
  Future<List<OfflineAction>> getUnSyncedActions() async {
    return (select(offlineActions)..where((a) => a.synced.equals(false))).get();
  }

  // تحديد إجراء كمتزامن
  Future<void> markActionAsSynced(int actionId) async {
    await (update(offlineActions)..where((a) => a.id.equals(actionId)))
        .write(const OfflineActionsCompanion(synced: Value(true)));
  }

  // إدراج تعليق غير متصل
  Future<void> insertOfflineComment(OfflineCommentsCompanion comment) async {
    await into(offlineComments).insert(comment);
  }

  // الحصول على التعليقات المحلية لعرض معين
  Future<List<OfferComment>> getOfflineComments(String offerId) async {
    return (select(offlineComments)..where((c) => c.offerId.equals(offerId)))
        .get();
  }

  // تنفيذ استعلام مخصص

  @override
  Future<int> customUpdate(
    String query, {
    UpdateKind? updateKind,
    Set<TableInfo<Table, dynamic>>? updates,
    List<Variable<Object>> variables = const [],
  }) {
    return super.customUpdate(
      query,
      updateKind: updateKind,
      updates: updates,
      variables: variables,
    );
  }

  // ======= وظائف المحادثات =======

  // إدراج محادثة جديدة أو تحديثها إذا كانت موجودة
  Future<void> insertChat(Chat chat) async {
    await into(chats).insertOnConflictUpdate(chat);
  }

  // إدراج محادثة من Firestore
  Future<void> insertChatFromFirestore(
      Map<String, dynamic> firestoreChat, String chatId) async {
    final chat = Chat(
      id: chatId,
      customerId: firestoreChat['customerId'] as int,
      ownerId: firestoreChat['ownerId'] as int,
      status: firestoreChat['status'] as String,
      createdAt: (firestoreChat['createdAt'] != null)
          ? DateTime.fromMillisecondsSinceEpoch(
              (firestoreChat['createdAt'] as int))
          : DateTime.now(),
      updatedAt: (firestoreChat['updatedAt'] != null)
          ? DateTime.fromMillisecondsSinceEpoch(
              (firestoreChat['updatedAt'] as int))
          : DateTime.now(),
      synced: true,
    );

    await insertChat(chat);
  }

  // الحصول على جميع المحادثات للمستخدم
  Future<List<Chat>> getChatsByUserId(int userId) async {
    return (select(chats)
          ..where((c) => c.customerId.equals(userId) | c.ownerId.equals(userId))
          ..orderBy([(c) => OrderingTerm.desc(c.updatedAt)]))
        .get();
  }

  // الحصول على محادثة معينة
  Future<Chat?> getChatById(String chatId) async {
    return (select(chats)..where((c) => c.id.equals(chatId))).getSingleOrNull();
  }

  // تحديث حالة المحادثة
  Future<void> updateChatStatus(String chatId, String status) async {
    await (update(chats)..where((c) => c.id.equals(chatId)))
        .write(ChatsCompanion(
      status: Value(status),
      updatedAt: Value(DateTime.now()),
      synced: const Value(false),
    ));
  }

  // إدراج رسالة جديدة
  Future<void> insertMessage(Message message) async {
    await into(messages).insertOnConflictUpdate(message);

    // تحديث وقت آخر تحديث للمحادثة
    await (update(chats)..where((c) => c.id.equals(message.chatId)))
        .write(ChatsCompanion(
      updatedAt: Value(DateTime.now()),
    ));
  }

  // إدراج رسالة من Firestore
  Future<void> insertMessageFromFirestore(
      Map<String, dynamic> firestoreMessage, String messageId) async {
    final message = Message(
      id: messageId,
      chatId: firestoreMessage['chatId'] as String,
      senderId: firestoreMessage['senderId'] as int,
      content: firestoreMessage['content'] as String,
      messageType: firestoreMessage['messageType'] as String? ?? 'text',
      createdAt: (firestoreMessage['createdAt'] != null)
          ? DateTime.fromMillisecondsSinceEpoch(
              (firestoreMessage['createdAt'] as int))
          : DateTime.now(),
      read: firestoreMessage['read'] as bool? ?? false,
      synced: true,
    );

    await insertMessage(message);
  }

  // الحصول على رسائل محادثة معينة
  Future<List<Message>> getMessagesByChatId(String chatId) async {
    return (select(messages)
          ..where((m) => m.chatId.equals(chatId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get();
  }

  // الحصول على آخر رسالة في محادثة معينة
  Future<Message?> getLastMessageByChatId(String chatId) async {
    return (select(messages)
          ..where((m) => m.chatId.equals(chatId))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  // تحديث حالة قراءة الرسائل
  Future<void> markMessagesAsRead(String chatId, int userId) async {
    await (update(messages)
          ..where(
              (m) => m.chatId.equals(chatId) & m.senderId.equals(userId).not()))
        .write(const MessagesCompanion(
      read: Value(true),
      synced: Value(false),
    ));
  }

  // الحصول على عدد الرسائل غير المقروءة في محادثة معينة
  Future<int> getUnreadMessagesCount(String chatId, int userId) async {
    final result = await customSelect(
      'SELECT COUNT(*) AS unread_count FROM messages WHERE chat_id = ? AND sender_id != ? AND read = 0',
      variables: [Variable.withString(chatId), Variable.withInt(userId)],
    ).getSingle();

    return result.read<int>('unread_count') ?? 0;
  }

  // الحصول على إجمالي عدد الرسائل غير المقروءة للمستخدم
  Future<int> getTotalUnreadMessagesCount(int userId) async {
    final userChats = await getChatsByUserId(userId);
    int totalUnread = 0;

    for (var chat in userChats) {
      totalUnread += await getUnreadMessagesCount(chat.id, userId);
    }

    return totalUnread;
  }

  // الحصول على الرسائل غير المتزامنة
  Future<List<Message>> getUnSyncedMessages() async {
    return (select(messages)..where((m) => m.synced.equals(false))).get();
  }

  // تحديد رسالة كمتزامنة
  Future<void> markMessageAsSynced(String messageId) async {
    await (update(messages)..where((m) => m.id.equals(messageId)))
        .write(const MessagesCompanion(synced: Value(true)));
  }

  // الحصول على المحادثات غير المتزامنة
  Future<List<Chat>> getUnSyncedChats() async {
    return (select(chats)..where((c) => c.synced.equals(false))).get();
  }

  // تحديد محادثة كمتزامنة
  Future<void> markChatAsSynced(String chatId) async {
    await (update(chats)..where((c) => c.id.equals(chatId)))
        .write(const ChatsCompanion(synced: Value(true)));
  }
}

// فتح اتصال قاعدة البيانات
// تغيير مسار قاعدة البيانات باستخدام dart:io مباشرة
// تعديل مسار قاعدة البيانات بدون استخدام مكتبات إضافية
// تعديل مسار قاعدة البيانات بدون استخدام مكتبات إضافية
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // استخدام مسار نسبي داخل مجلد التطبيق
    // في Flutter، التطبيق لديه صلاحيات للكتابة في مجلده الخاص

    // استخدام مسار مؤقت آمن متاح لجميع تطبيقات Flutter
    final dbFolder = Directory.systemTemp;

    final file = File(path.join(dbFolder.path, 'offers_database.sqlite'));

    // التأكد من وجود المجلد
    if (!(await dbFolder.exists())) {
      try {
        await dbFolder.create(recursive: true);
      } catch (e) {
        print('خطأ في إنشاء المجلد: $e');
        // استخدام مسار بديل في حالة الفشل
        final alternativePath = 'offers_database.sqlite';
        return NativeDatabase.createInBackground(File(alternativePath));
      }
    }

    return NativeDatabase.createInBackground(file);
  });
}
