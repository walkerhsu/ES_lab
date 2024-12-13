import 'package:flutter/material.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final Function()? onBack;
  const MyAppBar({super.key, this.title='TSMC', this.showBackButton=false, this.onBack});

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 85, 57, 82),
      title: Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: widget.showBackButton ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: widget.onBack ?? () => Navigator.pop(context),
      ) : null,
    );
  }
}