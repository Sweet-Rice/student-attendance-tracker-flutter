class Subject {
  Subject({required this.name, this.presentClasses = 0, this.totalClasses = 0});
  final String name;
  int presentClasses;
  int totalClasses;
  double get attendancePercentage =>
      totalClasses == 0 ? 0 : presentClasses / totalClasses * 100;
  Map<String, dynamic> toJson() => {
    'name': name,
    'presentClasses': presentClasses,
    'totalClasses': totalClasses,
  };
  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
    name: json['name'] as String? ?? 'Subject',
    presentClasses: json['presentClasses'] as int? ?? 0,
    totalClasses: json['totalClasses'] as int? ?? 0,
  );
}
