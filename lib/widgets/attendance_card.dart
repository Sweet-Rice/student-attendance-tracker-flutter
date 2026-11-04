import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subject.dart';
import '../providers/attendance_provider.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({
    super.key,
    required this.studentId,
    required this.subject,
  });
  final String studentId;
  final Subject subject;
  Future<void> _edit(BuildContext context) async {
    final present = TextEditingController(
      text: subject.presentClasses.toString(),
    );
    final total = TextEditingController(text: subject.totalClasses.toString());
    final key = GlobalKey<FormState>();
    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Correct ${subject.name} attendance'),
        content: Form(
          key: key,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: present,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Present'),
                  validator: _integer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: total,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total'),
                  validator: _integer,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (key.currentState!.validate() &&
                  int.parse(present.text) <= int.parse(total.text))
                Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (save == true && context.mounted)
      await context.read<AttendanceProvider>().correctAttendance(
        studentId,
        subject.name,
        presentClasses: int.parse(present.text),
        totalClasses: int.parse(total.text),
      );
    present.dispose();
    total.dispose();
  }

  String? _integer(String? value) {
    final parsed = int.tryParse(value ?? '');
    return parsed == null || parsed < 0 ? 'Enter 0 or more' : null;
  }

  @override
  Widget build(BuildContext context) {
    final pct = subject.attendancePercentage;
    final low = subject.totalClasses > 0 && pct < 75;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _edit(context),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${subject.presentClasses} present · ${subject.totalClasses} total',
                  ),
                ),
                Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: low ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: pct / 100,
              minHeight: 7,
              borderRadius: BorderRadius.circular(8),
              color: low ? Colors.red : Colors.green,
            ),
            if (low)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Attendance shortage: below 75%',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context
                        .read<AttendanceProvider>()
                        .markAttendance(studentId, subject.name, true),
                    icon: const Icon(Icons.check),
                    label: const Text('Present'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context
                        .read<AttendanceProvider>()
                        .markAttendance(studentId, subject.name, false),
                    icon: const Icon(Icons.close),
                    label: const Text('Absent'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
