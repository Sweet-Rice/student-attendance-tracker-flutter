import 'subject.dart';

class Student {
  Student({required this.id, required this.name, List<Subject>? subjects})
    : subjects = subjects ?? [];
  final String id;
  final String name;
  final List<Subject> subjects;
  int get presentClasses =>
      subjects.fold(0, (total, subject) => total + subject.presentClasses);
  int get totalClasses =>
      subjects.fold(0, (total, subject) => total + subject.totalClasses);
  double get attendancePercentage =>
      totalClasses == 0 ? 0 : presentClasses / totalClasses * 100;
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subjects': subjects.map((s) => s.toJson()).toList(),
  };
  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id:
        json['id'] as String? ??
        DateTime.now().microsecondsSinceEpoch.toString(),
    name: json['name'] as String? ?? 'Student',
    subjects: (json['subjects'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Subject.fromJson)
        .toList(),
  );
}
