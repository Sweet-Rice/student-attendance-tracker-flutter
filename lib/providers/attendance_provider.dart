import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/student.dart';
import '../models/subject.dart';

class AttendanceProvider extends ChangeNotifier {
  static const _storageKey = 'attendance_students_v1';
  final List<Student> _students = [];
  bool _isLoaded = false;
  List<Student> get students => List.unmodifiable(_students);
  bool get isLoaded => _isLoaded;
  int get totalStudents => _students.length;
  double get overallAttendance {
    final total = _students.fold<int>(0, (sum, s) => sum + s.totalClasses);
    final present = _students.fold<int>(0, (sum, s) => sum + s.presentClasses);
    return total == 0 ? 0 : present / total * 100;
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _students
          ..clear()
          ..addAll(
            decoded.whereType<Map<String, dynamic>>().map(Student.fromJson),
          );
      }
    } catch (_) {
      _students.clear();
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addStudent(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) return;
    _students.add(
      Student(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: clean,
      ),
    );
    await _save();
  }

  Future<void> deleteStudent(String id) async {
    _students.removeWhere((s) => s.id == id);
    await _save();
  }

  Future<void> addSubject(String id, String name) async {
    final clean = name.trim();
    final student = _findStudent(id);
    if (clean.isEmpty || student == null) return;
    if (student.subjects.any(
      (s) => s.name.toLowerCase() == clean.toLowerCase(),
    ))
      return;
    student.subjects.add(Subject(name: clean));
    await _save();
  }

  Future<void> markAttendance(
    String id,
    String subjectName,
    bool present,
  ) async {
    final subject = _findSubject(id, subjectName);
    if (subject == null) return;
    subject.totalClasses++;
    if (present) subject.presentClasses++;
    await _save();
  }

  Future<void> correctAttendance(
    String id,
    String subjectName, {
    required int presentClasses,
    required int totalClasses,
  }) async {
    final subject = _findSubject(id, subjectName);
    if (subject == null) return;
    final total = totalClasses < 0 ? 0 : totalClasses;
    subject
      ..totalClasses = total
      ..presentClasses = presentClasses.clamp(0, total).toInt();
    await _save();
  }

  Student? _findStudent(String id) {
    for (final s in _students) {
      if (s.id == id) return s;
    }
    return null;
  }

  Subject? _findSubject(String id, String name) {
    final student = _findStudent(id);
    if (student == null) return null;
    for (final subject in student.subjects) {
      if (subject.name == name) return subject;
    }
    return null;
  }

  Future<void> _save() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_students.map((s) => s.toJson()).toList()),
    );
  }
}
