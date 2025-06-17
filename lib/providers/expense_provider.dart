import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/tag.dart';

class ExpenseProvider with ChangeNotifier {
  final SharedPreferences prefs;

  // --- Data Lists ---
  List<Expense> _expenses = [];
  List<ExpenseCategory> _categories = [];
  List<Tag> _tags = [];

  // --- Default Data (for first-time app run) ---
  final List<ExpenseCategory> _defaultCategories = [
    ExpenseCategory(id: '1', name: 'Food', isDefault: true),
    ExpenseCategory(id: '2', name: 'Transport', isDefault: true),
    ExpenseCategory(id: '3', name: 'Shopping', isDefault: true),
    ExpenseCategory(id: '4', name: 'Groceries', isDefault: true),
    ExpenseCategory(id: '5', name: 'Bills', isDefault: true),
    ExpenseCategory(id: '6', name: 'Entertainment', isDefault: true),
    ExpenseCategory(id: '7', name: 'Salary', isDefault: true),
  ];

  final List<Tag> _defaultTags = [
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
    Tag(id: '16', name: 'Work'),
  ];

  // --- Getters ---
  List<Expense> get expenses => _expenses;

  List<ExpenseCategory> get categories => _categories;

  List<Tag> get tags => _tags;

  double get totalBalance =>
      _expenses.fold(0.0, (sum, item) => sum + item.amount);

  double get totalIncome => _expenses
      .where((e) => e.amount > 0)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpenses => _expenses
      .where((e) => e.amount < 0)
      .fold(0.0, (sum, e) => sum + e.amount.abs());

  // --- Constructor ---
  ExpenseProvider(this.prefs) {
    _loadDataFromStorage();
  }

  // --- Initialization Logic ---
  void _loadDataFromStorage() {
    // Load Expenses
    final expensesData = prefs.getString('expenses_list');
    if (expensesData != null) {
      final List<dynamic> decoded = jsonDecode(expensesData);
      _expenses = decoded.map((item) => Expense.fromJson(item)).toList();
    }

    // Load Categories (Defaults + User-Added)
    _categories = List.from(_defaultCategories); // Start with defaults
    final categoriesData = prefs.getString('user_categories');
    if (categoriesData != null) {
      final List<dynamic> decoded = jsonDecode(categoriesData);
      _categories.addAll(decoded.map((item) => ExpenseCategory.fromJson(item)));
    }

    // Load Tags (Defaults + User-Added)
    _tags = List.from(_defaultTags); // Start with defaults
    final tagsData = prefs.getString('user_tags');
    if (tagsData != null) {
      final List<dynamic> decoded = jsonDecode(tagsData);
      _tags.addAll(decoded.map((item) => Tag.fromJson(item)));
    }

    notifyListeners();
  }

  // --- Save Methods ---
  Future<void> _saveExpenses() async {
    await prefs.setString(
      'expenses_list',
      jsonEncode(_expenses.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _saveCategories() async {
    final userCategories = _categories
        .where((cat) => cat.isDefault != true)
        .toList();
    await prefs.setString(
      'user_categories',
      jsonEncode(userCategories.map((c) => c.toJson()).toList()),
    );
  }

  Future<void> _saveTags() async {
    final defaultTagNames = _defaultTags.map((t) => t.name).toSet();
    final userTags = _tags
        .where((tag) => !defaultTagNames.contains(tag.name))
        .toList();
    await prefs.setString(
      'user_tags',
      jsonEncode(userTags.map((t) => t.toJson()).toList()),
    );
  }

  // --- CRUD Operations ---

  void addOrUpdateExpense(Expense expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
    } else {
      _expenses.add(expense);
    }
    _saveExpenses();
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    _saveExpenses();
    notifyListeners();
  }

  void addCategory(ExpenseCategory category) {
    if (!_categories.any(
      (cat) => cat.name.toLowerCase() == category.name.toLowerCase(),
    )) {
      _categories.add(category);
      _saveCategories();
      notifyListeners();
    }
  }

  void deleteCategory(String id) {
    final categoryToDelete = _categories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => ExpenseCategory(id: '', name: ''),
    );
    if (categoryToDelete.isDefault == true)
      return; // Prevent deleting default categories

    _categories.removeWhere((category) => category.id == id);
    _saveCategories();
    notifyListeners();
  }

  void addTag(Tag tag) {
    if (!_tags.any((t) => t.name.toLowerCase() == tag.name.toLowerCase())) {
      _tags.add(tag);
      _saveTags();
      notifyListeners();
    }
  }

  void deleteTag(String id) {
    _tags.removeWhere((tag) => tag.id == id);
    _saveTags();
    notifyListeners();
  }

  ExpenseCategory getCategoryForId(String categoryId) {
    return categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => ExpenseCategory(id: 'unknown', name: 'Unknown'),
    );
  }
}
