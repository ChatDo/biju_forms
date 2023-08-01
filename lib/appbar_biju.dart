import 'package:flutter/material.dart';

class BijuAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const BijuAppBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xffff6b87),
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      // backgroundColor: const Color(0xffff6b87),
      backgroundColor: Colors.black.withOpacity(0.8),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
