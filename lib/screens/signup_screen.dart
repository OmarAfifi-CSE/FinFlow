// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../componants/my_button.dart';
import '../componants/my_textfield.dart';
import 'signin_screen.dart';
import '../main.dart'; // Import to use the global 'supabase' client

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Your existing controllers and keys are perfect.
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> usernameState = GlobalKey();
  final GlobalKey<FormState> emailState = GlobalKey();
  final GlobalKey<FormState> passwordState = GlobalKey();

  // --- NEW --- We add a loading state variable.
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// --- NEW --- This is the new sign-up logic.
  Future<void> _signUp() async {
    // 1. Validate all form fields using your existing keys.
    final isUsernameValid = usernameState.currentState!.validate();
    final isEmailValid = emailState.currentState!.validate();
    final isPasswordValid = passwordState.currentState!.validate();

    // If any field is invalid, stop here.
    if (!isUsernameValid || !isEmailValid || !isPasswordValid) {
      return;
    }

    // 2. Set the loading state to show a progress indicator.
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Attempt to sign up with Supabase Auth.
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        // We can pass extra non-sensitive data like the username.
        data: {'username': _usernameController.text.trim()},
        // This is our deep link for the email confirmation.
        emailRedirectTo:
            'https://omarafifi-cse.github.io/FinFlow/email-confirmed.html',
      );

      // 4. On success, show a confirmation message and navigate back.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green[600],
            content: Text(
              'Success! Please check your email to confirm your account.',
            ),
          ),
        );
        // Go back to the sign-in screen so they can log in after confirming.
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      // 5. If Supabase returns an error, show it in a snackbar.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      // 6. Handle any other unexpected errors.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An unexpected error occurred.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    // 7. After the attempt, hide the loading indicator.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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
                      "Create Account",
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 55),
                    const Text(
                      textAlign: TextAlign.start,
                      "Sign Up",
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
                        Icon(Icons.person_outline_outlined, size: 12),
                        Text(
                          textAlign: TextAlign.start,
                          " Your username",
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
                      controller: _usernameController,
                      hintText: 'Username',
                      formKey: usernameState,
                      valMessage: 'Enter username',
                      obscureText: false,
                    ),
                    const SizedBox(height: 30),
                    const Row(
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.email_outlined, size: 12),
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
                      formKey: emailState,
                      valMessage: 'Enter email',
                      obscureText: false,
                    ),
                    const SizedBox(height: 30),
                    const Row(
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.lock_outline, size: 12),
                        Text(
                          textAlign: TextAlign.start,
                          " Password",
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
                      valMessage: 'Enter password',
                    ),
                    const SizedBox(height: 100),

                    // --- THIS IS THE ONLY UI CHANGE ---
                    // If loading, show a progress indicator. Otherwise, show the button.
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      MyButton(
                        button_msg: 'Sign Up',
                        bgColor: Colors.teal,
                        fgColor: Colors.white,
                        // The button now calls our new _signUp function.
                        onPressed: _signUp,
                        padding: 15,
                        borderRadius: 50,
                      ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already a user?"),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            // Go back to the sign-in screen.
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
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
