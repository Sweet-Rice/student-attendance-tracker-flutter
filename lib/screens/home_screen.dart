import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';
import '../providers/attendance_provider.dart';
import '../screens/attendance_screen.dart';
import '../screens/add_student_screen.dart';
import '../widgets/student_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Attendance tracker')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddStudentScreen()),
      ),
      icon: const Icon(Icons.person_add_alt_1),
      label: const Text('Add student'),
    ),
    body: Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        if (!provider.isLoaded)
          return const Center(child: CircularProgressIndicator());
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 800;
            final statWidth = wide
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  children: [
                    Text(
                      'Good day 👋',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Keep your class attendance on track.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: statWidth,
                          child: _StatCard(
                            icon: Icons.groups_2_outlined,
                            label: 'Students',
                            value: '${provider.totalStudents}',
                            color: const Color(0xFF4263EB),
                          ),
                        ),
                        SizedBox(
                          width: statWidth,
                          child: _StatCard(
                            icon: Icons.fact_check_outlined,
                            label: 'Overall attendance',
                            value:
                                '${provider.overallAttendance.toStringAsFixed(1)}%',
                            color:
                                provider.overallAttendance < 75 &&
                                    provider.students.any(
                                      (s) => s.totalClasses > 0,
                                    )
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Your students',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text('${provider.totalStudents} total'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (provider.students.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              const Icon(Icons.school_outlined, size: 44),
                              const SizedBox(height: 12),
                              const Text(
                                'No students yet',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const Text(
                                'Add a student to start tracking attendance.',
                              ),
                              const SizedBox(height: 14),
                              FilledButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddStudentScreen(),
                                  ),
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Add your first student'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...provider.students.map(
                        (student) => Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: StudentCard(
                            student: student,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AttendanceScreen(student: student),
                              ),
                            ),
                            onDelete: () => _confirmDelete(
                              context,
                              student.id,
                              student.name,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
  Future<void> _confirmDelete(
    BuildContext context,
    String id,
    String name,
  ) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete student?'),
        content: Text('Remove $name and all their attendance records?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes == true && context.mounted)
      await context.read<AttendanceProvider>().deleteStudent(id);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
