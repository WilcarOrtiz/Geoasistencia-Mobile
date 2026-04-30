class ClassDay {
  final String id;
  final bool isActive;
  final String startTime;
  final String endTime;
  final int day;

  ClassDay({
    required this.id,
    required this.isActive,
    required this.startTime,
    required this.endTime,
    required this.day,
  });

  factory ClassDay.fromJson(Map<String, dynamic> json) => ClassDay(
    id: json['id'],
    isActive: json['is_active'],
    startTime: json['start_time'],
    endTime: json['end_time'],
    day: json['day'],
  );

  String get dayLabel {
    const labels = {
      0: 'Domingo',
      1: 'Lunes',
      2: 'Martes',
      3: 'Miércoles',
      4: 'Jueves',
      5: 'Viernes',
      6: 'Sábado',
    };
    return labels[day] ?? 'Día inválido';
  }
}
