import 'package:expense_manager/screens/home_screen.dart';
import 'package:expense_manager/screens/signin_screen.dart';
import 'package:flutter/material.dart';
import '../componants/my_button.dart';
import '../componants/my_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Declare TextEditingControllers for email and password fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> usernameState = GlobalKey();
  final GlobalKey<FormState> emailState = GlobalKey();
  final GlobalKey<FormState> passwordState = GlobalKey();

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                      "Create Account",
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 55,
                    ),
                    const Text(
                      textAlign: TextAlign.start,
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.person_outline_outlined,
                          size: 12,
                        ),
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
                    const SizedBox(
                      height: 10,
                    ),
                    // Email TextField
                    MyTextfield(
                      controller: _usernameController,
                      hintText: 'Username',
                      formKey: usernameState,
                      valMessage: 'Enter username',
                      obscureText: false,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.email_outlined,
                          size: 12,
                        ),
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
                    const SizedBox(
                      height: 10,
                    ),
                    // Email TextField
                    MyTextfield(
                      controller: _emailController,
                      hintText: 'Email',
                      formKey: emailState,
                      valMessage: 'Enter email',
                      obscureText: false,
                    ),
                    const SizedBox(
                      height: 30,
                    ),

                    const Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.lock_outline,
                          size: 12,
                        ),
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
                    const SizedBox(
                      height: 10,
                    ),
                    // Password TextField
                    MyTextfield(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      formKey: passwordState,
                      valMessage: 'Enter password',
                    ),
                    const SizedBox(
                      height: 100,
                    ),

                    // Sign up button

                    MyButton(
                      button_msg: 'Sign Up',
                      bgColor: Colors.teal,
                      fgColor: Colors.white,
                      onPressed: () {
                        // Validate all fields
                        bool isUsernameValid =
                        usernameState.currentState!.validate();
                        bool isEmailValid = emailState.currentState!.validate();
                        bool isPasswordValid =
                        passwordState.currentState!.validate();

                        // Check if all validations passed
                        if (isUsernameValid &&
                            isEmailValid &&
                            isPasswordValid) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Please fill out all fields correctly!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              margin: const EdgeInsets.all(20),
                              elevation: 10,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      padding: 15,
                      borderRadius: 50,
                    ),

                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already a user?",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SigninScreen()),
                            );
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
