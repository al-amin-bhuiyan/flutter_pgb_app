import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/dimensions.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.focusNode,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = AppColors.title(isDark);
    final subtitleColor = AppColors.subtitle(isDark);
    final inputBgColor = AppColors.inputBackground(isDark);
    final inputBorderColor = AppColors.inputBorder(isDark);
    final primaryColor = AppColors.accent(isDark);
    final focusHighlightColor = AppColors.focusHighlight(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: TextStyle(
            color: subtitleColor,
            fontSize: AppDimensions.fontS,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppDimensions.spaceM),
        Container(
          decoration: BoxDecoration(
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: focusHighlightColor,
                      blurRadius: 0,
                      offset: const Offset(0, 0),
                      spreadRadius: 3.r,
                    )
                  ]
                : null,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            style: TextStyle(
              color: titleColor,
              fontSize: AppDimensions.fontXL,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputBgColor,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.radiusL,
                vertical: AppDimensions.fontXL,
              ),
              prefixIcon: Icon(
                widget.prefixIcon,
                color: subtitleColor,
                size: AppDimensions.iconS + 1,
              ),
              suffixIcon: widget.suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                borderSide: BorderSide(
                  width: 1,
                  color: inputBorderColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                borderSide: BorderSide(
                  width: 1,
                  color: primaryColor,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.redAccent,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.redAccent,
                ),
              ),
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: subtitleColor.withOpacity(0.6),
                fontSize: AppDimensions.fontXL,
              ),
            ),
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}
