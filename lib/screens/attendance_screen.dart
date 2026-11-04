import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';
import '../providers/attendance_provider.dart';
import '../widgets/attendance_card.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key, required this.student});
  final Student student;
  Future<void> _addSubject(BuildContext context) async {
    final controller = TextEditingController();
    final key = GlobalKey<FormState>();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add subject'),
        content: Form(
          key: key,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Subject name'),
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Please enter a subject name.'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (key.currentState!.validate())
                Navigator.pop(ctx, controller.text);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && context.mounted)
      await context.read<AttendanceProvider>().addSubject(student.id, name);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(student.name),
      actions: [
        IconButton(
          onPressed: () => _addSubject(context),
          tooltip: 'Add subject',
          icon: const Icon(Icons.add),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _addSubject(context),
      icon: const Icon(Icons.add),
      label: const Text('Add subject'),
    ),
    body: Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        Student? current;
        for (final item in provider.students) {
          if (item.id == student.id) current = item;
        }
        if (current == null)
          return const Center(child: Text('Student not found.'));
        final active = current;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.insights, size: 34),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Overall attendance'),
                          Text(
                            '${active.attendancePercentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${active.presentClasses}/${active.totalClasses} classes',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (active.subjects.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'Add a subject to start tracking attendance.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...active.subjects.map(
                (subject) =>
                    AttendanceCard(studentId: active.id, subject: subject),
              ),
          ],
        );
      },
    ),
  );
}
