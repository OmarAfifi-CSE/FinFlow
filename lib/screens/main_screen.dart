import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import 'add_expense_sheet.dart';

// HomeScreen now acts as the UI "Shell"
class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onPageTapped(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2E9A91);
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
        backgroundColor: primaryColor,
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
                _onPageTapped(context, 0); // Go to branch 0
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: primaryColor),
              title: const Text('Manage Categories'),
              onTap: () {
                Navigator.pop(context);
                _onPageTapped(context, 1); // Go to branch 1
              },
            ),
            ListTile(
              leading: const Icon(Icons.tag, color: primaryColor),
              title: const Text('Manage Tags'),
              onTap: () {
                Navigator.pop(context);
                _onPageTapped(context, 2); // Go to branch 2
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: primaryColor),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _onPageTapped(context, 3); // Go to branch 3
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await supabase.auth.signOut();
                // Router will automatically redirect to the login screen
              },
            ),
          ],
        ),
      ),
      // The body is now the currently active page provided by the router
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: 'main_fab',
        shape: const CircleBorder(),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddExpenseSheet(),
          );
        },
        tooltip: 'Add Transaction',
        backgroundColor: primaryColor,
        elevation: 4.0,
        child: const Icon(Icons.add, size: 30),
      ),
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  Widget _buildBottomAppBar(BuildContext context) {
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
              children: [
                _buildNavItem(context, icon: Icons.home, index: 0),
                _buildNavItem(context, icon: Icons.category, index: 1),
                const SizedBox(width: 40),
                _buildNavItem(context, icon: Icons.tag, index: 2),
                _buildNavItem(context, icon: Icons.person, index: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required int index,
  }) {
    return InkWell(
      onTap: () => _onPageTapped(context, index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: navigationShell.currentIndex == index
                  ? const Color(0xFF2E9A91)
                  : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
