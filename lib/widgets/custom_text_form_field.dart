import 'package:flutter/material.dart';

import '../styling/app_colors.dart';
import '../styling/app_text_styles.dart';

class CustomTextFormField extends StatefulWidget {
  final GlobalKey<FormState>? formKey;
  final String? label;
  final String? hintText;
  final Widget? suffixIcon;
  final double? width;
  final double? height;
  final bool obscureText;
  final TextEditingController? controller;
  final String? valMessage;

  const CustomTextFormField({
    super.key,
    this.formKey,
    this.label,
    required this.hintText,
    this.suffixIcon,
    this.width,
    this.height,
    this.obscureText = false,
    this.controller,
    this.valMessage,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: TextFormField(
        style: TextStyle(fontSize: 16),
        controller: widget.controller,
        validator: (value) {
          if (value!.isEmpty) {
            return widget.valMessage;
          }
          return null;
        },
        cursorColor: AppColors.primaryColor,
        obscureText: _isObscured,
        decoration: InputDecoration(

          hintText: widget.hintText,
          hintStyle: AppTextStyles.subtitlesStyle,
          filled: true,
          fillColor: AppColors.whiteColor,
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.secondaryColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryColor,width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          suffixIcon: widget.obscureText
              ? _buildPasswordIcon()
              : widget.suffixIcon,
        ),
      ),
    );
  }

  Widget _buildPasswordIcon() {
    return IconButton(
      icon: Icon(
        _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.secondaryColor,
      ),
      onPressed: () {
        setState(() {
          _isObscured = !_isObscured;
        });
      },
    );
  }
}
