import 'package:flutter/material.dart';

class InputCard extends StatelessWidget {
  const InputCard({
    super.key,
    required this.icon,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.errorText,
    this.autofillHints,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
  });

  final IconData icon;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final List<String>? autofillHints;
  final int? maxLines;
  final int? minLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10))],
      ),
      child: TextField(
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        minLines: minLines,
        textInputAction: textInputAction ?? TextInputAction.next,
        autofillHints: autofillHints,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: scheme.primary.withValues(alpha: 0.7)),
          hintText: hintText,
          hintStyle: TextStyle(color: scheme.primary.withValues(alpha: 0.5)),
          suffixIcon: suffixIcon,
          errorText: errorText,
        ),
      ),
    );
  }
}
