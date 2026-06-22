import 'package:flutter/material.dart';
import 'package:note_jo/components/editor/note_blocks.dart';
import 'package:google_fonts/google_fonts.dart';

class BlockRenderer {
  static Widget build({
    required NoteBlock block,
    required Map<String, TextEditingController> textController,
    required Map<String, FocusNode> focusNodes,
  }) {
    switch (block.type) {
      case BlockType.heading:
        return TextField(
          controller: textController[block.id]!,
          focusNode: focusNodes[block.id]!,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          maxLines: null,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Heading',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        );

      case BlockType.paragraph:
        return TextField(
          controller: textController[block.id]!,
          focusNode: focusNodes[block.id]!,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 16, color: Colors.white),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Type something...',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        );

      case BlockType.scripture:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2E32),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController["${block.id}_verse"]!,
                focusNode: focusNodes["${block.id}_verse"]!,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Romans 12:2',
                  hintStyle: TextStyle(color: Colors.white30),
                  isDense: true,
                ),
              ),
              TextField(
                controller: textController["${block.id}_text"]!,
                focusNode: focusNodes["${block.id}_text"]!,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Scripture text...',
                  hintStyle: TextStyle(color: Colors.white30),
                  isDense: true,
                ),
              ),
            ],
          ),
        );

      case BlockType.quote:
        return Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Colors.cyanAccent, width: 4)),
          ),
          padding: const EdgeInsets.only(left: 12),
          child: TextField(
            controller: textController[block.id],
            focusNode: focusNodes[block.id],
            maxLines: null,
            style: GoogleFonts.pacifico(fontSize: 16, color: Colors.cyanAccent),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Quote...',
              hintStyle: TextStyle(color: Colors.white30),
            ),
          ),
        );

      case BlockType.divider:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(color: Colors.white24, thickness: 1),
        );

    }
  }
}
