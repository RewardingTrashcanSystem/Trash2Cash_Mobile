import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color color;
  
  // Fixed styling
  static const double buttonWidth = 312.0;
  static const double buttonHeight = 50.0;
  static const double borderRadius = 12.0;
  static const Color textColor = Colors.white;
  static const List<BoxShadow> shadows = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      blurRadius: 6,
      offset: Offset(0, 3),
    ),
  ];
  
  const AppButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.isLoading = false,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: onPressed == null || isLoading 
              ? color.withOpacity(0.6) 
              : color,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadows,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}