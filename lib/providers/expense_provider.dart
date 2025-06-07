import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/tag.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

class ExpenseProvider with ChangeNotifier {
  final LocalStorage storage;
  // List of expenses
  List<Expense> _expenses = [];

  // List of categories
  final List<ExpenseCategory> _categories = [
    ExpenseCategory(id: '1', name: 'Food', isDefault: true),
    ExpenseCategory(id: '2', name: 'Transport', isDefault: true),
    ExpenseCategory(id: '3', name: 'Shopping', isDefault: true),
    ExpenseCategory(id: '4', name: 'Groceries', isDefault: true),
    ExpenseCategory(id: '5', name: 'Bills', isDefault: true),
    ExpenseCategory(id: '6', name: 'Entertainment', isDefault: true),
    ExpenseCategory(id: '7', name: 'Salary', isDefault: true), // Added for income
  ];

  // List of tags
  final List<Tag> _tags = [
    Tag(id: '1', name: 'Breakfast'),
    Tag(id: '2', name: 'Lunch'),
    Tag(id: '3', name: 'Dinner'),
    Tag(id: '4', name: 'Treat'),
    Tag(id: '5', name: 'Cafe'),
    Tag(id: '6', name: 'Restaurant'),
    Tag(id: '7', name: 'Train'),
    Tag(id: '8', name: 'Vacation'),
    Tag(id: '9', name: 'Birthday'),
    Tag(id: '10', name: 'Diet'),
    Tag(id: '11', name: 'MovieNight'),
    Tag(id: '12', name: 'Tech'),
    Tag(id: '13', name: 'CarStuff'),
    Tag(id: '14', name: 'SelfCare'),
    Tag(id: '15', name: 'Streaming'),
    Tag(id: '16', name: 'Work'), // Added for income
  ];

  // Getters
  List<Expense> get expenses => _expenses;
  List<ExpenseCategory> get categories => _categories;
  List<Tag> get tags => _tags;

  // --- ADD THIS CALCULATION LOGIC ---

  /// Calculates the current balance (total income minus total expenses).
  double get totalBalance {
    // This simply sums up all transaction amounts.
    // Negative expenses will automatically be subtracted from positive income.
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Calculates the total income by summing up all positive amounts.
  double get totalIncome {
    return _expenses
        .where((exp) => exp.amount > 0)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Calculates total expenses by summing up the absolute value of all negative amounts.
  /// We use .abs() so the UI shows a positive number (e.g., "$284.00").
  double get totalExpenses {
    return _expenses
        .where((exp) => exp.amount < 0)
        .fold(0.0, (sum, item) => sum + item.amount.abs());
  }

  ExpenseProvider(this.storage) {
    _loadExpensesFromStorage();
  }

  void _loadExpensesFromStorage() async {
    // await storage.ready; // Uncomment if your localstorage version needs it
    var storedExpenses = storage.getItem('expenses');
    if (storedExpenses != null) {
      _expenses = List<Expense>.from(
        (storedExpenses as List).map((item) => Expense.fromJson(item)),
      );
      notifyListeners();
    }
  }

  // Add an expense
  void addExpense(Expense expense) {
    _expenses.add(expense);
    _saveExpensesToStorage();
    notifyListeners();
  }

  void _saveExpensesToStorage() {
    storage.setItem(
        'expenses', jsonEncode(_expenses.map((e) => e.toJson()).toList()));
  }

  void addOrUpdateExpense(Expense expense) {
    int index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      // Update existing expense
      _expenses[index] = expense;
    } else {
      // Add new expense
      _expenses.add(expense);
    }
    _saveExpensesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  // Delete an expense
  void deleteExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    _saveExpensesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  // Add a category
  void addCategory(ExpenseCategory category) {
    if (!_categories.any((cat) => cat.name == category.name)) {
      _categories.add(category);
      notifyListeners();
    }
  }

  // Delete a category
  void deleteCategory(String id) {
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
  }

  // Add a tag
  void addTag(Tag tag) {
    if (!_tags.any((t) => t.name == tag.name)) {
      _tags.add(tag);
      notifyListeners();
    }
  }

  // Delete a tag
  void deleteTag(String id) {
    _tags.removeWhere((tag) => tag.id == id);
    notifyListeners();
  }

  void removeExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    _saveExpensesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  ExpenseCategory getCategoryForId(String categoryId) {
    return categories.firstWhere((cat) => cat.id == categoryId, orElse: () => ExpenseCategory(id: 'unknown', name: 'Unknown', isDefault: false));
  }
}