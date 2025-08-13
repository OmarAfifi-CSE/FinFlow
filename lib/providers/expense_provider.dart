import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/tag.dart';
import '../main.dart';
import 'deleted_category_data.dart'; // To get the global 'supabase' client

const uuid = Uuid();

class ExpenseProvider with ChangeNotifier {
  bool _isLoading = true;
  bool _isDataLoaded = false;

  bool get isLoading => _isLoading;

  bool get isDataLoaded => _isDataLoaded;

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

  List<Expense> get sortedExpensesByDate {
    final sorted = List<Expense>.from(_expenses);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  List<dynamic> get getExpensesByCategory {
    if (_expenses.isEmpty) return [];

    final grouped = groupBy(sortedExpensesByDate, (Expense e) => e.categoryId);

    final List<dynamic> itemsList = [];
    for (var entry in grouped.entries) {
      final categoryName = getCategoryForId(entry.key).name;
      final total = entry.value.fold(
        0.0,
        (prev, Expense element) => prev + element.amount,
      );

      double percentage = 0.0;
      String percentageLabel = '';

      if (total > 0) {
        final double categoryIncomeTotal = entry.value
            .where((e) => e.amount > 0)
            .fold(0.0, (sum, e) => sum + e.amount);

        if (totalIncome > 0) {
          percentage = (categoryIncomeTotal / totalIncome) * 100;
          percentageLabel = ' of income';
        }
      } else if (total < 0) {
        final double categoryExpenseTotal = entry.value
            .where((e) => e.amount < 0)
            .fold(0.0, (sum, e) => sum + e.amount.abs());

        if (totalExpenses > 0) {
          percentage = (categoryExpenseTotal / totalExpenses) * 100;
          percentageLabel = ' of expenses';
        }
      }

      itemsList.add({
        'name': categoryName,
        'total': total,
        'percentage': percentage,
        'percentageLabel': percentageLabel,
      });
      itemsList.addAll(entry.value);
    }
    return itemsList;
  }

  // --- Data Fetching from Supabase ---
  Future<void> fetchInitialData() async {
    if (_isDataLoaded) {
      return;
    }
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

      _isDataLoaded = true;

      if (_categories.isEmpty) await _addDefaultCategories(userId);
      if (_tags.isEmpty) await _addDefaultTags(userId);
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> forceRefreshData() async {
    _isDataLoaded = false;
    await fetchInitialData();
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

    final newCategory = ExpenseCategory(id: uuid.v4(), name: name);

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

  Future<DeletedCategoryData?> deleteCategory(String id) async {
    final categoryToDelete = _categories.firstWhereOrNull(
      (cat) => cat.id == id,
    );
    if (categoryToDelete == null) {
      return null;
    }
    final relatedExpenses = _expenses
        .where((exp) => exp.categoryId == id)
        .toList();
    _categories.removeWhere((category) => category.id == id);
    _expenses.removeWhere((expense) => expense.categoryId == id);
    notifyListeners();
    try {
      await supabase.from('categories').delete().eq('id', id);
    } catch (e) {
      debugPrint("Error deleting category, re-fetching to sync state: $e");
      await fetchInitialData();
    }
    return DeletedCategoryData(categoryToDelete, relatedExpenses);
  }

  Future<void> undoDeleteCategory(DeletedCategoryData deletedData) async {
    final categoryMap = deletedData.category.toJson();
    categoryMap['user_id'] = supabase.auth.currentUser!.id;
    await supabase.from('categories').upsert(categoryMap);
    if (deletedData.relatedExpenses.isNotEmpty) {
      final expenseMaps = deletedData.relatedExpenses.map((e) {
        final map = e.toJson();
        map['user_id'] = supabase.auth.currentUser!.id;
        return map;
      }).toList();
      await supabase.from('expenses').upsert(expenseMaps);
    }
    _isDataLoaded = false;
    await fetchInitialData();
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
      orElse: () => ExpenseCategory(id: 'unknown', name: 'Unknown'),
    );
  }

  Future<void> _addDefaultCategories(String userId) async {
    final List<Map<String, dynamic>> defaultCategories = [
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Food'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Transport'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Shopping'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Groceries'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Bills'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Entertainment'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Health'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Travel'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Education'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Gifts'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Family'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Pets'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Home'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Investments'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Business'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Salary'},
      {'id': uuid.v4(), 'user_id': userId, 'name': 'Savings'},
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
