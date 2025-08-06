import 'package:expense_manager/widgets/custom_primary_button.dart';
import 'package:expense_manager/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../styling/app_colors.dart';
import '../widgets/wave_clipper.dart';
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
                                        content: Text(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.loose,
        alignment: AlignmentDirectional.topCenter,
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 450,
              decoration: const BoxDecoration(color: AppColors.primaryColor),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 60, bottom: 20),
                    child: Text(
                      "Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.teal[300],
                      child: const Icon(
                        Icons.person,
                        size: 140,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _username,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    _email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black54,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 10),
                    child: CustomPrimaryButton(
                      buttonText: 'Change Password',
                      icon: Icons.lock,
                      onPressed: _showChangePasswordDialog,
                      borderRadius: 12,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 40),
                    child: CustomPrimaryButton(
                      buttonText: 'Log Out',
                      textColor: Colors.red[700],
                      icon: Icons.logout,
                      onPressed: () async {
                        await supabase.auth.signOut();
                      },
                      borderRadius: 12,
                      buttonColor: Colors.red[50]!,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
