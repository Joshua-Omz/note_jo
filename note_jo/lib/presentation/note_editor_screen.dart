import 'package:flutter/material.dart';
import 'package:note_jo/components/editor/note_blocks.dart';
import 'package:note_jo/components/editor/note_editor_controller.dart';
import 'package:note_jo/components/editor/block_render.dart';
import 'package:note_jo/repository/note_repository.dart';
import 'package:note_jo/components/models/note_model.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final NoteEditorController _controller = NoteEditorController();
  final NoteRepository _repository = NoteRepository();

  // The category the user picks before saving
  String _selectedCategory = 'Personal Jottings';

  static const List<String> _categories = [
    'Word of God',
    'Meeting Minutes',
    'Personal Jottings',
    'Class Jottings',
  ];

  @override
  void initState() {
    super.initState();
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

  // ── SAVE ────────────────────────────────────────────────────────────────────
  Future<void> _saveAndPop() async {
    // Read title from the heading block's TextEditingController (not .data)
    final headingBlock = _controller.blocks.firstWhere(
      (b) => b.type == BlockType.heading,
      orElse: () => _controller.blocks.first,
    );
    final title =
        (_controller.textControllers[headingBlock.id]?.text ?? '').trim();

    // Concatenate all body blocks for the preview text
    final bodyBlocks =
        _controller.blocks.where((b) => b.type != BlockType.heading);
    final brief = bodyBlocks.map((b) {
      if (b.type == BlockType.scripture) {
        final verse = _controller.textControllers['${b.id}_verse']?.text ?? '';
        final text = _controller.textControllers['${b.id}_text']?.text ?? '';
        return verse.isNotEmpty ? '[$verse] $text' : text;
      }
      return _controller.textControllers[b.id]?.text ?? '';
    }).where((t) => t.isNotEmpty).join('\n').trim();

    // Skip saving truly empty notes
    if (title.isEmpty && brief.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final now = DateTime.now();
    final note = NoteModel(
      id: now.millisecondsSinceEpoch.toString(),
      title: title.isEmpty ? 'Untitled Note' : title,
      brief: brief.isEmpty ? 'No additional content.' : brief,
      category: _selectedCategory,
      dateTime: now,
      timeAgo: 'Just now',
    );

    await _repository.saveNote(note);
    if (mounted) Navigator.pop(context, true); // return `true` so home reloads
  }

  // ── CATEGORY PICKER BOTTOM SHEET ────────────────────────────────────────────
  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2E32),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Select Category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ..._categories.map((cat) => ListTile(
                    title: Text(cat,
                        style: const TextStyle(color: Colors.white70)),
                    trailing: _selectedCategory == cat
                        ? const Icon(Icons.check, color: Color(0xFF5C6CE1))
                        : null,
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  // ── INSERT BLOCK ─────────────────────────────────────────────────────────────
  void _insertBlock(BlockType type) {
    int targetIndex = _controller.blocks.length - 1;
    for (int i = 0; i < _controller.blocks.length; i++) {
      final block = _controller.blocks[i];
      final key = block.type == BlockType.scripture
          ? '${block.id}_verse'
          : block.id;
      if (_controller.focusNodes[key]?.hasFocus == true ||
          _controller.focusNodes['${block.id}_text']?.hasFocus == true) {
        targetIndex = i;
        break;
      }
    }
    if (targetIndex < 0) targetIndex = 0;

    final data = <String, dynamic>{};
    if (type == BlockType.scripture) {
      data['verse'] = '';
      data['text'] = '';
    } else {
      data['text'] = '';
    }

    _controller.insertBlockAfter(
      targetIndex,
      NoteBlock(id: UniqueKey().toString(), type: type, data: data),
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202124),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        // Show the active category as a tappable chip
        title: GestureDetector(
          onTap: _showCategoryPicker,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF3F51B5).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedCategory,
                  style: const TextStyle(
                    color: Color(0xFF8C9EFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down,
                    color: Color(0xFF8C9EFF), size: 18),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAndPop,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
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
          ),
          // ── BOTTOM TOOLBAR ────────────────────────────────────────────────
          SafeArea(
            child: Container(
              color: const Color(0xFF202124),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _toolbarBtn(Icons.text_fields, 'Paragraph',
                      () => _insertBlock(BlockType.paragraph)),
                  _toolbarBtn(Icons.format_quote, 'Quote',
                      () => _insertBlock(BlockType.quote)),
                  _toolbarBtn(Icons.menu_book, 'Scripture',
                      () => _insertBlock(BlockType.scripture)),
                  _toolbarBtn(Icons.horizontal_rule, 'Divider',
                      () => _insertBlock(BlockType.divider)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolbarBtn(IconData icon, String tooltip, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
