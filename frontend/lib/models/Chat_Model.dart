class FinalChatListRun {
  final String chatId;
  final String storeName;
  final List<String> storeImage;
  final String? lastMessage;
  final bool isActive;
  final OtherUser otherUser;

  FinalChatListRun({
    required this.chatId,
    required this.storeName,
    required this.storeImage,
    this.lastMessage,
    required this.isActive,
    required this.otherUser,
  });

  // لتحويل JSON إلى كائن من النوع FinalChatListRun
  factory FinalChatListRun.fromJson(Map<String, dynamic> json) {
    return FinalChatListRun(
      chatId: json['chat_id'],
      storeName: json['store_name'],
      storeImage: List<String>.from(json['store_image']),
      lastMessage: json['last_message'],
      isActive: json['is_active'],
      otherUser: OtherUser.fromJson(json['other_user']),
    );
  }

  // لتحويل كائن FinalChatListRun إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'store_name': storeName,
      'store_image': storeImage,
      'last_message': lastMessage,
      'is_active': isActive,
      'other_user': otherUser.toJson(),
    };
  }
}

class OtherUser {
  final int id;
  final String name;

  OtherUser({
    required this.id,
    required this.name,
  });

  // لتحويل JSON إلى كائن من النوع OtherUser
  factory OtherUser.fromJson(Map<String, dynamic> json) {
    return OtherUser(
      id: json['id'],
      name: json['name'],
    );
  }

  // لتحويل كائن OtherUser إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
