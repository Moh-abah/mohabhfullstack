import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import '../database_helper.dart';

import '../ServicesFireBase/firestore_service.dart';

class OfflineActionService {
  final AppDatabase _database;
  final FirestoreService _firestoreService;
  final Logger _logger = Logger();

  OfflineActionService(this._database, this._firestoreService);

  // وضع إجراء الإعجاب في قائمة الانتظار للمزامنة لاحقاً
  Future<void> queueLikeAction(
      String offerId, String userId, String username) async {
    _logger.i("وضع إجراء الإعجاب في قائمة الانتظار للعرض $offerId");

    try {
      await _database.insertOfflineAction(
        OfflineActionsCompanion(
          actionType: const Value('like'),
          offerId: Value(offerId),
          userId: Value(userId),
          username: Value(username),
          createdAt: Value(DateTime.now()),
        ),
      );
      _logger.i("تم وضع إجراء الإعجاب في قائمة الانتظار بنجاح");
    } catch (e) {
      _logger.e("خطأ في وضع إجراء الإعجاب في قائمة الانتظار: $e");
      rethrow;
    }
  }

  // وضع إجراء التعليق في قائمة الانتظار للمزامنة لاحقاً
  Future<void> queueCommentAction(
      String offerId, String userId, String username, String comment) async {
    _logger.i("وضع إجراء التعليق في قائمة الانتظار للعرض $offerId");

    try {
      // حفظ التعليق محلياً للعرض في وضع عدم الاتصال
      await _database.insertOfflineComment(
        OfflineCommentsCompanion(
          offerId: Value(offerId),
          userId: Value(userId),
          username: Value(username),
          comment: Value(comment),
          createdAt: Value(DateTime.now()),
        ),
      );

      // وضع إجراء التعليق في قائمة الانتظار للمزامنة
      await _database.insertOfflineAction(
        OfflineActionsCompanion(
          actionType: const Value('comment'),
          offerId: Value(offerId),
          userId: Value(userId),
          username: Value(username),
          data: Value(jsonEncode({'comment': comment})),
          createdAt: Value(DateTime.now()),
        ),
      );
      _logger.i("تم وضع إجراء التعليق في قائمة الانتظار بنجاح");
    } catch (e) {
      _logger.e("خطأ في وضع إجراء التعليق في قائمة الانتظار: $e");
      rethrow;
    }
  }

  // مزامنة جميع الإجراءات في قائمة الانتظار
  Future<void> syncOfflineActions() async {
    _logger.i("بدء مزامنة الإجراءات غير المتصلة");

    try {
      // الحصول على جميع الإجراءات غير المتزامنة
      final actions = await _database.getUnSyncedActions();
      _logger.i("تم العثور على ${actions.length} إجراء غير متزامن");

      for (var action in actions) {
        bool success = false;

        try {
          if (action.actionType == 'like') {
            // مزامنة إجراء الإعجاب
            await _firestoreService.addLikeToOffer(
              action.offerId,
              action.userId,
              action.username,
            );
            success = true;
          } else if (action.actionType == 'comment') {
            // تحليل بيانات التعليق
            final data = jsonDecode(action.data ?? '{}');
            final comment = data['comment'] as String?;

            if (comment != null) {
              // مزامنة إجراء التعليق
              await _firestoreService.addCommentToOffer(
                action.offerId,
                action.userId,
                comment,
                action.username,
              );
              success = true;
            }
          }

          if (success) {
            // تحديد الإجراء كمتزامن
            await _database.markActionAsSynced(action.id);
            _logger.i(
                "تمت مزامنة إجراء ${action.actionType} بنجاح للعرض ${action.offerId}");
          }
        } catch (e) {
          _logger.e("خطأ في مزامنة إجراء ${action.actionType}: $e");
          // الاستمرار مع الإجراء التالي
        }
      }

      _logger.i("اكتملت مزامنة الإجراءات غير المتصلة");
    } catch (e) {
      _logger.e("خطأ أثناء مزامنة الإجراءات غير المتصلة: $e");
      rethrow;
    }
  }

  // الحصول على التعليقات المحلية لعرض معين
  Future<List<OfferComment>> getOfflineComments(String offerId) async {
    try {
      return await _database.getOfflineComments(offerId);
    } catch (e) {
      _logger.e("خطأ في الحصول على التعليقات المحلية: $e");
      return [];
    }
  }
}
