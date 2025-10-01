import 'package:flutter/material.dart';

class Cards extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onTitleTap;
  final VoidCallback? onIconTap;
  final double elevation;
  final double borderRadius;

  Cards({
    Key? key,
    required this.title,
    this.icon,
    this.onTitleTap,
    this.onIconTap,
    this.elevation = 8.0,
    this.borderRadius = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onTitleTap,
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            if (icon != null)
              IconButton(
                icon: Icon(icon),
                onPressed: onIconTap,
              ),
          ],
        ),
      ),
    );
  }
}
