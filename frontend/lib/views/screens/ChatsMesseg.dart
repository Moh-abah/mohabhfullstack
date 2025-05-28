import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ain_frontend/viewmodels/Message_Provider.dart';
import 'package:ain_frontend/views/widgets/wallpaper.dart';

import '../widgets/ChatMenuWidget.dart'; // تأكد من صحة المسار

class ChatsMesseg extends StatefulWidget {
  final String chatId;

  const ChatsMesseg({super.key, required this.chatId});

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsMesseg> {
  // Update to ChatsScreen.dart to mark messages as delivered/read when opened
  @override
  void initState() {
    super.initState();

    // Use a post-frame callback to ensure the context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = Provider.of<MessageProvider>(context, listen: false);
      provider.loadBackground();
      provider.loadUserData();

      // Start listening for message status updates
      provider.listenForMessageStatusUpdates(widget.chatId);

      // Mark messages as delivered/read when chat is opened
      provider.onChatOpened(widget.chatId);
    });
  }

  @override
  void dispose() {
    // No need to call any methods that might cause errors
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<MessageProvider>(
        builder: (context, provider, _) => Container(
          decoration: BoxDecoration(
            color: provider.backgroundColor,
            image: provider.backgroundImage != null
                ? DecorationImage(
                    image: NetworkImage(provider.backgroundImage!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.1),
                      BlendMode.darken,
                    ),
                  )
                : null,
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: _buildMessagesList(provider),
                ),
              ),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A5C8D), Color(0xFF1E3F6F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.chat, color: Colors.white),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المحادثة',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              /* 
              Text(
                'متصل الآن',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              */
            ],
          ),
        ],
      ),
      actions: [
        ChatMenuWidget(
          //onStoreInfo: () => //////////////,
          onChangeBackground: () => _showBackgroundSelector(context),
          onDeleteMessages: () => _confirmDeleteMessages(context),
          onDeleteChat: () => _confirmDeleteChat(context),
        ),
      ],
    );
  }

  Widget _buildMessagesList(MessageProvider provider) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('حدث خطأ: ${snapshot.error}'));
        }

        // Get messages from Firestore
        //final List<Map<String, dynamic>> allMessages = [];
        final List<DocumentSnapshot> firestoreMessages = [];

        // Add messages from Firestore
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            // Skip messages that are in pending (to avoid duplicates)
            if (provider.pendingMessages.values
                .any((m) => m['tempId'] == data['tempId'])) {
              continue;
            }
            firestoreMessages.add(doc);
          }
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            firestoreMessages.isEmpty &&
            provider.pendingMessages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // First render Firestore messages
        return ListView.builder(
          reverse: false, // ترتيب الرسائل من الأقدم إلى الأحدث
          padding: EdgeInsets.zero,
          // Add the count of both Firestore messages and pending messages
          itemCount: firestoreMessages.length + provider.pendingMessages.length,
          itemBuilder: (context, index) {
            // Handle pending messages after Firestore messages
            if (index >= firestoreMessages.length) {
              // This is a pending message
              final pendingIndex = index - firestoreMessages.length;
              final pendingMessage =
                  provider.pendingMessages.values.elementAt(pendingIndex);

              // تحقق من أن currentUserId ليس null قبل المقارنة
              if (provider.currentUserId == null) {
                print('Current UserId is null!');
                return _buildPendingMessageBubble(pendingMessage, provider);
              }

              // طباعة senderId و currentUserId للتحقق من القيم
              print('Pending Message SenderId: ${pendingMessage['senderId']}');
              print('Current UserId: ${provider.currentUserId}');

              // تحقق إذا كانت الرسالة مرسلة من قبل المستخدم
              bool isSentByUser =
                  pendingMessage['senderId'] == provider.currentUserId;

              // طباعة ما إذا كانت الرسالة مرسلة من المستخدم
              print('Is pending message sent by user? $isSentByUser');

              // تحديد المحاذاة بناءً على من هو المرسل
              final alignment = isSentByUser
                  ? Alignment
                      .centerRight // إذا كانت مرسلة من المستخدم تكون على اليمين
                  : Alignment.centerLeft; // إذا كانت مستقبلة تكون على اليسار

              // طباعة الموقع الفعلي للرسالة
              print(
                  'Pending message is aligned to: ${isSentByUser ? "Right" : "Left"}');

              return Padding(
                padding: const EdgeInsets.only(
                    bottom: 10.0), // تباعد بين كل رسالة والتي تليها
                child: Align(
                  alignment: alignment,
                  child: _buildPendingMessageBubble(pendingMessage, provider),
                ),
              );
            }

            // This is a Firestore message
            final message = firestoreMessages[index];

            // تحقق من أن currentUserId ليس null قبل المقارنة
            if (provider.currentUserId == null) {
              print('Current UserId is null!');
              return _buildMessageBubble(
                  message, provider); // بناء واجهة الرسالة
            }

            // طباعة senderId و currentUserId للتحقق من القيم
            print('Message SenderId: ${message['senderId']}');
            print('Current UserId: ${provider.currentUserId}');

            // تحقق إذا كانت الرسالة مرسلة من قبل المستخدم
            bool isSentByUser = message['senderId'] == provider.currentUserId;

            // طباعة ما إذا كانت الرسالة مرسلة من المستخدم
            print('Is message sent by user? $isSentByUser');

            // تحديد المحاذاة بناءً على من هو المرسل
            final alignment = isSentByUser
                ? Alignment
                    .centerRight // إذا كانت مرسلة من المستخدم تكون على اليمين
                : Alignment.centerLeft; // إذا كانت مستقبلة تكون على اليسار

            // طباعة الموقع الفعلي للرسالة
            print('Message is aligned to: ${isSentByUser ? "Right" : "Left"}');

            return Padding(
              padding: const EdgeInsets.only(
                  bottom: 10.0), // تباعد بين كل رسالة والتي تليها
              child: Align(
                alignment: alignment,
                child: _buildMessageBubble(
                    message, provider), // بناء واجهة الرسالة
              ),
            );
          },
        );
      },
    );
  }

  // Original message bubble for Firestore messages
  Widget _buildMessageBubble(
      DocumentSnapshot message, MessageProvider provider) {
    final data = message.data() as Map<String, dynamic>;
    final isCurrentUser = data['senderId'] == provider.currentUserId;
    final isReply = message.id == provider.repliedMessage?.id;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? const Color.fromARGB(255, 42, 92, 141)
            : const Color.fromARGB(255, 63, 79, 100),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isCurrentUser ? 12 : 4),
          bottomRight: Radius.circular(isCurrentUser ? 4 : 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isReply)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  provider.repliedMessage!['content'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Text(
              data['content'],
              style: const TextStyle(
                color: Color.fromARGB(221, 255, 255, 255),
                fontSize: 16,
                height: 1.4,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTimestamp(data['timestamp']),
                    style: TextStyle(
                      color: const Color.fromARGB(255, 226, 226, 226),
                      fontSize: 12,
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 6),
                    _buildEnhancedStatusIcon(data['status'] ?? 'sent', false),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pending message bubble with similar structure to original
  Widget _buildPendingMessageBubble(
      Map<String, dynamic> pendingMessage, MessageProvider provider) {
    final isCurrentUser = pendingMessage['senderId'] == provider.currentUserId;
    final isPending = true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFDCF8C6) : Colors.grey[200],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isCurrentUser ? 12 : 4),
          bottomRight: Radius.circular(isCurrentUser ? 4 : 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pendingMessage['content'],
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatPendingTimestamp(pendingMessage['timestamp']),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 6),
                    _buildEnhancedStatusIcon(
                        pendingMessage['status'], isPending),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStatusIcon(String status, bool isPending) {
    // If message is pending and status is 'sending', show rotating clock
    if (isPending && status == 'sending') {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
        ),
      );
    }

    // For other statuses
    switch (status) {
      case 'sending':
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        );
      case 'sent':
        return Icon(Icons.check, size: 16, color: Colors.grey[600]);
      case 'delivered':
        return Icon(Icons.done_all, size: 16, color: Colors.grey[600]);
      case 'read':
        return const Icon(Icons.done_all, size: 16, color: Colors.blue);
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPendingTimestamp(dynamic timestamp) {
    final DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else {
      date = DateTime.now(); // Fallback for pending messages
    }
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageInput() {
    final provider = Provider.of<MessageProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          if (provider.repliedMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'رد على: ${provider.repliedMessage!['content']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                    onPressed: () => provider.setRepliedMessage(null),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: provider.messageController,
                  maxLines: 5,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالة...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => provider.sendMessage(widget.chatId),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBackgroundSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => BackgroundSelectorWidget(
        onBackgroundSelected: (image, color) =>
            Provider.of<MessageProvider>(context, listen: false)
                .updateBackground(image, color),
      ),
    );
  }

  void _confirmDeleteMessages(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الرسائل'),
        content: const Text('هل تريد حذف كل الرسائل في هذه المحادثة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<MessageProvider>(context, listen: false)
                    .deleteAllMessages(widget.chatId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف جميع الرسائل بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('فشل الحذف: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المحادثة'),
        content: const Text('هل تريد حذف هذه المحادثة بشكل دائم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<MessageProvider>(context, listen: false)
                    .deleteChat(widget.chatId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف المحادثة بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('فشل حذف المحادثة: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
