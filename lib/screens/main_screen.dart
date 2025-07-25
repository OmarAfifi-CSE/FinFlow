import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../styling/app_assets.dart';
import '../styling/app_colors.dart';
import 'add_expense_sheet.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onPageTapped(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _showAddExpenseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddExpenseSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'FinFlow',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 30),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
          tooltip: 'Open menu',
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primaryColor),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: AppColors.primaryColor),
              title: const Text('Home'),
              onTap: () {
                context.pop();
                _onPageTapped(context, 0); // Go to branch 0
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.category,
                color: AppColors.primaryColor,
              ),
              title: const Text('Manage Categories'),
              onTap: () {
                context.pop();
                _onPageTapped(context, 1); // Go to branch 1
              },
            ),
            ListTile(
              leading: const Icon(Icons.tag, color: AppColors.primaryColor),
              title: const Text('Manage Tags'),
              onTap: () {
                context.pop();
                _onPageTapped(context, 2); // Go to branch 2
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.primaryColor),
              title: const Text('Profile'),
              onTap: () {
                context.pop();
                _onPageTapped(context, 3); // Go to branch 3
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () async {
                context.pop();
                await supabase.auth.signOut();
              },
            ),
          ],
        ),
      ),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex < 2
            ? navigationShell.currentIndex
            : navigationShell.currentIndex + 1,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey[600],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 30,
        onTap: (index) {
          if (index == 2) {
            _showAddExpenseSheet(context);
          } else {
            _onPageTapped(context, index < 2 ? index : index - 1);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppAssets.homeIcon,
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                navigationShell.currentIndex == 0
                    ? AppColors.primaryColor
                    : AppColors.secondaryColor,
                BlendMode.srcIn,
              ),
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: Icon(Icons.add, color: AppColors.primaryColor, size: 20),
              ),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.tag_outlined),
            activeIcon: Icon(Icons.tag),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppAssets.profileIcon,
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                navigationShell.currentIndex == 3
                    ? AppColors.primaryColor
                    : AppColors.secondaryColor,
                BlendMode.srcIn,
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
