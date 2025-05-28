import 'package:ain_frontend/viewmodels/Profile_Store_Provider.dart';
import 'package:ain_frontend/viewmodels/ReviewViewModel.dart';
import 'package:ain_frontend/viewmodels/Store_Map_Provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/addReview_model.dart';

class AddReviewDialog extends StatefulWidget {
  final int storeId;

  const AddReviewDialog({super.key, required this.storeId});

  @override
  _AddReviewDialogState createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  int _rating = 0; // التقييم بالنجمات (من 1 إلى 5)
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("أضف تقييم للمتجر"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // عرض النجوم كأزرار قابلة للاختيار
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating =
                        index + 1; // عند الضغط على النجمة يتم تحديد التقييم
                  });
                },
                child: Icon(
                  _rating > index ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 30,
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: "التعليق"),
            maxLines: 3,
            enabled: !_isSubmitting,
          ),
          if (_isSubmitting)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    "جاري إرسال التقييم...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text("إلغاء"),
          style: TextButton.styleFrom(
            foregroundColor: _isSubmitting ? Colors.grey : null,
          ),
        ),
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  if (_rating >= 1 &&
                      _rating <= 5 &&
                      _commentController.text.isNotEmpty) {
                    setState(() {
                      _isSubmitting = true;
                    });

                    final reviewModel = AddReviewModel(
                        rating: _rating, comment: _commentController.text);

                    try {
                      // إرسال التقييم
                      await context.read<ReviewViewModel>().submitReview(
                            widget.storeId,
                            reviewModel.rating,
                            reviewModel.comment,
                            context.read<ReviewsState>(),
                          );

                      Navigator.of(context).pop(true);

                      // تحديث التقييمات
                      await context
                          .read<ReviewsState>()
                          .fetchStoreReviews(widget.storeId);

                      // تحديث بيانات المتجر
                      await context
                          .read<StoresState>()
                          .updateStoreRating(widget.storeId);

                      Navigator.of(context).pop(true);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("تم إضافة التقييم بنجاح"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.of(context).pop(true);
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() {
                          _isSubmitting = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("حدث خطأ: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("يرجى إدخال التقييم والتعليق بشكل صحيح"),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
          child: const Text("إرسال"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
}
