import 'package:expense_manager/screens/tag_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

// Removed all the redundant constant maps and classes.

import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'add_expense_sheet.dart';
import 'category_management_screen.dart'; // Import the category screen
import '../utils/app_constants.dart'; // <-- Import our single source of truth

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
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'FinFlow',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 30),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          tooltip: 'Open menu',
        ),
      ),
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
                Navigator.pop(context); // Close the drawer
                // Navigate to the Category Management Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.tag, color: primaryColor),
              title: Text('Manage Tags'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to the Tag Management Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TagManagementScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildBalanceCard(context)),
          SliverToBoxAdapter(child: _buildTabBar()),
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
        shape: CircleBorder(),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return AddExpenseSheet();
            },
          );
        },
        tooltip: 'Add Transaction',
        child: Icon(Icons.add, size: 30),
        backgroundColor: const Color(0xFF2E9A91),
        elevation: 4.0,
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final totalBalance = provider.totalBalance;
    final totalIncome = provider.totalIncome;
    final totalExpenses = provider.totalExpenses;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2E9A91),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Container(
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
                _buildIncomeExpense(
                  'Income',
                  '\$${totalIncome.toStringAsFixed(2)}',
                  Icons.arrow_downward,
                ),
                _buildIncomeExpense(
                  'Expenses',
                  '\$${totalExpenses.toStringAsFixed(2)}',
                  Icons.arrow_upward,
                ),
              ],
            ),
          ],
        ),
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
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    const primaryColor = Color(0xFF2E9A91);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorPadding: const EdgeInsets.all(5.0),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              labelColor: Colors.white,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelColor: Colors.black54,
              tabs: const [
                Tab(text: "By Date"),
                Tab(text: "By Category"),
              ],
            ),
          ),
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
        final sortedExpenses = provider.expenses
          ..sort((a, b) => b.date.compareTo(a.date));
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: sortedExpenses.length,
          itemBuilder: (context, index) {
            final expense = sortedExpenses[index];
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
            String categoryName = provider.getCategoryForId(entry.key).name;
            double total = entry.value.fold(
              0.0,
              (double prev, Expense element) => prev + element.amount,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 8.0,
                  ),
                  child: Text(
                    "$categoryName - Total: \$${total.abs().toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                ...entry.value
                    .map((expense) => _buildTransactionItem(context, expense))
                    .toList(),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  // --- WIDGET UPDATED TO BE TAPPABLE FOR EDITING ---
  Widget _buildTransactionItem(BuildContext context, Expense expense) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final categoryName = provider.getCategoryForId(expense.categoryId).name;

    final formattedName = toTitleCase(categoryName);

    final IconData icon = categoryIcons[formattedName] ?? Icons.category;
    final CategoryTheme theme =
        categoryThemes[formattedName] ??
        defaultCategoryThemes[categoryName.hashCode %
            defaultCategoryThemes.length];

    final bool isIncome = expense.amount > 0;
    final String formattedDate = DateFormat.yMMMd().format(expense.date);

    final Color amountColor = isIncome ? Colors.green[700]! : Colors.red;
    final String amountPrefix = isIncome ? '+' : '-';

    // --- WRAPPED IN INKWELL TO MAKE TAPPABLE FOR EDITING ---
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            // Pass the specific expense to the sheet for editing
            return AddExpenseSheet(expense: expense);
          },
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.backgroundColor,
            child: Icon(icon, color: theme.color),
          ),
          title: Text(categoryName),
          trailing: Text(
            '$amountPrefix \$${expense.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: amountColor,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
