import 'package:flutter/material.dart';
import '../components/topbar.dart';
import '../components/custom_search_bar.dart';
import '../components/category_tabs.dart';
import '../components/notecard.dart';
import '../components/models/note_model.dart';
import '../repository/note_repository.dart';
import 'note_editor_screen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final NoteRepository _repository = NoteRepository();

  String _selectedCategory = 'All Notes';
  String _searchQuery = '';

  static const List<String> _categories = [
    'All Notes',
    'Word of God',
    'Meeting Minutes',
    'Personal Jottings',
    'Class Jottings',
  ];

  // All notes from disk
  List<NoteModel> _allNotes = [];

  // Derived list after filter + search
  List<NoteModel> get _filteredNotes {
    return _allNotes.where((note) {
      // 1. Category filter
      final matchesCategory =
          _selectedCategory == 'All Notes' || note.category == _selectedCategory;

      // 2. Search filter (title or brief, case-insensitive)
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          note.title.toLowerCase().contains(q) ||
          note.brief.toLowerCase().contains(q);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await _repository.loadAllNotes();
    setState(() {
      _allNotes = notes;
      _isLoading = false;
    });
  }

  Future<void> _deleteNote(String id) async {
    await _repository.deleteNote(id);
    await _loadNotes(); // refresh the list
  }

  Future<void> _openEditor() async {
    // Wait for the editor to pop — it returns `true` if a note was saved
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
    );
    if (saved == true) _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202124),
      appBar: const Topbar(),
      body: Column(
        children: [
          // ── SEARCH BAR ──────────────────────────────────────────────────
          CustomSearchBar(
            onChanged: (query) => setState(() => _searchQuery = query),
          ),
          const SizedBox(height: 8),

          // ── CATEGORY TABS ────────────────────────────────────────────────
          CategoryTabs(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: (cat) =>
                setState(() => _selectedCategory = cat),
          ),
          const SizedBox(height: 8),

          // ── NOTE LIST ────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF5C6CE1)))
                : _filteredNotes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _filteredNotes.length,
                        itemBuilder: (context, index) {
                          final note = _filteredNotes[index];
                          return Dismissible(
                            key: Key(note.id),
                            direction: DismissDirection.endToStart,
                            background: _buildDeleteBackground(),
                            onDismissed: (_) => _deleteNote(note.id),
                            child: Notecard(note: note),
                          );
                        },
                      ),
          ),
        ],
      ),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: _openEditor,
        backgroundColor: const Color(0xFF5C6CE1),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      // ── BOTTOM NAV ────────────────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF202124),
        selectedItemColor: const Color(0xFF5C6CE1),
        unselectedItemColor: Colors.white54,
        showUnselectedLabels: true,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.description), label: 'Notes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.star_border), label: 'Favorites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.label_outline), label: 'Labels'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    final isFiltered =
        _selectedCategory != 'All Notes' || _searchQuery.isNotEmpty;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFiltered ? Icons.search_off : Icons.note_add_outlined,
            size: 64,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'No notes match your filter.' : 'No notes yet.',
            style: const TextStyle(color: Colors.white38, fontSize: 16),
          ),
          if (!isFiltered)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Tap + to write your first note.',
                style: TextStyle(color: Colors.white24, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade800,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }
}
