enum BlockType { heading, paragraph, quote, scripture, divider }

class NoteBlock {
  final String id;
  final BlockType type;
  final Map<String, dynamic> data;

  NoteBlock({required this.id, required this.type, required this.data});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
    };
  }

  factory NoteBlock.fromJson(Map<String, dynamic> json) {
    return NoteBlock(
      id: json['id'],
      type: BlockType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BlockType.paragraph,
      ),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}
