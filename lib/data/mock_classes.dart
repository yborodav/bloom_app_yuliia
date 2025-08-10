import '../models/yoga_class.dart';

final List<YogaClass> mockClasses = [
  YogaClass(
    id: '1',
    title: 'Restorative Flow',
    description: 'Test restorative description',
    instructor: 'Leah',
    duration: 15,
    type: ClassType.restorative,
    coverPath: 'https://restorative.com',
    videoPath: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    averageRating: 0,
    reviewCount: 0
  ),
  YogaClass(
      id: '2',
      title: 'Morning meditation',
      description: 'Test meditationdescription',
      instructor: 'Yuliia',
      duration: 10,
      type: ClassType.meditation,
      coverPath: 'https://meditation.com',
      videoPath: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      averageRating: 0,
      reviewCount: 0
  ),
];