class Expense {
  final String id;
  final double amount;
  final String categoryId;
  final String note;
  final DateTime date;
  final String? tag;

  Expense({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.note,
    required this.date,
    this.tag,
  });

  // Convert a JSON object to an Expense instance
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category_id'],
      note: json['description'],
      date: DateTime.parse(json['date']),
      tag: json['tag_id'],
    );
  }

  // Convert an Expense instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category_id': categoryId,
      'description': note,
      'date': date.toIso8601String(),
      'tag_id': tag,
    };
  }
}
