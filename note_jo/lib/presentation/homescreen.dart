import 'package:flutter/material.dart';
import '../components/topbar.dart';
import '../components/custom_search_bar.dart';
import '../components/category_tabs.dart';
import '../components/notecard.dart';
import '../components/models/note_model.dart';
import 'note_editor_screen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String selectedCategory = 'All Notes';
  final List<String> categories = ['All Notes', 'Word of God', 'Meeting Minutes', 'Personal Jottings', 'Class Jottings'];

  final List<NoteModel> dummyNotes = [
    NoteModel(
      id: '1',
      title: 'Sermon on the Mount Reflection',
      brief: 'The beatitudes offer a paradoxical view of blessing. "Blessed are the poor in spirit..." meaning that recognizing our...',
      category: 'Word of God',
      dateTime: DateTime.now(),
      timeAgo: '2 hours ago',
    ),
    NoteModel(
      id: '2',
      title: 'Q3 Design Sync',
      brief: '- Reviewed new brand tokens.\n- Action: Update spacing system to use 8px grid baseline...',
      category: 'Meeting Minutes',
      dateTime: DateTime.now(),
      timeAgo: 'Yesterday',
    ),
    NoteModel(
      id: '3',
      title: 'Grocery List & Errands',
      brief: 'Milk, Eggs, Whole wheat bread. Don\'t forget to pick up the dry cleaning on the way back from the studio. Also need t...',
      category: 'Personal Jottings',
      dateTime: DateTime.now(),
      timeAgo: 'Oct 12',
    ),
    NoteModel(
      id: '4',
      title: 'Advanced Typography 101',
      brief: 'Kerning vs Tracking. Kerning is the space between two specific letters (e.g., \'A\' and \'V\' often need adjustment)...',
      category: 'Class Jottings',
      dateTime: DateTime.now(),
      timeAgo: 'Oct 10',
    ),
    NoteModel(
      id: '5',
      title: 'Journal Entry: Quiet Productivity',
      brief: 'Today I realized the importance of digital wellness. By removing the unnecessary visual noise from my...',
      category: 'Personal Jottings',
      dateTime: DateTime.now(),
      timeAgo: 'Oct 05',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202124), // Updated to dark theme
      appBar: const Topbar(),
      body: Column(
        children: [
          const CustomSearchBar(),
          const SizedBox(height: 8),
          CategoryTabs(
            categories: categories,
            selectedCategory: selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                selectedCategory = category;
              });
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: dummyNotes.length,
              itemBuilder: (context, index) {
                return Notecard(note: dummyNotes[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
          );
        },
        backgroundColor: const Color(0xFF5C6CE1),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF202124), // Dark background
        selectedItemColor: const Color(0xFF5C6CE1),
        unselectedItemColor: Colors.white54, // Lighter unselected color
        showUnselectedLabels: true,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.label_outline),
            label: 'Labels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
