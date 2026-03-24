import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: onPressed == null || isLoading
            ? LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade500],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : LinearGradient(
                colors: [theme.colorScheme.secondary, theme.colorScheme.primary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: onPressed == null || isLoading
            ? []
            : [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                    ),
                  )
                : Text(
                    text,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
