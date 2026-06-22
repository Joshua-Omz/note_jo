class NoteModel {
  final String id;
  final String title;
  final String brief;
  final String category;
  final DateTime dateTime;
  final String timeAgo;

  NoteModel({
    required this.id,
    required this.title,
    required this.brief,
    required this.category,
    required this.dateTime,
    required this.timeAgo,
  });
}
