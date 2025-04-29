class ExerciseType {
  final String id;
  final String name;
  final String description;
  final String details;
  final String duration;
  final String imageCover;
  final String videoUrl;

  ExerciseType({
    required this.id,
    required this.name,
    required this.description,
    required this.details,
    required this.duration,
    required this.imageCover,
    required this.videoUrl,
  });

  factory ExerciseType.fromJson(Map<String, dynamic> json) {
    return ExerciseType(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      details: json['details'],
      duration: json['duration'],
      imageCover: json['image_cover'],
      videoUrl: json['video_url'],
    );
  }
} 