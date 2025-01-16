import 'package:ai_short_form_video_web/styles/colors.dart';
import 'package:ai_short_form_video_web/styles/fonts.dart';
import 'package:flutter/material.dart';

class MiddleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MiddleButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: AppFonts.button1,
      fixedSize: const Size(160, 60),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
          color: AppColors.black1,
          width: 2,
        ),
      ),
      backgroundColor: AppColors.white,
    );
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Text(text),
    );
  }
}
