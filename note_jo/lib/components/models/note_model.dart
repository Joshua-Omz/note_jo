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

  // Converts this object → a Map that dart:convert can turn into JSON text
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'brief': brief,
      'category': category,
      'dateTime': dateTime.toIso8601String(), // DateTime must be a String for JSON
      'timeAgo': timeAgo,
    };
  }

  // Reconstructs a NoteModel from a JSON map (the reverse operation)
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      brief: json['brief'] as String,
      category: json['category'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String), // String → DateTime
      timeAgo: json['timeAgo'] as String,
    );
  }
}
