import 'package:expense_manager/screens/widgets/show_logout_dialog.dart';
import 'package:expense_manager/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../styling/app_colors.dart';
import '../main.dart'; // Import for the global supabase client

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Fetches user data from Supabase and updates the state.
  void _loadUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = supabase.auth.currentUser;
      if (user != null && mounted) {
        setState(() {
          _username = user.userMetadata?['username'] ?? 'No username set';
          _email = user.email ?? 'No email found';
        });
      }
    });
  }

  Future<void> _showChangePasswordDialog() async {
    final TextEditingController forgotEmailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isDialogLoading = false;

    return showDialog<void>(
      context: context,
      // Use a StatefulBuilder to manage the dialog's loading state
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (isDialogLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      const Text(
                        'Enter the email address associated with your account'
                        ' to receive a password reset link.',
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        controller: forgotEmailController,
                        hintText: 'Your Email',
                        obscureText: false,
                        valMessage: 'Please enter your email',
                      ),
                    ],
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: isDialogLoading
                      ? null
                      : () {
                          context.pop();
                        },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isDialogLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setDialogState(() {
                              isDialogLoading = true;
                            });

                            try {
                              final email = forgotEmailController.text.trim();

                              // Step 1: Call the database function to check if the user exists
                              final bool userExists = await supabase.rpc(
                                'check_user_exists',
                                params: {'user_email': email},
                              );

                              if (mounted) {
                                // Check if widget is still in the tree
                                if (userExists) {
                                  // Step 2: If user exists, send the reset email
                                  await supabase.auth.resetPasswordForEmail(
                                    email,
                                    redirectTo:
                                        'https://omarafifi-cse.github.io/FinFlow/reset-password.html',
                                  );
                                  if (context.mounted) {
                                    context.pop(); // Close the dialog
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Password reset link sent! Please check your email.',
                                        ),
                                        backgroundColor: Colors.green[600],
                                      ),
                                    );
                                  }
                                } else {
                                  // Step 3: If user does not exist, show an error
                                  if (context.mounted) {
                                    context.pop(); // Close the dialog
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'No account found with that email address.',
                                        ),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    );
                                  }
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                context.pop(); // Close the dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'An unexpected error occurred. Please try again.',
                                    ),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.error,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  child: const Text('Send Link'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildGradientCard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    final isDark =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.grey[800]!.withValues(alpha: 0.8),
                  Colors.grey[900]!.withValues(alpha: 0.6),
                ]
              : [
                  Colors.grey[100]!.withValues(alpha: 0.8),
                  Colors.grey[50]!.withValues(alpha: 0.6),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: _buildGradientCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: MediaQuery.sizeOf(context).width > 700 ? 18 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: MediaQuery.sizeOf(context).width > 700 ? 18 : 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return
    // Enhanced gradient background
    Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      width: MediaQuery.sizeOf(context).width,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(40),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(40),
        ),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.8),
            AppColors.primaryColorShade,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 65,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.teal[200],
                child: const Icon(Icons.person, size: 80, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Text(
                _username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _email,
                style:
                    Provider.of<ThemeProvider>(context).themeMode ==
                        ThemeMode.dark
                    ? TextStyle(
                        fontSize: MediaQuery.sizeOf(context).width > 700
                            ? 20
                            : 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white54,
                      )
                    : TextStyle(
                        fontSize: MediaQuery.sizeOf(context).width > 700
                            ? 20
                            : 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),

            // Stats Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    spacing: 16,
                    children: [
                      _buildStatCard(
                        "Expenses",
                        '\$${Provider.of<ExpenseProvider>(context).totalExpenses.toStringAsFixed(0)}',
                        Icons.trending_down,
                        Colors.red,
                      ),
                      _buildStatCard(
                        "Income",
                        '\$${Provider.of<ExpenseProvider>(context).totalIncome.toStringAsFixed(0)}',
                        Icons.trending_up,
                        Colors.green,
                      ),
                      _buildStatCard(
                        "Categories",
                        Provider.of<ExpenseProvider>(
                          context,
                        ).categories.length.toString(),
                        Icons.category,
                        Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Settings Section
                  _buildGradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Account Settings",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildSettingTile(
                          icon: Icons.lock_outline,
                          title: "Change Password",
                          subtitle: "Update your password",
                          onTap: _showChangePasswordDialog,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Log Out Section
                  _buildGradientCard(
                    child: _buildSettingTile(
                      icon: Icons.logout,
                      title: "Log Out",
                      subtitle: "Sign out of your account",
                      onTap: () async {
                        await showLogoutDialog(context);
                      },
                      color: Colors.red,
                      isDestructive: true,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: MediaQuery.sizeOf(context).width > 700
                          ? 18
                          : 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: MediaQuery.sizeOf(context).width > 700
                          ? 16
                          : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
