import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.width,
      required this.height,
      required this.text,
      required this.onPressed,
      required this.color,
      required this.textColor,
      required this.isBordered});
  final double width;
  final double height;
  final String text;
  final Function onPressed;
  final Color color;
  final Color textColor;
  final bool isBordered;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: () => onPressed(),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isBordered ? Theme.of(context).colorScheme.surface : color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: isBordered
                  ? BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 1.5)
                  : BorderSide.none,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
                color: isBordered
                    ? Theme.of(context).colorScheme.primary
                    : textColor),
          ),
        ));
  }
}