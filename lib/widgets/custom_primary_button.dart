import 'package:flutter/material.dart';
import '../styling/app_colors.dart';
import '../styling/app_text_styles.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String? buttonText;
  final Color? buttonColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? elevation;
  final void Function()? onPressed;
  final bool isLoading;

  const CustomPrimaryButton({
    super.key,
    required this.buttonText,
    this.buttonColor,
    this.width,
    this.height,
    this.borderRadius,
    this.elevation,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor ?? AppColors.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        elevation: elevation ?? 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 30),
        ),
        fixedSize: width != null && height != null
            ? Size(width!, height!)
            : null,
        textStyle: AppTextStyles.whiteTextStyle,
      ),
      child: isLoading
          ? CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
            )
          : Text(buttonText ?? ""),
    );
  }
}
