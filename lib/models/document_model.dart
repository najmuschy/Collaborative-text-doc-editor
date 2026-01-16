class DocumentModel{
  final String uid;
  final String title ;
  final DateTime createdAt;
  final List<dynamic> content ;
  final String id;


  const DocumentModel({
    required this.uid,
    required this.title,
    required this.createdAt,
    required this.content,
    required this.id,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentModel &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          title == other.title &&
          createdAt == other.createdAt &&
          content == other.content &&
          id == other.id);

  @override
  int get hashCode =>
      uid.hashCode ^
      title.hashCode ^
      createdAt.hashCode ^
      content.hashCode ^
      id.hashCode;

  @override
  String toString() {
    return 'DocumentModel{' +
        ' uid: $uid,' +
        ' title: $title,' +
        ' createdAt: $createdAt,' +
        ' content: $content,' +
        ' id: $id,' +
        '}';
  }

  DocumentModel copyWith({
    String? uid,
    String? title,
    DateTime? createdAt,
    List<dynamic>? content,
    String? id,
  }) {
    return DocumentModel(
      uid: uid ?? this.uid,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'title': this.title,
      'createdAt': this.createdAt,
      'content': this.content,
      '_id': this.id,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      uid: map['uid'] as String,
      title: map['title'] as String,
      createdAt: DateTime.fromMicrosecondsSinceEpoch(map['createdAt']),
      content: map['content'] as List<dynamic>,
      id: map['_id'] as String,
    );
  }

  //</editor-fold>
}