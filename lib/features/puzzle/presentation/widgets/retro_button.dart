import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetroButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final Color baseColor;
  final bool isSmall;

  const RetroButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.baseColor = const Color(0xFF00F0FF), // Neon Cyan
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    final effectiveColor = isDisabled ? Colors.grey : baseColor;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isDisabled
            ? Colors.white.withValues(alpha: 0.1)
            : effectiveColor,
        foregroundColor: isDisabled ? Colors.white38 : Colors.black,
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
        disabledForegroundColor: Colors.white38,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 16 : 32,
          vertical: isSmall ? 12 : 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmall ? 12 : 20),
          side: BorderSide(
            color: isDisabled ? Colors.transparent : effectiveColor,
            width: 2,
          ),
        ),
        elevation: isDisabled ? 0 : 8,
        shadowColor: effectiveColor.withValues(alpha: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(
                size: isSmall ? 16 : 20,
                color: isDisabled ? Colors.white38 : Colors.black,
              ),
              child: icon!,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label.toUpperCase(),
            style: GoogleFonts.pressStart2p(
              fontSize: isSmall ? 10 : 14,
              fontWeight: FontWeight.bold,
              color: isDisabled ? Colors.white38 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
