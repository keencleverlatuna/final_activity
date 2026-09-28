class Email {
  final int id;
  final String sender;
  final String recipient;
  final String subject;
  final String message;
  final String date;
  final bool isRead;

  const Email({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.subject,
    required this.message,
    required this.date,
    required this.isRead,
  });

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      id: int.tryParse(json['id'].toString()) ?? 0,
      sender: json['sender']?.toString() ?? '',
      recipient: json['recipient']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      isRead: json['is_read'].toString() == '1' ||
          json['is_read'].toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'recipient': recipient,
      'subject': subject,
      'message': message,
      'date': date,
      'is_read': isRead ? 1 : 0,
    };
  }

  Email copyWith({
    int? id,
    String? sender,
    String? recipient,
    String? subject,
    String? message,
    String? date,
    bool? isRead,
  }) {
    return Email(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      recipient: recipient ?? this.recipient,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
    );
  }
}