import '../models/expense.dart';
import '../models/expense_category.dart';

class DeletedCategoryData {
  final ExpenseCategory category;
  final List<Expense> relatedExpenses;
  DeletedCategoryData(this.category, this.relatedExpenses);
}