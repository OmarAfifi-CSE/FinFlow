import 'package:expense_manager/auth/widgets/custom_text_field_label.dart';
import 'package:expense_manager/widgets/custom_primary_button.dart';
import 'package:expense_manager/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../routing/app_routes.dart';
import '../styling/app_text_styles.dart';
import 'signup_screen.dart';
import '../main.dart'; // Import to use the global 'supabase' client

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> emailState = GlobalKey();
  final GlobalKey<FormState> passwordState = GlobalKey();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    bool isEmailValid = emailState.currentState!.validate();
    bool isPasswordValid = passwordState.currentState!.validate();

    if (!isEmailValid || !isPasswordValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An unexpected error occurred.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showForgotPasswordDialog() async {
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  "Welcome Back",
                  style: AppTextStyles.primaryHeadlineStyle,
                ),
                const SizedBox(height: 55),
                Text(
                  textAlign: TextAlign.start,
                  "Login",
                  style: AppTextStyles.primaryHeadlineStyle,
                ),
                const SizedBox(height: 25),
                CustomTextFieldLabel(
                  icon: Icons.mail_outlined,
                  label: "Your email",
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  hintText: 'Email',
                  controller: _emailController,
                  obscureText: false,
                  formKey: emailState,
                  valMessage: "Please enter your email",
                ),
                const SizedBox(height: 30),
                CustomTextFieldLabel(
                  icon: Icons.lock_outline,
                  label: "Your password",
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  hintText: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  formKey: passwordState,
                  valMessage: "Please enter your password",
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: _showForgotPasswordDialog,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  CustomPrimaryButton(
                    buttonText: 'Sign In',
                    onPressed: _signIn,
                  ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        context.pushNamed(AppRoutes.registerScreen);
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
