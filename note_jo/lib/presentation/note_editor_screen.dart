import 'package:flutter/material.dart';
import 'package:note_jo/components/editor/note_blocks.dart';
import 'package:note_jo/components/editor/note_editor_controller.dart';
import 'package:note_jo/components/editor/block_render.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final NoteEditorController _controller = NoteEditorController();

  @override
  void initState() {
    super.initState();
    // Initialize with a single heading block if empty
    _controller.loadBlocks([
      NoteBlock(
        id: UniqueKey().toString(),
        type: BlockType.heading,
        data: {'text': ''},
      ),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertBlock(BlockType type) {
    // Find currently focused block (fallback to last block if none focused)
    int targetIndex = _controller.blocks.length - 1;
    for (int i = 0; i < _controller.blocks.length; i++) {
      final block = _controller.blocks[i];
      if (block.type == BlockType.scripture) {
        if (_controller.focusNodes["${block.id}_verse"]?.hasFocus == true ||
            _controller.focusNodes["${block.id}_text"]?.hasFocus == true) {
          targetIndex = i;
          break;
        }
      } else {
        if (_controller.focusNodes[block.id]?.hasFocus == true) {
          targetIndex = i;
          break;
        }
      }
    }

    // Ensure we don't insert at -1 if the list is empty somehow
    if (targetIndex < 0) targetIndex = 0;

    final data = <String, dynamic>{};
    if (type == BlockType.scripture) {
      data['verse'] = '';
      data['text'] = '';
    } else {
      data['text'] = '';
    }

    final newBlock = NoteBlock(
      id: UniqueKey().toString(),
      type: type,
      data: data,
    );
    _controller.insertBlockAfter(targetIndex, newBlock);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202124), // Google Keep dark mode surface
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            itemCount: _controller.blocks.length,
            itemBuilder: (context, index) {
              final block = _controller.blocks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: BlockRenderer.build(
                  block: block,
                  textController: _controller.textControllers,
                  focusNodes: _controller.focusNodes,
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF202124),
        elevation: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.text_fields, color: Colors.white),
              onPressed: () => _insertBlock(BlockType.paragraph),
              tooltip: 'Add Paragraph',
            ),
            IconButton(
              icon: const Icon(Icons.format_quote, color: Colors.white),
              onPressed: () => _insertBlock(BlockType.quote),
              tooltip: 'Add Quote',
            ),
            IconButton(
              icon: const Icon(Icons.menu_book, color: Colors.white),
              onPressed: () => _insertBlock(BlockType.scripture),
              tooltip: 'Add Scripture',
            ),
            IconButton(
              icon: const Icon(Icons.horizontal_rule, color: Colors.white),
              onPressed: () => _insertBlock(BlockType.divider),
              tooltip: 'Add Divider',
            ),
          ],
        ),
      ),
    );
  }
}
