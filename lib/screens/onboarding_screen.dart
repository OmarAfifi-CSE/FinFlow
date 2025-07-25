import 'package:expense_manager/styling/app_text_styles.dart';
import 'package:expense_manager/widgets/custom_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routing/app_routes.dart';
import '../styling/app_assets.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Image(
          image: AssetImage(AppAssets.onboardingImage),
          width: MediaQuery.of(context).size.width < 500
              ? MediaQuery.of(context).size.width
              : 300,
          fit: BoxFit.fill,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Text(
          "Spend Smarter\nSave More",
          textAlign: TextAlign.center,
          style: AppTextStyles.primaryHeadlineStyle.copyWith(fontSize: 35),
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
            child: CustomPrimaryButton(
              buttonText: 'Get Started',
              elevation: 5,
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('onboarding_complete', true);
                if (context.mounted) {
                  context.pushReplacementNamed(AppRoutes.mainScreen);
                }
              },
            ),
          ),
        ),
        SizedBox(height: 50),
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
