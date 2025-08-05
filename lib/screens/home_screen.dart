import 'package:expense_manager/providers/expense_provider.dart';
import 'package:expense_manager/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../models/expense.dart';
import '../styling/app_colors.dart';
import '../styling/app_text_styles.dart';
import 'add_expense_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && !provider.isDataLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        return NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(child: _buildBalanceCard(provider)),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(_buildTabBar()),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildExpensesByDate(context),
              _buildExpensesByCategory(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(ExpenseProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryColorShade,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Balance', style: AppTextStyles.cardSubtitlesStyle),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '\$${provider.totalBalance.toStringAsFixed(2)}',
                style: AppTextStyles.cardPrimaryTextStyle,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 16,
              children: [
                Expanded(
                  child: _buildIncomeExpense(
                    'Income',
                    '\$${provider.totalIncome.toStringAsFixed(2)}',
                    Icons.arrow_downward,
                  ),
                ),
                Expanded(
                  child: _buildIncomeExpense(
                    'Expenses',
                    '\$${provider.totalExpenses.toStringAsFixed(2)}',
                    Icons.arrow_upward,
                    alignRight: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpense(
    String title,
    String value,
    IconData icon, {
    alignRight = false,
  }) {
    return Row(
      mainAxisAlignment: alignRight
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.cardSubtitlesStyle.copyWith(fontSize: 14),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: AppTextStyles.cardPrimaryTextStyle.copyWith(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: AppTextStyles.blackTextStyle.copyWith(
              fontWeight: FontWeight.bold,
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
                color: AppColors.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
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
    return RefreshIndicator(
      onRefresh: () => Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).forceRefreshData(),
      child: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.expenses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  textAlign: TextAlign.center,
                  "No transactions yet. Tap '+' to add one!",
                  style: AppTextStyles.subtitlesStyle,
                ),
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
      ),
    );
  }

  Widget _buildExpensesByCategory(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).forceRefreshData(),
      child: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.expenses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  textAlign: TextAlign.center,
                  "No transactions yet. Tap '+' to add one!",
                  style: AppTextStyles.subtitlesStyle,
                ),
              ),
            );
          }
          final sortedExpenses = List<Expense>.from(provider.expenses)
            ..sort((a, b) => b.date.compareTo(a.date));
          final grouped = groupBy(sortedExpenses, (Expense e) => e.categoryId);

          final double grandTotalIncome = provider.totalIncome;
          final double grandTotalExpenses = provider.totalExpenses;

          final List<dynamic> itemsList = [];
          for (var entry in grouped.entries) {
            final categoryName = provider.getCategoryForId(entry.key).name;
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

              if (grandTotalIncome > 0) {
                percentage = (categoryIncomeTotal / grandTotalIncome) * 100;
                percentageLabel = ' of income';
              }
            } else if (total < 0) {
              final double categoryExpenseTotal = entry.value
                  .where((e) => e.amount < 0)
                  .fold(0.0, (sum, e) => sum + e.amount.abs());

              if (grandTotalExpenses > 0) {
                percentage = (categoryExpenseTotal / grandTotalExpenses) * 100;
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

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: itemsList.length,
            itemBuilder: (context, index) {
              final item = itemsList[index];

              if (item is Map) {
                final CategoryTheme theme =
                    categoryThemes[item['name']] ??
                    defaultCategoryThemes[item['name'].hashCode %
                        defaultCategoryThemes.length];
                return RichText(
                  text: TextSpan(
                    text: toTitleCase(item['name']),
                    style: AppTextStyles.blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.color,
                    ),
                    children: [
                      if (item['percentage'] > 0)
                        TextSpan(
                          text: ' (${item['percentage'].toStringAsFixed(1)}%${item['percentageLabel']})',
                          style: AppTextStyles.subtitlesStyle.copyWith(
                            color: theme.color,
                          ),
                        ),
                      TextSpan(
                        text: '${MediaQuery.sizeOf(context).width < 600? '\n':' - '}Total: \$${item['total'].toStringAsFixed(2)}',
                        style: AppTextStyles.blackTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return _buildTransactionItem(context, item as Expense);
              }
            },
          );
        },
      ),
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
    final String formattedDate = DateFormat.yMMMd().format(expense.date);
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: Scaffold.of(context).context,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: CircleAvatar(
            backgroundColor: theme.backgroundColor,
            child: Icon(icon, color: theme.color),
          ),
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(categoryName, style: TextStyle(color: theme.color)),
          ),
          subtitle: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(formattedDate),
          ),
          trailing: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.3,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '$amountPrefix \$${expense.amount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final Widget _tabBar;

  @override
  double get minExtent => 135;

  @override
  double get maxExtent => 135;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.grey[100], child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
