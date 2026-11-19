import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:student_attendance_tracker/main.dart';

void main() {
  testWidgets('a student with no recorded classes is not flagged as a shortage',
      (tester) async {
    final provider = AttendanceProvider()..addStudent('Sam Lee');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: provider, child: const MyApp()),
    );

    expect(find.text('Attendance Shortage'), findsNothing);
    expect(find.text('No classes recorded yet'), findsOneWidget);

    provider.markAbsent(0);
    await tester.pump();
    expect(find.text('Attendance Shortage'), findsOneWidget);
  });
}
