import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/yoga_class.dart';
import 'fullscreen_video_player.dart';

class VideoScreen extends StatefulWidget {
  final YogaClass yogaClass;
  const VideoScreen({super.key, required this.yogaClass});
  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _markedComplete = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(widget.yogaClass.videoPath);
      final downloadUrl = await storageRef.getDownloadURL();
      _controller = VideoPlayerController.network(downloadUrl);
      await _controller!.initialize();
      setState(() {
        _isLoading = false;
      });
      _controller!.addListener(() async {
        if (!_controller!.value.isInitialized) return;
        final position = _controller!.value.position;
        final duration = _controller!.value.duration;
        if (duration.inMilliseconds == 0) return;
        final progress = position.inMilliseconds / duration.inMilliseconds;
        if (progress >= 0.75 && !_markedComplete) {
          _markedComplete = true;
          await _markClassCompleted();
        }
      });
    } catch (e) {
      debugPrint('Video loading error: $e');
    }
  }

  Future<void> _markClassCompleted() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userProgressRef = FirebaseFirestore.instance
        .collection('user_progress')
        .doc(user.uid)
        .collection('classes')
        .doc(widget.yogaClass.id);
    final classDocRef = FirebaseFirestore.instance
        .collection('Classes')
        .doc(widget.yogaClass.id);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userProgressRef);
      final now = FieldValue.serverTimestamp();
      if (snapshot.exists) {
        transaction.update(userProgressRef, {
          'lastWatched': now,
          'timesCompleted': FieldValue.increment(1),
        });
      } else {
        transaction.set(userProgressRef, {
          'lastWatched': now,
          'timesCompleted': 1,
        });
      }
      transaction.update(classDocRef, {
        'viewCount': FieldValue.increment(1),
      });
    });
  }

  void _goFullScreen() {
    if (_controller != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenVideoPlayer(controller: _controller!),
        ),
      );
    }
  }

  void _showReviewDialog(BuildContext context) {
    int rating = 5;
    String comment = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Leave a Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<int>(
              value: rating,
              items: [1, 2, 3, 4, 5]
                  .map((r) => DropdownMenuItem(value: r, child: Text('$r stars')))
                  .toList(),
              onChanged: (val) => rating = val!,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Comment'),
              onChanged: (val) => comment = val,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;
              final currentAverage = widget.yogaClass.averageRating;
              final reviewCount = widget.yogaClass.reviewCount;
              final newAverage = ((currentAverage * reviewCount) + rating) / (reviewCount + 1);
              await FirebaseFirestore.instance
                  .collection('Classes')
                  .doc(widget.yogaClass.id)
                  .collection('Reviews')
                  .add({
                'userId': user.uid,
                'rating': rating,
                'comment': comment,
                'timestamp': FieldValue.serverTimestamp(),
              });
              FirebaseFirestore.instance
                  .collection('Classes')
                  .doc(widget.yogaClass.id)
                  .update({
                'averageRating': newAverage,
                'reviewCount': reviewCount + 1,
              });
              setState(() {
                widget.yogaClass.averageRating = newAverage;
                widget.yogaClass.reviewCount = reviewCount + 1;
              });
              Navigator.pop(context);
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final yogaClass = widget.yogaClass;
    return Scaffold(
      appBar: AppBar(title: Text(yogaClass.title)),
      body: _isLoading || _controller == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.fullscreen, size: 30, color: Colors.white),
                    onPressed: _goFullScreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      yogaClass.title,
                      style: const TextStyle(fontSize: 22),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        yogaClass.averageRating != null
                            ? yogaClass.averageRating!.toStringAsFixed(1)
                            : '—',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: Text('${yogaClass.instructor} • ${yogaClass.duration} min'),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(yogaClass.description),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.rate_review),
              label: Text("Leave a Review"),
              onPressed: () => _showReviewDialog(context),
            ),
          ],
        ),
      ),
      floatingActionButton: _controller != null
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
          });
        },
        child: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
      )
          : null,
    );
  }
}
