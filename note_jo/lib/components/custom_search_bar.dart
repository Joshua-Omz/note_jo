import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  /// Called every time the user types a character.
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2E32),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          style: const TextStyle(color: Colors.white),
          onChanged: onChanged, // pipes keystrokes up to the parent
          decoration: const InputDecoration(
            icon: Icon(Icons.search, color: Colors.white54),
            border: InputBorder.none,
            hintText: 'Search notes...',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
      ),
    );
  }
}
