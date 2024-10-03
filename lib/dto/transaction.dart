class TransactionDto {
  int? id;
  final String userId;
  final String type;
  final String source;
  final String description;
  final double amount;
  String? attachmentUrl;
  final String txnTime;
  final bool isDeleted;
  final bool isSynced;

  TransactionDto({
    this.id,
    required this.userId,
    required this.type,
    required this.source,
    required this.description,
    required this.amount,
    required this.attachmentUrl,
    required this.txnTime,
    required this.isDeleted,
    required this.isSynced,
  });

  // Converts User object to a map to store in Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'source': source,
      'description': description,
      'amount': amount,
      'attachmentUrl': attachmentUrl,
      'txnTime': txnTime,
      'isDeleted': isDeleted ? 1 : 0,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  Map<String, Object?> toJsonSQL() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'source': source,
      'description': description,
      'amount': amount,
      'attachmentUrl': attachmentUrl,
      'txnTime': txnTime,
      'isDeleted': isDeleted ? 1 : 0,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  static TransactionDto fromJson(Map<String, dynamic> json) {
    return TransactionDto(
        id: json['id'],
        userId: json['userId'],
        type: json['type'],
        source: json['source'],
        description: json['description'],
        amount: json['amount'],
        attachmentUrl: json['attachmentUrl'],
        txnTime: json['txnTime'],
        isDeleted: json['isDeleted'] == 1,
        isSynced: json['isSynced'] == 1);
  }
}
