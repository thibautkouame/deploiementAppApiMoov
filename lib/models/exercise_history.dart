class ExerciseHistory {
  static Map<String, String> monthToNumber = {
    'Janvier': '1',
    'Février': '2',
    'Mars': '3',
    'Avril': '4',
    'Mai': '5',
    'Juin': '6',
    'Juillet': '7',
    'Août': '8',
    'Septembre': '9',
    'Octobre': '10',
    'Novembre': '11',
    'Décembre': '12',
  };

  final String id;
  final String userId;
  final String exerciseTypeName;
  final String waterLiter;
  final String sleepHours;
  final String calories;
  final String bloodPressureBefore;
  final String sensationBefore;
  final String heartRateBefore;
  final String duration;
  final String repetition;
  final String caloriesBurned;
  final String sensationAfter;
  final String sensationDuring;
  final String bloodPressureAfter;
  final String heartRateAfter;
  final String systolicPressureBefore;
  final String diastolicPressureBefore;
  final String systolicPressureAfter;
  final String diastolicPressureAfter;
  final String date;
  final String the_day;
  final String the_month;
  final String the_year;
  final String status;

  ExerciseHistory({
    required this.id,
    required this.userId,
    required this.exerciseTypeName,
    required this.waterLiter,
    required this.sleepHours,
    required this.calories,
    required this.bloodPressureBefore,
    required this.sensationBefore,
    required this.heartRateBefore,
    required this.duration,
    required this.repetition,
    required this.caloriesBurned,
    required this.sensationAfter,
    required this.sensationDuring,
    required this.bloodPressureAfter,
    required this.heartRateAfter,
    required this.systolicPressureBefore,
    required this.diastolicPressureBefore,
    required this.systolicPressureAfter,
    required this.diastolicPressureAfter,
    required this.date,
    required this.the_day,
    required this.the_month,
    required this.the_year,
    required this.status,
  });

  factory ExerciseHistory.fromJson(Map<String, dynamic> json) {
    String monthStr = json['the_month']?.toString() ?? '';
    String monthNumber = monthToNumber[monthStr] ?? DateTime.now().month.toString();

    return ExerciseHistory(
      id: json['_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      exerciseTypeName: json['exercise_type_name']?.toString() ?? '',
      waterLiter: json['water_liter']?.toString() ?? '0',
      sleepHours: json['sleep_hours']?.toString() ?? '0',
      calories: json['calories']?.toString() ?? '0',
      bloodPressureBefore: json['blood_pressure_before']?.toString() ?? '0/0',
      sensationBefore: json['sensation_before']?.toString() ?? '',
      heartRateBefore: json['heart_rate_before']?.toString() ?? '0',
      systolicPressureBefore: json['systolic_pressure_before']?.toString() ?? '0',
      diastolicPressureBefore: json['diastolic_pressure_before']?.toString() ?? '0',
      duration: json['duration']?.toString() ?? '0',
      repetition: json['repetition']?.toString() ?? '0',
      caloriesBurned: json['calories_burned']?.toString() ?? '0',
      sensationAfter: json['sensation_after']?.toString() ?? '',
      sensationDuring: json['sensation_during']?.toString() ?? '',
      bloodPressureAfter: json['blood_pressure_after']?.toString() ?? '0/0',
      heartRateAfter: json['heart_rate_after']?.toString() ?? '0',
      systolicPressureAfter: json['systolic_pressure_after']?.toString() ?? '0',
      diastolicPressureAfter: json['diastolic_pressure_after']?.toString() ?? '0',
      status: json['status']?.toString() ?? '0',
      date: json['date']?.toString() ?? DateTime.now().toIso8601String(),
      the_day: json['the_day']?.toString() ?? DateTime.now().day.toString(),
      the_month: monthNumber,
      the_year: json['the_year']?.toString() ?? DateTime.now().year.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'user_id': userId,
      'exercise_type_name': exerciseTypeName,
      'water_liter': waterLiter,
      'sleep_hours': sleepHours,
      'calories': calories,
      'blood_pressure_before': bloodPressureBefore,
      'sensation_before': sensationBefore,
      'heart_rate_before': heartRateBefore,
      'duration': duration,
      'repetition': repetition,
      'calories_burned': caloriesBurned,
      'sensation_after': sensationAfter,
      'sensation_during': sensationDuring,
      'blood_pressure_after': bloodPressureAfter,
      'heart_rate_after': heartRateAfter,
      'date': date,
      'the_day': the_day,
      'the_month': the_month,
      'the_year': the_year,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'ExerciseHistory(date: $date, exerciseType: $exerciseTypeName)';
  }
} 