import 'package:expense_manager/screens/tag_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'add_expense_sheet.dart';
import 'category_management_screen.dart';
import '../utils/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// Helper class for the sticky header.
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final Widget _tabBar;

  // The height of the tab bar section
  @override
  double get minExtent => 140;

  @override
  double get maxExtent => 150;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.grey[100], // Match the Scaffold's background color
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  void _onPageTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

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

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePageContent();
      case 1:
        return CategoryManagementScreen();
      case 2:
        return TagManagementScreen();
      default:
        return _buildHomePageContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2E9A91);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      // FIX: Reverted to the original, simple AppBar
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
      // FIX: Reverted to the original, non-conditional Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: primaryColor),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                _onPageTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: primaryColor),
              title: const Text('Manage Categories'),
              onTap: () {
                Navigator.pop(context);
                _onPageTapped(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.tag, color: primaryColor),
              title: const Text('Manage Tags'),
              onTap: () {
                Navigator.pop(context);
                _onPageTapped(2);
              },
            ),
          ],
        ),
      ),
      body: _buildCurrentPage(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => AddExpenseSheet(),
          );
        },
        tooltip: 'Add Transaction',
        backgroundColor: primaryColor,
        elevation: 4.0,
        child: const Icon(Icons.add, size: 30),
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  // --- This is the key fix for scrolling ---
  Widget _buildHomePageContent() {
    final provider = Provider.of<ExpenseProvider>(context);
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        // These are the slivers that will scroll away.
        return <Widget>[
          SliverToBoxAdapter(child: _buildBalanceCard(provider)),
          // This makes the TabBar header stick to the top.
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(_buildTabBar()),
            pinned: true,
          ),
        ];
      },
      // The body is the content of the tabs, which can now scroll freely.
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpensesByDate(context),
          _buildExpensesByCategory(context),
        ],
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      height: 65,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildNavItem(icon: Icons.home, index: 0)],
            ),
          ),
          const SizedBox(width: 60),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(icon: Icons.category, index: 1),
                _buildNavItem(icon: Icons.tag, index: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    return InkWell(
      onTap: () => _onPageTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: _selectedIndex == index
                  ? const Color(0xFF2E9A91)
                  : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(ExpenseProvider provider) {
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
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${provider.totalBalance.toStringAsFixed(2)}',
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
                  '\$${provider.totalIncome.toStringAsFixed(2)}',
                  Icons.arrow_downward,
                ),
                _buildIncomeExpense(
                  'Expenses',
                  '\$${provider.totalExpenses.toStringAsFixed(2)}',
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
                color: Colors.white.withValues(alpha: 0.8),
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
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              labelColor: Colors.white,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: sortedExpenses.length,
          itemBuilder: (context, index) =>
              _buildTransactionItem(context, sortedExpenses[index]),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                ...entry.value.map(
                  (expense) => _buildTransactionItem(context, expense),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

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
    final Color amountColor = isIncome ? Colors.green[700]! : Colors.red;
    final String amountPrefix = isIncome ? '+' : '-';

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => AddExpenseSheet(expense: expense),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 8),
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
