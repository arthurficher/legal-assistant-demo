import 'package:flutter/material.dart';

class InputText extends StatelessWidget {
  final String label;
  final TextInputType keyboardType;
  final bool obscureText, borderEnabled;
  final double fontSize;
  final void Function(String text)? onChanged;
  final String? Function(String? text)? validator;
  final double fontSizeError;
  final Widget? suffixIcon;

  const InputText({
    super.key,
    this.label = '',
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.borderEnabled = true,
    this.fontSize = 15,
    this.onChanged,
    this.validator, 
    this.fontSizeError = 15,
    this.suffixIcon
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: this.obscureText,
      onChanged: this.onChanged,
      validator: this.validator,
      style: TextStyle(
        fontSize: this.fontSize,
        color: Theme.of(context).textTheme.bodyLarge?.color
      ),
      keyboardType: this.keyboardType,
      decoration: InputDecoration(
          border: this.borderEnabled ? null : InputBorder.none,
          labelText: this.label,
          contentPadding: EdgeInsets.symmetric(vertical: 5),
          labelStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500
          ),
          errorStyle: TextStyle(
            fontSize: this.fontSizeError,
            color: Theme.of(context).colorScheme.error
          ),
          suffixIcon: this.suffixIcon
        ),
    );
  }
}
