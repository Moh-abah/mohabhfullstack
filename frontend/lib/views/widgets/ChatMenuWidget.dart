import 'package:flutter/material.dart';

class ChatMenuWidget extends StatelessWidget {
  //final VoidCallback onStoreInfo;
  final VoidCallback onChangeBackground;
  final VoidCallback onDeleteMessages;
  final VoidCallback onDeleteChat;

  const ChatMenuWidget({
    super.key,

    //required this.onStoreInfo,
    required this.onChangeBackground,
    required this.onDeleteMessages,
    required this.onDeleteChat,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          /*
          case 'store_info':
            provider.fetchOwnerId(chatId); // استخدم المعرف الممرر
            final ownerId = provider.ownerId;
            final sstoreId = provider.storeId;

            if (ownerId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profilestore(
                    marchintID: ownerId,
                    storeId: sstoreId,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('فشل في جلب بيانات التاجر')),
              );
            }
            break;
            */

          case 'change_background':
            onChangeBackground();
            break;
          case 'delete_messages':
            onDeleteMessages();
            break;
          case 'delete_chat':
            onDeleteChat();
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem(
            value: 'store_info',
            child: Text("عرض معلومات المتجر"),
          ),
          const PopupMenuItem(
            value: 'change_background',
            child: Text("تغيير الخلفية"),
          ),
          const PopupMenuItem(
            value: 'delete_messages',
            child: Text("حذف الرسائل"),
          ),
          const PopupMenuItem(
            value: 'delete_chat',
            child: Text("حذف المحادثة"),
          ),
        ];
      },
    );
  }
}
