import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/tag.dart';
import '../main.dart'; // To get the global 'supabase' client

const uuid = Uuid();

class ExpenseProvider with ChangeNotifier {
  // --- State Management ---
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  // --- Data Lists ---
  List<Expense> _expenses = [];
  List<ExpenseCategory> _categories = [];
  List<Tag> _tags = [];

  // --- Public Getters ---
  List<Expense> get expenses => _expenses;

  List<ExpenseCategory> get categories => _categories;

  List<Tag> get tags => _tags;

  // --- Calculated Getters ---
  double get totalBalance =>
      _expenses.fold(0.0, (sum, item) => sum + item.amount);

  double get totalIncome => _expenses
      .where((e) => e.amount > 0)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpenses => _expenses
      .where((e) => e.amount < 0)
      .fold(0.0, (sum, e) => sum + e.amount.abs());

  // --- Data Fetching from Supabase ---
  Future<void> fetchInitialData() async {
    _isLoading = true;
    Future.delayed(Duration.zero, () => notifyListeners());

    try {
      final userId = supabase.auth.currentUser!.id;

      final results = await Future.wait([
        supabase.from('expenses').select().eq('user_id', userId),
        supabase.from('categories').select().eq('user_id', userId),
        supabase.from('tags').select().eq('user_id', userId),
      ]);

      _expenses = (results[0] as List)
          .map((item) => Expense.fromJson(item))
          .toList();
      _categories = (results[1] as List)
          .map((item) => ExpenseCategory.fromJson(item))
          .toList();
      _tags = (results[2] as List).map((item) => Tag.fromJson(item)).toList();

      if (_categories.isEmpty) await _addDefaultCategories(userId);
      if (_tags.isEmpty) await _addDefaultTags(userId);
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- CRUD Operations ---

  Future<void> addOrUpdateExpense(Expense expense) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final expenseMap = expense.toJson();
    expenseMap['user_id'] = user.id;

    final savedData = await supabase
        .from('expenses')
        .upsert(expenseMap)
        .select()
        .single();
    final savedExpense = Expense.fromJson(savedData);

    final index = _expenses.indexWhere((e) => e.id == savedExpense.id);
    if (index != -1) {
      _expenses[index] = savedExpense;
    } else {
      _expenses.insert(0, savedExpense);
    }
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();

    try {
      await supabase.from('expenses').delete().eq('id', id);
    } catch (e) {
      debugPrint("Error deleting expense, re-fetching to sync state: $e");
      await fetchInitialData();
    }
  }

  Future<ExpenseCategory?> addCategory(
    String name, {
    bool isDefault = false,
  }) async {
    if (_categories.any(
      (cat) => cat.name.toLowerCase() == name.toLowerCase(),
    )) {
      debugPrint('Category with this name already exists locally.');
      return null;
    }

    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final newCategory = ExpenseCategory(
      id: uuid.v4(),
      name: name,
      isDefault: isDefault,
    );

    final categoryMap = newCategory.toJson();
    categoryMap['user_id'] = user.id;

    try {
      final savedData = await supabase
          .from('categories')
          .insert(categoryMap)
          .select()
          .single();
      final savedCategory = ExpenseCategory.fromJson(savedData);

      _categories.add(savedCategory);
      notifyListeners();
      return savedCategory;
    } on PostgrestException catch (e) {
      debugPrint("Error adding category: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("An unexpected error occurred: $e");
      return null;
    }
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
    try {
      await supabase.from('categories').delete().eq('id', id);
    } catch (e) {
      debugPrint("Error deleting category, re-fetching to sync state: $e");
      await fetchInitialData();
    }
  }

  Future<Tag?> addTag(String name) async {
    if (_tags.any((tag) => tag.name.toLowerCase() == name.toLowerCase())) {
      debugPrint('Tag with this name already exists locally.');
      return null;
    }
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final newTag = Tag(id: uuid.v4(), name: name);
    final tagMap = newTag.toJson();
    tagMap['user_id'] = user.id;

    try {
      final savedData = await supabase
          .from('tags')
          .insert(tagMap)
          .select()
          .single();
      final savedTag = Tag.fromJson(savedData);

      _tags.add(savedTag);
      notifyListeners();
      return savedTag;
    } on PostgrestException catch (e) {
      debugPrint("Error adding tag: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("An unexpected error occurred: $e");
      return null;
    }
  }

  Future<void> deleteTag(String id) async {
    _tags.removeWhere((tag) => tag.id == id);
    notifyListeners();
    try {
      await supabase.from('tags').delete().eq('id', id);
    } catch (e) {
      debugPrint("Error deleting tag, re-fetching to sync state: $e");
      await fetchInitialData();
    }
  }

  // --- Helper and Default Data functions ---
  ExpenseCategory getCategoryForId(String categoryId) {
    return categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () =>
          ExpenseCategory(id: 'unknown', name: 'Unknown', isDefault: false),
    );
  }

  Future<void> _addDefaultCategories(String userId) async {
    final List<Map<String, dynamic>> defaultCategories = [
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Food', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Transport', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Shopping', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Groceries', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Bills', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Entertainment', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Health', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Travel', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Education', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Gifts', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Family', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Pets', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Home', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Investments', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Business', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Salary', 'is_default': true},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Savings', 'is_default': true},
    ];
    await supabase.from('categories').insert(defaultCategories);
    await fetchInitialData();
  }

  Future<void> _addDefaultTags(String userId) async {
    final List<Map<String, dynamic>> defaultTags = [
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Breakfast'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Lunch'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Dinner'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Treat'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Cafe'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Restaurant'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Train'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Vacation'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Self Care'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Car Stuff'},
    ];
    await supabase.from('tags').insert(defaultTags);
    await fetchInitialData();
  }
}
