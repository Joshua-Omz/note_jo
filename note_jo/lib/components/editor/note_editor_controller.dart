import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_jo/components/editor/note_blocks.dart';

class NoteEditorController extends ChangeNotifier {
  
  // ==========================================
  // 1. THE SOURCE OF TRUTH
  // ==========================================
  List<NoteBlock> blocks = [];

  // ==========================================
  // 2. THE UI COORDINATORS (The Dictionaries)
  // ==========================================
  // We use maps so our NoteBlock model never touches Flutter UI code.
  // Standard blocks use: block.id
  // Multi-field blocks use: "${block.id}_fieldName"
  final Map<String, TextEditingController> textControllers = {};
  final Map<String, FocusNode> focusNodes = {};

  // ==========================================
  // 3. INITIALIZATION
  // ==========================================
  void loadBlocks(List<NoteBlock> initialBlocks) {
    blocks = initialBlocks;
    for (var block in blocks) {
      _setupNode(block);
    }
    notifyListeners();
  }

  // ==========================================
  // 4. THE NODE SETUP ROUTINE
  // ==========================================
  void _setupNode(NoteBlock block) {
    switch (block.type) {
      case BlockType.divider:
      return;
      
      // --- MULTI-FIELD BLOCKS (Path A: Composite Keys) ---
      case BlockType.scripture:
        final verseKey = "${block.id}_verse";
        final textKey = "${block.id}_text";

        // 1. Create the tools
        final verseController = TextEditingController(text: block.data["verse"]);
        final textController = TextEditingController(text: block.data["text"]);
        final verseNode = FocusNode();
        final textNode = FocusNode();

        // 2. Attach the listeners via our clean helper method
        _attachKeyboardListener(block, verseController, verseNode);
        _attachKeyboardListener(block, textController, textNode);

        // 3. Save them to the dictionary for the UI to find
        textControllers[verseKey] = verseController;
        textControllers[textKey] = textController;
        focusNodes[verseKey] = verseNode;
        focusNodes[textKey] = textNode;
        break;

      // --- STANDARD SINGLE-FIELD BLOCKS ---
      default:
        final controller = TextEditingController(text: block.data["text"]);
        final node = FocusNode();

        _attachKeyboardListener(block, controller, node);

        textControllers[block.id] = controller;
        focusNodes[block.id] = node;
        break;
    }
  }

  // ==========================================
  // 5. THE KEYBOARD INTERCEPTION LAYER
  // ==========================================
  // Extracted to keep _setupNode clean and readable.
  void _attachKeyboardListener(NoteBlock block, TextEditingController controller, FocusNode node) {
    node.onKeyEvent = (node, event) {
      // Ignore key releases to prevent double-firing
      if (event is! KeyDownEvent) return KeyEventResult.ignored;

      final currentText = controller.text;
      final cursorPosition = controller.selection.baseOffset;

      // --- ENTER KEY LOGIC ---
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        final splitIndex = cursorPosition >= 0 ? cursorPosition : currentText.length;
        final textToKeep = currentText.substring(0, splitIndex);
        final textToMove = currentText.substring(splitIndex);

        // 1. Update current controller
        controller.text = textToKeep;
        controller.selection = TextSelection.collapsed(offset: textToKeep.length);

        // 2. Create new block data (Always defaults to paragraph for fluid typing)
        final newBlock = NoteBlock(
          id: UniqueKey().toString(), 
          type: BlockType.paragraph, 
          data: {'text': textToMove},
        );

        // 3. Insert and shift focus
        final currentIndex = blocks.indexWhere((b) => b.id == block.id);
        insertBlockAfter(currentIndex, newBlock);

        return KeyEventResult.handled; // Block the default newline
      }

      // --- BACKSPACE KEY LOGIC ---
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (cursorPosition == 0) {
          final currentIndex = blocks.indexWhere((b) => b.id == block.id);
          
          if (currentIndex > 0) {
            // Note: If the previous block is a scripture block, you will need 
            // logic here to determine if the text appends to the '_verse' or '_text' key.
            final previousBlock = blocks[currentIndex - 1];
            final previousController = textControllers[previousBlock.id]!; // Assumes standard block for this example

            final previousTextLength = previousController.text.length;
            previousController.text += currentText;
            previousController.selection = TextSelection.collapsed(offset: previousTextLength);

            removeBlock(currentIndex);
            return KeyEventResult.handled; // Block default backspace
          }
        }
      }

      return KeyEventResult.ignored; // Let user type normally
    };
  }

  // ==========================================
  // 6. STRUCTURAL MUTATIONS
  // ==========================================
  void insertBlockAfter(int currentIndex, NoteBlock newBlock) {
    blocks.insert(currentIndex + 1, newBlock);
    _setupNode(newBlock); // for divider, _setupNode returns immediately (no-op)
    notifyListeners();

    // Dividers have no TextField — auto-insert a paragraph after and focus that instead
    if (newBlock.type == BlockType.divider) {
      final paragraphBlock = NoteBlock(
        id: UniqueKey().toString(),
        type: BlockType.paragraph,
        data: {'text': ''},
      );
      blocks.insert(currentIndex + 2, paragraphBlock);
      _setupNode(paragraphBlock);
      notifyListeners();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        focusNodes[paragraphBlock.id]?.requestFocus();
      });
      return; // skip the default focus logic below
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Handles focus for both standard and multi-field blocks
      final targetKey = newBlock.type == BlockType.scripture 
          ? "${newBlock.id}_verse" 
          : newBlock.id;
      focusNodes[targetKey]?.requestFocus();
    });
  }

  void removeBlock(int index) {
    if (index == 0) return;

    final block = blocks[index];
    final previousBlock = blocks[index - 1];

    // --- MEMORY CLEANUP: MULTI-FIELD ---
    if (block.type == BlockType.scripture) {
      final verseKey = "${block.id}_verse";
      final textKey = "${block.id}_text";

      textControllers[verseKey]?.dispose();
      textControllers[textKey]?.dispose();
      focusNodes[verseKey]?.dispose();
      focusNodes[textKey]?.dispose();

      textControllers.remove(verseKey);
      textControllers.remove(textKey);
      focusNodes.remove(verseKey);
      focusNodes.remove(textKey);
    } 
    // --- MEMORY CLEANUP: STANDARD ---
    else {
      textControllers[block.id]?.dispose();
      focusNodes[block.id]?.dispose();
      textControllers.remove(block.id);
      focusNodes.remove(block.id);
    }

    blocks.removeAt(index);
    notifyListeners();

    // Shift focus to the block above
    final previousTargetKey = previousBlock.type == BlockType.scripture 
        ? "${previousBlock.id}_text" // Focus the bottom field of a scripture block
        : previousBlock.id;
    focusNodes[previousTargetKey]?.requestFocus();
  }

  // ==========================================
  // 7. ABSOLUTE CLEANUP (App Close / Screen Pop)
  // ==========================================
  @override
  void dispose() {
    for (var controller in textControllers.values) {
      controller.dispose();
    }
    for (var node in focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }
}