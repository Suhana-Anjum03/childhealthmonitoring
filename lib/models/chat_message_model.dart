class ChatMessageModel {
  final int? id;
  final int senderId;
  final int receiverId;
  final String senderRole; // 'doctor' or 'parent'
  final String message;
  final DateTime sentAt;
  final bool isRead;

  ChatMessageModel({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderRole,
    required this.message,
    DateTime? sentAt,
    this.isRead = false,
  }) : sentAt = sentAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'sender_role': senderRole,
      'message': message,
      'sent_at': sentAt.toIso8601String(),
      'is_read': isRead ? 1 : 0,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] as int?,
      senderId: map['sender_id'] as int,
      receiverId: map['receiver_id'] as int,
      senderRole: map['sender_role'] as String,
      message: map['message'] as String,
      sentAt: DateTime.parse(map['sent_at'] as String),
      isRead: map['is_read'] == 1,
    );
  }

  ChatMessageModel copyWith({
    int? id,
    int? senderId,
    int? receiverId,
    String? senderRole,
    String? message,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderRole: senderRole ?? this.senderRole,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
