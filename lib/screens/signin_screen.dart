// lib/screens/signin_screen.dart

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
  // Your existing controllers and keys are perfect.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> emailState = GlobalKey();
  final GlobalKey<FormState> passwordState = GlobalKey();

  // --- NEW --- We add a loading state variable.
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// --- NEW --- This is the new sign-in logic.
  Future<void> _signIn() async {
    // 1. Validate both form fields using your existing keys.
    bool isEmailValid = emailState.currentState!.validate();
    bool isPasswordValid = passwordState.currentState!.validate();

    // If either is invalid, stop here.
    if (!isEmailValid || !isPasswordValid) {
      return;
    }

    // 2. Set the loading state to show a progress indicator.
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Attempt to sign in with Supabase Auth.
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // On success, the AuthGate will automatically handle navigation.
      // We don't need a Navigator.push here.
    } on AuthException catch (e) {
      // 4. If Supabase returns an error, show it in a snackbar.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      // 5. Handle any other unexpected errors.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An unexpected error occurred.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    // 6. After the attempt, hide the loading indicator.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final TextEditingController forgotEmailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
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
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Send Link'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    // Call Supabase to send the reset email
                    await supabase.auth.resetPasswordForEmail(
                      forgotEmailController.text.trim(),
                        redirectTo: 'https://omarafifi-cse.github.io/FinFlow/reset-password.html'
                    );

                    if (mounted) {
                      Navigator.of(context).pop(); // Close the dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Password reset link sent! Please check your email.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } on AuthException catch (e) {
                    if (mounted) {
                      Navigator.of(context).pop(); // Close the dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.message),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.of(context).pop(); // Close the dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('An unexpected error occurred.'),
                          backgroundColor: Theme.of(context).colorScheme.error,
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
                    // --- ALL YOUR UI CODE IS UNCHANGED ---
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
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 70),

                    // --- THIS IS THE ONLY UI CHANGE ---
                    // If loading, show a progress indicator. Otherwise, show the button.
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      MyButton(
                        button_msg: 'Sign In',
                        bgColor: Colors.teal,
                        fgColor: Colors.white,
                        // The button now calls our new _signIn function.
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
