import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_gate.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Image(
          image: AssetImage('assets/images/Onboarding.png'),
          width: MediaQuery.of(context).size.width < 500
              ? MediaQuery.of(context).size.width
              : 300,
          fit: BoxFit.fitWidth,
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.02),

        Text(
          "Spend Smarter\nSave More",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 40,
            color: Color(0xff438883),
          ),
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 500
                ? MediaQuery.of(context).size.width * .1
                : MediaQuery.of(context).size.width * .2,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // Inside your ElevatedButton's onPressed:
              onPressed: () async {
                // Get the instance of SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                // Save the flag
                await prefs.setBool('onboarding_complete', true);
                // Navigate to the home screen and remove the onboarding screen from the history
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthGate()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff438883),
                foregroundColor: Colors.white,
                elevation: 5,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Get Started"),
            ),
          ),
        ),
      ],
    );
    return Scaffold(
      backgroundColor: Color(0xffE5E5E5),
      body: MediaQuery.of(context).size.width < 500
          ? SingleChildScrollView(child: content)
          : Center(child: SingleChildScrollView(child: content)),
    );
  }
}
