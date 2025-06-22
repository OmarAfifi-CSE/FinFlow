import 'package:flutter/material.dart';

class MyTextfield extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;
  final GlobalKey<FormState>? formKey;
  final String? valMessage;
  final Color? backgroundColor;
  final Color? borderSideColor;
  final int? maxLines;
  final ValueChanged<String>? onChanged;

  const MyTextfield({
    Key? key,
    this.controller,
    required this.hintText,
    required this.obscureText,
    this.formKey,
    this.valMessage,
    this.backgroundColor,
    this.borderSideColor,
    this.maxLines,
    this.onChanged,
  }) : super(key: key);

  @override
  _MyTextfieldState createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Form(
        key: widget.formKey,
        child: TextFormField(
          maxLines: widget.maxLines ?? 1,
          validator: (value) {
            if (value!.isEmpty) {
              return widget.valMessage;
            }
            return null;
          },
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.borderSideColor ?? Color(0xFF828282),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
            ),
            fillColor: widget.backgroundColor ?? Colors.white,
            filled: true,
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Color(0xFF828282)),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF828282),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
