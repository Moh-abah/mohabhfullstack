import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ain_frontend/views/screens/ChatsMesseg.dart';

import '../../viewmodels/ChatProvider.dart';

class ChatHomeListScreen extends StatelessWidget {
  final int userId;

  ChatHomeListScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(userId: userId),
      child: _ChatHomeListView(),
    );
  }
}

class _ChatHomeListView extends StatefulWidget {
  @override
  _ChatHomeListViewState createState() => _ChatHomeListViewState();
}

class _ChatHomeListViewState extends State<_ChatHomeListView> {
  late ChatProvider chatProvider;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    final primaryColor = provider.primaryColor;
    final accentColor = provider.accentColor;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              ' ${provider.activeChatsCount} محادثة ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          const SizedBox(width: 8),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.8),
                accentColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                  accentColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                _buildChatFilter(context),
                Expanded(child: _buildChatList(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatFilter(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    final filters = ['الكل', 'المتاجر', 'العملاء'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters
              .map((filter) => _buildFilterChip(
                  context,
                  filter,
                  provider.selectedFilter == filter,
                  () => provider.setFilter(filter)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final provider = Provider.of<ChatProvider>(context);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey[100],
        selectedColor: provider.primaryColor,
        onSelected: (bool selected) {
          if (selected) onTap();
        },
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);

    if (provider.isLoading) {
      return _buildLoadingIndicator(context);
    }

    final filteredChats = provider.getFilteredChats();

    return filteredChats.isEmpty
        ? _buildEmptyState(context)
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredChats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              var chat = filteredChats[index];
              return _buildChatItem(context, chat);
            },
          );
  }

  Widget _buildChatItem(BuildContext context, QueryDocumentSnapshot chat) {
    final provider = Provider.of<ChatProvider>(context);
    final primaryColor = provider.primaryColor;
    final userId = provider.userId;

    final isOwner = chat['ownerId'] == userId;
    final otherUserId = isOwner ? chat['customerId'] : chat['ownerId'];

    String formattedTime = 'جارِ التحميل...';
    if (chat['lastMessageTime'] != null) {
      DateTime messageTime = (chat['lastMessageTime'] as Timestamp)
          .toDate(); // تحويل Timestamp إلى DateTime
      formattedTime = DateFormat('h:mm a')
          .format(messageTime); // تنسيق الوقت بتنسيق 12 ساعة (12:30 م)
    }

    return Hero(
      tag: 'chat_${chat.id}',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToChat(context, chat.id),
            borderRadius: BorderRadius.circular(25),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildAvatar(context, isOwner),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FutureBuilder<Map<String, dynamic>?>(
                                future: provider.getOtherUser(otherUserId),
                                builder: (context, snapshot) {
                                  String userName = 'جارِ التحميل...';
                                  if (snapshot.hasData) {
                                    userName = snapshot.data!['name'] ??
                                        'مستخدم غير معروف';
                                  }
                                  return Text(
                                    userName,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                              Text(
                                formattedTime, // عرض الوقت المنسق هنا
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // _buildStatusIndicator(context, chat['status']),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  chat['lastMessage'] ?? 'لا توجد رسائل بعد.',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isOwner) {
    final provider = Provider.of<ChatProvider>(context);
    final primaryColor = provider.primaryColor;
    final accentColor = provider.accentColor;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.8),
            accentColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        isOwner ? Icons.person : Icons.storefront,
        color: Colors.white,
        size: 30,
      ),
    );
  }
  /*


  Widget _buildStatusIndicator(BuildContext context, String status) {
    final isActive = status == 'active';
    final statusColor = isActive ? Colors.green : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isActive ? 'نشطة' : 'مغلقة',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: statusColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  */

  Widget _buildLoadingIndicator(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);

    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(provider.primaryColor),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    final primaryColor = provider.primaryColor;
    final accentColor = provider.accentColor;

    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  accentColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 80,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'لا توجد محادثات بعد',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ابدأ محادثة جديدة مع أي متجر',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
            ),
            child: const Text(
              'استكشف المتاجر',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(BuildContext context, String chatId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatsMesseg(chatId: chatId),
      ),
    ).then((_) {
      // Refresh chats when returning from chat screen
      Provider.of<ChatProvider>(context, listen: false).refreshChats();
    });
  }
}
