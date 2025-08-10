import 'package:cloud_firestore/cloud_firestore.dart';

enum ClassType { vin, restorative, adaptive, meditation, learn }
ClassType? classTypeFromString(String? str) {
  switch (str) {
    case 'vin':
      return ClassType.vin;
    case 'restorative':
      return ClassType.restorative;
    case 'adaptive':
      return ClassType.adaptive;
    case 'meditation':
      return ClassType.meditation;
    case 'learn':
      return ClassType.learn;
    default:
      return null;
  }
}
String? classTypeToString(ClassType? type) {
  switch (type) {
    case ClassType.vin:
      return 'vin';
    case ClassType.restorative:
      return 'restorative';
    case ClassType.adaptive:
      return 'adaptive';
    case ClassType.meditation:
      return 'meditation';
    case ClassType.learn:
      return 'learn';
    default:
      return null;
  }
}
class YogaClass {
  final String id;
  final String title;
  final String instructor;
  final int duration;
  final String description;
  final String videoPath;
  final String coverPath;
  final ClassType? type;
  double averageRating;
  int reviewCount;
  DateTime? uploadTimestamp;
  int views;
  YogaClass({
    required this.id,
    required this.title,
    required this.instructor,
    required this.duration,
    required this.description,
    required this.videoPath,
    required this.coverPath,
    required this.type,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.uploadTimestamp,
    this.views = 0,
  });
  factory YogaClass.fromMap(Map<String, dynamic> data, String docId) {
    return YogaClass(
      id: docId,
      title: data['title'] ?? '',
      instructor: data['instructor'] ?? '',
      duration: data['duration'] ?? 0,
      description: data['description'] ?? '',
      videoPath: data['videoPath'] ?? '',
      coverPath: data['coverPath'] ?? '',
      type: classTypeFromString(data['type']),
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      uploadTimestamp: (data['uploaded'] as Timestamp?)?.toDate(),
      views: data['timesCompleted'] ?? 0,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'instructor': instructor,
      'duration': duration,
      'description': description,
      'videoPath': videoPath,
      'coverPath': coverPath,
      'type': classTypeToString(type),
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'uploadTimestamp': uploadTimestamp,
      'views': views,
    };
  }
}
