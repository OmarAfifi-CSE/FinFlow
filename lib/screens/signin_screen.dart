import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../componants/my_button.dart';
import '../componants/my_textfield.dart';
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
                        'Enter the email address associated with your account to receive a password reset link.',
                      ),
                      const SizedBox(height: 20),
                      MyTextfield(
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
                  child: const Text('Cancel'),
                  onPressed: isDialogLoading
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                ),
                TextButton(
                  child: const Text('Send Link'),
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
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close the dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Password reset link sent! Please check your email.',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  // Step 3: If user does not exist, show an error
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close the dialog
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
                            } catch (e) {
                              if (mounted) {
                                Navigator.of(context).pop(); // Close the dialog
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      textAlign: TextAlign.center,
                      "Welcome Back",
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 55),
                    const Text(
                      textAlign: TextAlign.start,
                      "Login",
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Row(
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.mail_outlined, size: 12),
                        Text(
                          textAlign: TextAlign.start,
                          " Your email",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      controller: _emailController,
                      hintText: 'Email',
                      obscureText: false,
                      formKey: emailState,
                      valMessage: "Enter your Email",
                    ),
                    const SizedBox(height: 30),
                    const Row(
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.lock_outline, size: 12),
                        Text(
                          textAlign: TextAlign.start,
                          " Your Password",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      formKey: passwordState,
                      valMessage: "Enter your Password",
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
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
                    ),
                    const SizedBox(height: 70),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      MyButton(
                        button_msg: 'Sign In',
                        bgColor: Colors.teal,
                        fgColor: Colors.white,
                        onPressed: _signIn,
                        padding: 15,
                        borderRadius: 50,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
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
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
