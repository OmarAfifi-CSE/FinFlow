import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../providers/expense_provider.dart';
import '../screens/add_expense_screen.dart';
import '../models/expense.dart';

// Mapping of category names to specific icons.
const Map<String, IconData> categoryIcons = {
  'Food': Icons.fastfood,
  'Travel': Icons.emoji_transportation,
  'Shopping': Icons.shopping_bag,
  'Groceries': Icons.local_grocery_store,
  'Bills': Icons.receipt,
  'Entertainment': Icons.movie,
};

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
      key: _scaffoldKey, // Add scaffold key to open drawer
      backgroundColor: Colors.grey[100],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: primaryColor), // Corrected color
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.category, color: primaryColor), // Corrected color
              title: Text('Manage Categories'),
              onTap: () {
                Navigator.pop(context); // Closes the drawer
                Navigator.pushNamed(context, '/manage_categories');
              },
            ),
            ListTile(
              leading: Icon(Icons.tag, color: primaryColor), // Corrected color
              title: Text('Manage Tags'),
              onTap: () {
                Navigator.pop(context); // Closes the drawer
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddExpenseScreen()),
        ),
        tooltip: 'Add Expense',
        child: Icon(Icons.add, size: 30),
        backgroundColor: primaryColor,
        elevation: 4.0,
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  /// Builds the top header section with the new user-provided design.
  Widget _buildHeader(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    // Using dummy data as in your provided code
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
          // FIX: The Row containing the drawer icon was missing. It is added back here.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                onPressed: () {
                  // This line opens the drawer.
                  _scaffoldKey.currentState?.openDrawer();
                },
                tooltip: 'Open menu',
              ),
              const Icon(Icons.more_horiz, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 10),
          // Rest of your header code remains the same
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF38A39A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
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

  /// Helper widget to build the Income/Expense section in the header.
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

  /// Builds the tab bar for switching between views.
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

  /// Builds the bottom app bar with navigation icons.
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
            SizedBox(width: 40), // The space for the FAB
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

  /// Builds the list of expenses sorted by date.
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

  /// Builds the list of expenses grouped by category.
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

  /// Builds a single transaction list item.
  Widget _buildTransactionItem(BuildContext context, Expense expense) {
    String categoryName = getCategoryNameById(context, expense.categoryId);
    IconData icon = categoryIcons[categoryName] ?? Icons.category;
    bool isIncome = expense.amount > 0;
    String formattedDate = DateFormat('MMM d, yyyy').format(expense.date);
    Color amountColor = isIncome ? Colors.green : Colors.black;
    String amountPrefix = isIncome ? '+' : '-';

    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(icon, color: Color(0xFF2E9A91)),
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