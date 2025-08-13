import 'package:expense_manager/providers/expense_provider.dart';
import 'package:expense_manager/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
                delegate: _SliverAppBarDelegate(
                  _buildTabBar(context),
                  Theme.of(context),
                ),
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

  Widget _buildTabBar(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Transactions', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
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
              unselectedLabelColor: theme.brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black54,
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
    Theme.of(context);
    return RefreshIndicator(
      onRefresh: () => Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).forceRefreshData(),
      child: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final expenses = provider.expenses;
          if (expenses.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  textAlign: TextAlign.center,
                  "No transactions yet. Tap '+' to add one!",
                  style: AppTextStyles.subtitlesStyle,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: expenses.length,
            itemBuilder: (context, index) =>
                _buildTransactionItem(context, provider.sortedExpensesByDate[index]),
          );
        },
      ),
    );
  }

  Widget _buildExpensesByCategory(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () => Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).forceRefreshData(),
      child: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.expenses.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  textAlign: TextAlign.center,
                  "No transactions yet. Tap '+' to add one!",
                  style: AppTextStyles.subtitlesStyle,
                ),
              ),
            );
          }
          final itemsList = provider.getExpensesByCategory;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: itemsList.length,
            itemBuilder: (context, index) {
              final item = itemsList[index];

              if (item is Map) {
                final CategoryTheme categoryTheme =
                    categoryThemes[item['name']] ??
                    defaultCategoryThemes[item['name'].hashCode %
                        defaultCategoryThemes.length];
                return RichText(
                  text: TextSpan(
                    text: toTitleCase(item['name']),
                    style: AppTextStyles.blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: categoryTheme.color,
                    ),
                    children: [
                      if (item['percentage'] > 0)
                        TextSpan(
                          text:
                              ' (${item['percentage'].toStringAsFixed(1)}%${item['percentageLabel']})',
                          style: AppTextStyles.subtitlesStyle.copyWith(
                            color: categoryTheme.color,
                          ),
                        ),
                      TextSpan(
                        text:
                            '${MediaQuery.sizeOf(context).width < 600 ? '\n' : ' - '}Total: \$${item['total'].toStringAsFixed(2)}',
                        style: AppTextStyles.blackTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark
                              ? AppColors.whiteColor
                              : AppColors.blackColor,
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
    final ThemeData theme = Theme.of(context);
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    final bool isDarkMode = theme.brightness == Brightness.dark;
    final bool isIncome = expense.amount > 0;
    final Color incomeColor = isDarkMode
        ? Colors.greenAccent[400]!
        : Colors.green[800]!;
    final Color expenseColor = isDarkMode
        ? Colors.redAccent[200]!
        : Colors.red[700]!;
    final Color amountColor = isIncome ? incomeColor : expenseColor;
    final String amountPrefix = isIncome ? '+' : '-';

    final categoryName = provider.getCategoryForId(expense.categoryId).name;
    final formattedName = toTitleCase(categoryName);
    final IconData icon = categoryIcons[formattedName] ?? Icons.category;
    final CategoryTheme categoryTheme =
        categoryThemes[formattedName] ??
        defaultCategoryThemes[categoryName.hashCode %
            defaultCategoryThemes.length];
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
            backgroundColor: categoryTheme.backgroundColor,
            child: Icon(icon, color: categoryTheme.color),
          ),
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              categoryName,
              style: theme.textTheme.bodySmall!.copyWith(
                color: categoryTheme.color,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
          ),
          subtitle: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formattedDate,
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
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
                style: theme.textTheme.titleLarge!.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
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
  _SliverAppBarDelegate(this._tabBar, this.theme);

  final Widget _tabBar;
  final ThemeData theme;

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
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return oldDelegate.theme != theme;
  }
}
