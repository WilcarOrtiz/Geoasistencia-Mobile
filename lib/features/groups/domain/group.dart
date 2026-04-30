class Group {
  final String id;
  final String code;
  final String name;
  final int academicYear;
  final int maxStudents;
  final int totalStudents;
  final int totalSessions;
  final bool isActive;
  final Subject subject;
  final Semester semester;
  final Teacher teacher;

  Group({
    required this.id,
    required this.code,
    required this.name,
    required this.academicYear,
    required this.maxStudents,
    required this.totalStudents,
    required this.totalSessions,
    required this.isActive,
    required this.subject,
    required this.semester,
    required this.teacher,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
    id: json['id'],
    code: json['code'],
    name: json['name'],
    academicYear: json['academic_year'],
    maxStudents: json['max_students'],
    totalStudents: json['total_students'],
    totalSessions: json['total_sessions'],
    isActive: json['is_active'],
    subject: Subject.fromJson(json['subject']),
    semester: Semester.fromJson(json['semester']),
    teacher: Teacher.fromJson(json['teacher']),
  );
}

class Subject {
  final String id;
  final String name;
  Subject({required this.id, required this.name});
  factory Subject.fromJson(Map<String, dynamic> json) =>
      Subject(id: json['id'], name: json['name']);
}

class Semester {
  final String id;
  final String name;
  final String state;
  Semester({required this.id, required this.name, required this.state});
  factory Semester.fromJson(Map<String, dynamic> json) =>
      Semester(id: json['id'], name: json['name'], state: json['state']);
}

class Teacher {
  final String id;
  final String name;
  Teacher({required this.id, required this.name});
  factory Teacher.fromJson(Map<String, dynamic> json) =>
      Teacher(id: json['id'], name: json['name']);
}
