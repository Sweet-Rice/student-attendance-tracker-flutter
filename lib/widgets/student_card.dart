import 'package:flutter/material.dart';

import '../models/student.dart';

class StudentCard extends StatelessWidget {
  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
    required this.onDelete,
  });
  final Student student;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    final pct = student.attendancePercentage;
    final low = student.totalClasses > 0 && pct < 75;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                child: Text(
                  student.name.trim().isEmpty
                      ? '?'
                      : student.name.trim()[0].toUpperCase(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${student.subjects.length} subjects · ${student.presentClasses}/${student.totalClasses} classes',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 9),
                    LinearProgressIndicator(
                      value: pct / 100,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(8),
                      color: low ? Colors.red : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    '${pct.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: low ? Colors.red : null,
                    ),
                  ),
                  if (low)
                    const Text(
                      'SHORTAGE',
                      style: TextStyle(fontSize: 9, color: Colors.red),
                    ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'delete', child: Text('Delete student')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
