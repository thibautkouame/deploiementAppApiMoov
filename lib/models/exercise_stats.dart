class ExerciseStats {
  final String id;
  final String userId;
  final double waterLiter;
  final double sleepHours;
  final double calories;
  final String bloodPressureBefore;
  final String sensationBefore;
  final String heartRateBefore;
  final String duration;
  final int repetition;
  final double caloriesBurned;
  final String sensationAfter;
  final String sensationDuring;
  final String bloodPressureAfter;
  final String heartRateAfter;
  final int theDay;
  final int theMonth;
  final int theYear;
  final DateTime date;
  final String exerciseTypeName;

  ExerciseStats({
    required this.id,
    required this.userId,
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
    required this.theDay,
    required this.theMonth,
    required this.theYear,
    required this.date,
    required this.exerciseTypeName,
  });

  factory ExerciseStats.fromJson(Map<String, dynamic> json) {
    return ExerciseStats(
      id: json['_id'],
      userId: json['user_id'],
      waterLiter: double.parse(json['water_liter']),
      sleepHours: double.parse(json['sleep_hours']),
      calories: double.parse(json['calories']),
      bloodPressureBefore: json['blood_pressure_before'],
      sensationBefore: json['sensation_before'],
      heartRateBefore: json['heart_rate_before'],
      duration: json['duration'],
      repetition: int.parse(json['repetition']),
      caloriesBurned: double.parse(json['calories_burned']),
      sensationAfter: json['sensation_after'],
      sensationDuring: json['sensation_during'],
      bloodPressureAfter: json['blood_pressure_after'],
      heartRateAfter: json['heart_rate_after'],
      theDay: int.parse(json['the_day']),
      theMonth: int.parse(json['the_month']),
      theYear: int.parse(json['the_year']),
      date: DateTime.parse(json['date']),
      exerciseTypeName: json['exercise_type_name'],
    );
  }
} 