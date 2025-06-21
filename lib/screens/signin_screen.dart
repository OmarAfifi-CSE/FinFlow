import 'package:flutter/material.dart';
import '../componants/my_button.dart';
import '../componants/my_textfield.dart';
import 'package:expense_manager/screens/home_screen.dart';
import 'package:expense_manager/screens/signup_screen.dart';


class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  // Declare TextEditingControllers for email and password fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> emailState = GlobalKey();
  final GlobalKey<FormState> passwordState = GlobalKey();

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
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
                      "Welcome Back",
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
                      "Login",
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
                          Icons.mail_outlined,
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
                      obscureText: false,
                      formKey: emailState,
                      valMessage: "Enter your Email",
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
                          " Your Password",
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
                      valMessage: "Enter your Password",
                    ),
                    const SizedBox(
                      height: 40,
                    ),

                    // Forget password
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Forgot Password?',
                            style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 70,
                    ),

                    // Sign in button
                    MyButton(
                      button_msg: 'Sign In',
                      bgColor: Colors.teal,
                      fgColor: Colors.white,
                      onPressed: () {
                        // Validate all fields
                        bool isEmailValid = emailState.currentState!.validate();
                        bool isPasswordValid =
                        passwordState.currentState!.validate();
                        if (isEmailValid && isPasswordValid) {
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
                          "Don't have an account?",
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
                                  builder: (context) => const SignupScreen()),
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
                    const SizedBox(
                      height: 120,
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
