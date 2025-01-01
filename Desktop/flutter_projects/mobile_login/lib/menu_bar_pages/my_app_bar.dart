import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.onMenuPressed,
  });

  final VoidCallback onMenuPressed;

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    // Set the status bar color
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black, // transparent status bar
      statusBarIconBrightness:
          Brightness.dark, // dark icons for light status bar
    ));

    return AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.menu_rounded,
          size: 45.0,
        ),
        onPressed: () {
          Scaffold.of(context)
              .openDrawer(); // Ensure Scaffold.of(context) is used correctly
        },
      ),
    );
  }
}
