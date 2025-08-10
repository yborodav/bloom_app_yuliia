import 'package:bloom_app/models/yoga_class.dart';
import 'package:bloom_app/screens/video_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
class YogaCard extends StatefulWidget {
  final YogaClass yogaClass;
  const YogaCard({super.key, required this.yogaClass});
  @override
  State<YogaCard> createState() => _YogaCardState();
}
class _YogaCardState extends State<YogaCard> {
  String? imageUrl;
  @override
  void initState() {
    super.initState();
    _loadImage();
  }
  Future<void> _loadImage() async {
    try {
      final ref = FirebaseStorage.instance.ref(widget.yogaClass.coverPath);
      final url = await ref.getDownloadURL();
      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      debugPrint('Error loading image: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final yogaClass = widget.yogaClass;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VideoScreen(yogaClass: yogaClass)),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            imageUrl != null
                ? Image.network(imageUrl!, height: 180, width: double.infinity, fit: BoxFit.cover)
                : Container(height: 180, color: Colors.grey.shade300),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    yogaClass.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${yogaClass.instructor} • ${yogaClass.duration} min',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        yogaClass.averageRating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${yogaClass.reviewCount})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
