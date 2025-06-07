import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'dart:math'; // Imported for the hash code logic

import '../providers/expense_provider.dart';
import '../screens/add_expense_screen.dart';
import '../models/expense.dart';
import 'add_expense_sheet.dart';

// A simple class to hold the color theme for a category
class CategoryTheme {
  final Color color;
  final Color backgroundColor;

  const CategoryTheme({required this.color, required this.backgroundColor});
}

// Mapping of category names to their specific icons
const Map<String, IconData> categoryIcons = {
  'Food': Icons.fastfood,
  'Transport': Icons.emoji_transportation,
  'Shopping': Icons.shopping_bag,
  'Groceries': Icons.local_grocery_store,
  'Bills': Icons.receipt,
  'Entertainment': Icons.movie,
};

// --- Main themes for specific, hardcoded categories ---
final Map<String, CategoryTheme> categoryThemes = {
  'Food': CategoryTheme(color: Colors.red[400]!, backgroundColor: Colors.red[50]!),
  'Transport': CategoryTheme(color: Colors.orange[400]!, backgroundColor: Colors.orange[50]!),
  'Shopping': CategoryTheme(color: Colors.green[600]!, backgroundColor: Colors.green[50]!),
  'Groceries': CategoryTheme(color: Colors.blue[400]!, backgroundColor: Colors.blue[50]!),
  'Bills': CategoryTheme(color: Colors.purple[400]!, backgroundColor: Colors.purple[50]!),
  'Entertainment': CategoryTheme(color: Colors.teal[400]!, backgroundColor: Colors.teal[50]!),
};

// --- NEW: A list of default themes for any new categories ---
// We will pick from this list using the category name's hash code.
final List<CategoryTheme> defaultCategoryThemes = [
  CategoryTheme(color: Colors.teal[400]!, backgroundColor: Colors.teal[50]!),
  CategoryTheme(color: Colors.lightBlue[600]!, backgroundColor: Colors.lightBlue[50]!),
  CategoryTheme(color: Colors.pink[400]!, backgroundColor: Colors.pink[50]!),
  CategoryTheme(color: Colors.amber[700]!, backgroundColor: Colors.amber[50]!),
  CategoryTheme(color: Colors.indigo[400]!, backgroundColor: Colors.indigo[50]!),
  CategoryTheme(color: Colors.brown[400]!, backgroundColor: Colors.brown[50]!),
  CategoryTheme(color: Colors.cyan[600]!, backgroundColor: Colors.cyan[50]!),
];


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2E9A91);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.category, color: primaryColor),
              title: Text('Manage Categories'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manage_categories');
              },
            ),
            ListTile(
              leading: Icon(Icons.tag, color: primaryColor),
              title: Text('Manage Tags'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manage_tags');
              },
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          SliverToBoxAdapter(
            child: _buildTabBar(),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExpensesByDate(context),
                _buildExpensesByCategory(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // This is the new way to open the sheet.
          showModalBottomSheet(
            context: context,
            // This makes the sheet scrollable and avoids the keyboard covering the fields.
            isScrollControlled: true,
            // This gives the sheet the rounded top corners.
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              // Here we build our new sheet widget.
              return AddExpenseSheet();
            },
          );
        },
        tooltip: 'Add Expense',
        child: Icon(Icons.add, size: 30),
        backgroundColor: const Color(0xFF2E9A91),
        elevation: 4.0,
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Dummy data for display purposes
    final totalBalance = 1000;
    final totalIncome = 100;
    final totalExpenses = 200;

    return Container(
      padding: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0, bottom: 20.0),
      decoration: const BoxDecoration(
        color: Color(0xFF2E9A91),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                tooltip: 'Open menu',
              ),
              const Icon(Icons.more_horiz, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF38A39A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Balance',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${totalBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIncomeExpense('Income', '\$${totalIncome.toStringAsFixed(2)}', Icons.arrow_downward),
                    _buildIncomeExpense('Expenses', '\$${totalExpenses.toStringAsFixed(2)}', Icons.arrow_upward),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIncomeExpense(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
            ),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Color(0xFF2E9A91),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(text: "By Date"),
          Tab(text: "By Category"),
        ],
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home, color: Color(0xFF2E9A91)),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.bar_chart, color: Colors.grey),
              onPressed: () {},
            ),
            SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.account_balance_wallet, color: Colors.grey),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.grey),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesByDate(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        if (provider.expenses.isEmpty) {
          return Center(
            child: Text(
              "No transactions yet. Tap '+' to add one!",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: provider.expenses.length,
          itemBuilder: (context, index) {
            final expense = provider.expenses[index];
            return _buildTransactionItem(context, expense);
          },
        );
      },
    );
  }

  Widget _buildExpensesByCategory(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        if (provider.expenses.isEmpty) {
          return Center(
            child: Text(
              "No transactions yet. Tap '+' to add one!",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          );
        }
        var grouped = groupBy(provider.expenses, (Expense e) => e.categoryId);
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: grouped.entries.map((entry) {
            String categoryName = getCategoryNameById(context, entry.key);
            double total = entry.value.fold(
                0.0, (double prev, Expense element) => prev + element.amount);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                  child: Text(
                    "$categoryName - Total: \$${total.abs().toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                ...entry.value.map((expense) => _buildTransactionItem(context, expense)).toList(),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  // --- WIDGET UPDATED WITH NEW LOGIC FOR RANDOM COLORS ---
  Widget _buildTransactionItem(BuildContext context, Expense expense) {
    String categoryName = getCategoryNameById(context, expense.categoryId);
    IconData icon = categoryIcons[categoryName] ?? Icons.category; // A generic fallback icon

    // Get the category-specific theme.
    CategoryTheme theme = categoryThemes[categoryName] ??
        // If not found, use the HASHING method to pick a consistent "random" color.
        defaultCategoryThemes[categoryName.hashCode % defaultCategoryThemes.length];

    String formattedDate = DateFormat('MMM d, yyyy').format(expense.date);

    // expense
    Color amountColor = Colors.red;
    String amountPrefix = '-';

    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.backgroundColor, // Use background color from theme
          child: Icon(icon, color: theme.color),   // Use main color from theme
        ),
        title: Text(
          categoryName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(formattedDate),
        trailing: Text(
          '$amountPrefix \$${expense.amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: amountColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String getCategoryNameById(BuildContext context, String categoryId) {
    try {
      var category = Provider.of<ExpenseProvider>(context, listen: false)
          .categories
          .firstWhere((cat) => cat.id == categoryId);
      return category.name;
    } catch (e) {
      return "Unknown Category";
    }
  }
}