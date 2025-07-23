import 'package:expense_manager/auth/widgets/custom_text_field_label.dart';
import 'package:expense_manager/widgets/custom_primary_button.dart';
import 'package:expense_manager/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import '../styling/app_text_styles.dart'; // Import to use the global 'supabase' client

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> usernameState = GlobalKey();
  final GlobalKey<FormState> emailState = GlobalKey();
  final GlobalKey<FormState> passwordState = GlobalKey();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final isUsernameValid = usernameState.currentState!.validate();
    final isEmailValid = emailState.currentState!.validate();
    final isPasswordValid = passwordState.currentState!.validate();

    if (!isUsernameValid || !isEmailValid || !isPasswordValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        // Pass extra non-sensitive data like the username.
        data: {'username': _usernameController.text.trim()},
        // This is our deep link for the email confirmation.
        emailRedirectTo:
            'https://omarafifi-cse.github.io/FinFlow/email-confirmed.html',
      );

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
        context.pop();
      }
    } on AuthException catch (e) {
      // If Supabase returns an error, show it in a snackbar.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      // Handle any other unexpected errors.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An unexpected error occurred.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    // After the attempt, hide the loading indicator.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    "Create Account",
                    style: AppTextStyles.primaryHeadlineStyle,
                  ),
                  const SizedBox(height: 55),
                  Text(
                    textAlign: TextAlign.start,
                    "Sign Up",
                    style: AppTextStyles.primaryHeadlineStyle,
                  ),
                  const SizedBox(height: 25),
                  const CustomTextFieldLabel(
                    icon: Icons.person_outline_outlined,
                    label: "Your username",
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    controller: _usernameController,
                    hintText: 'Username',
                    formKey: usernameState,
                    valMessage: 'Please enter your username',
                    obscureText: false,
                  ),
                  const SizedBox(height: 30),
                  const CustomTextFieldLabel(
                    icon: Icons.email_outlined,
                    label: "Your email",
                  ),

                  const SizedBox(height: 10),
                  CustomTextFormField(
                    controller: _emailController,
                    hintText: 'Email',
                    formKey: emailState,
                    valMessage: 'Please enter your email',
                    obscureText: false,
                  ),
                  const SizedBox(height: 30),
                  const CustomTextFieldLabel(
                    icon: Icons.lock_outline,
                    label: "Your password",
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    formKey: passwordState,
                    valMessage: 'Please enter your password',
                  ),
                  const SizedBox(height: 70),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    CustomPrimaryButton(
                      buttonText: 'Sign Up',
                      onPressed: _signUp,
                    ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already a user?"),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          context.pop();
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
        ),
      ),
    );
  }
}
