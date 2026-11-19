
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AttendanceProvider(),
      child: const MyApp(),
    ),
  );
}

// STUDENT MODEL

class Student {
  String name;
  int totalClasses;
  int presentClasses;

  Student({
    required this.name,
    this.totalClasses = 0,
    this.presentClasses = 0,
  });

  double get percentage {
    if (totalClasses == 0) return 0;
    return (presentClasses / totalClasses) * 100;
  }

  int get absentClasses => totalClasses - presentClasses;
}

// PROVIDER

class AttendanceProvider extends ChangeNotifier {
  final List<Student> _students = [];

  List<Student> get students => _students;

  void addStudent(String name) {
    if (name.trim().isEmpty) return;

    _students.add(Student(name: name.trim()));
    notifyListeners();
  }

  void markPresent(int index) {
    _students[index].totalClasses++;
    _students[index].presentClasses++;
    notifyListeners();
  }

  void markAbsent(int index) {
    _students[index].totalClasses++;
    notifyListeners();
  }

  // Records one class for every student, all present (one-tap roll call).
  void markAllPresent() {
    for (final student in _students) {
      student.totalClasses++;
      student.presentClasses++;
    }
    notifyListeners();
  }

  void resetStudent(int index) {
    _students[index].totalClasses = 0;
    _students[index].presentClasses = 0;
    notifyListeners();
  }

  void deleteStudent(int index) {
    _students.removeAt(index);
    notifyListeners();
  }

  // OVERALL ATTENDANCE PERCENTAGE

  double get overallPercentage {
    int totalClasses = 0;
    int presentClasses = 0;

    for (Student student in _students) {
      totalClasses += student.totalClasses;
      presentClasses += student.presentClasses;
    }

    if (totalClasses == 0) return 0;

    return (presentClasses / totalClasses) * 100;
  }

  int get totalStudents => _students.length;

  int get totalPresent {
    return _students.fold(
      0,
      (sum, student) => sum + student.presentClasses,
    );
  }

  int get totalAbsent {
    return _students.fold(
      0,
      (sum, student) => sum + student.absentClasses,
    );
  }

  int get totalClasses {
    return _students.fold(
      0,
      (sum, student) => sum + student.totalClasses,
    );
  }
}

// MAIN APP

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const AttendanceScreen(),
    );
  }
}

// ATTENDANCE SCREEN

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text(
          'Student Attendance Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Mark all present',
            color: Colors.white,
            icon: const Icon(Icons.done_all),
            onPressed: provider.students.isEmpty
                ? null
                : () {
                    provider.markAllPresent();
                    final count = provider.totalStudents;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            'Marked $count student${count == 1 ? '' : 's'} present',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                  },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddStudentDialog(context),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // OVERALL ATTENDANCE CARD

            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                children: [
                  const Text(
                    'OVERALL ATTENDANCE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '${provider.overallPercentage.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  LinearProgressIndicator(
                    value: provider.overallPercentage / 100,
                    minHeight: 10,
                    backgroundColor: Colors.white30,
                    color: Colors.greenAccent,
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: [
                      summaryItem(
                        'Students',
                        '${provider.totalStudents}',
                      ),
                      summaryItem(
                        'Present',
                        '${provider.totalPresent}',
                      ),
                      summaryItem(
                        'Absent',
                        '${provider.totalAbsent}',
                      ),
                      summaryItem(
                        'Classes',
                        '${provider.totalClasses}',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // STUDENT LIST TITLE

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'INDIVIDUAL STUDENT ATTENDANCE',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // INDIVIDUAL STUDENT CARDS

            if (provider.students.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No students added yet!',
                  style: TextStyle(fontSize: 17),
                ),
              ),

            ...List.generate(
              provider.students.length,
              (index) {
                final student = provider.students[index];

                final percentage = student.percentage;
                final eligible = percentage >= 75;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        // STUDENT NAME

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                student.name,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                provider.deleteStudent(index);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // INDIVIDUAL PERCENTAGE

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Student Attendance',
                              style: TextStyle(fontSize: 15),
                            ),

                            Text(
                              '${percentage.toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: eligible
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade300,
                          color: eligible
                              ? Colors.green
                              : Colors.red,
                        ),

                        const SizedBox(height: 15),

                        // STUDENT DETAILS

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            summaryItem(
                              'Total',
                              '${student.totalClasses}',
                            ),
                            summaryItem(
                              'Present',
                              '${student.presentClasses}',
                            ),
                            summaryItem(
                              'Absent',
                              '${student.absentClasses}',
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // PRESENT AND ABSENT BUTTONS

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  provider.markPresent(index);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Present'),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  provider.markAbsent(index);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Absent'),
                              ),
                            ),
                          ],
                        ),

                        // ELIGIBILITY AND RESET

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              eligible
                                  ? 'Eligible (75%+)'
                                  : 'Attendance Shortage',

                              style: TextStyle(
                                color: eligible
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            TextButton.icon(
                              onPressed: () {
                                provider.resetStudent(index);
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // SUMMARY ITEM WIDGET

  Widget summaryItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // ADD STUDENT DIALOG

  void showAddStudentDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Student'),

          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Student Name',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                controller.dispose();
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context
                      .read<AttendanceProvider>()
                      .addStudent(controller.text);

                  Navigator.pop(dialogContext);
                  controller.dispose();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
