import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/yoga_class.dart';
import '../widgets/yoga_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ClassType? selectedType;
  int? selectedLength;
  String sortBy = 'recent';
  final List<int?> lengthOptions = [null, 10, 15, 30, 45];
  final Map<ClassType?, String> typeLabels = {
    null: 'All Classes',
    ClassType.vin: 'Vinyasa Flow',
    ClassType.restorative: 'Restorative',
    ClassType.adaptive: 'Adaptive',
    ClassType.meditation: 'Meditation',
    ClassType.learn: 'Learn Poses',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classes')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: sortBy,
                      underline: SizedBox(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.secondary,  // Use secondary color from theme
                      ),
                      items: const [
                        DropdownMenuItem(value: 'recent', child: Text('Most Recent')),
                        DropdownMenuItem(value: 'rating', child: Text('Best Rated')),
                        DropdownMenuItem(value: 'popular', child: Text('Most Popular')),
                      ],
                      onChanged: (val) => setState(() => sortBy = val!),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: DropdownButton<ClassType?>(
                      value: selectedType,
                      underline: SizedBox(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.secondary,  // Use secondary color from theme
                      ),
                      items: typeLabels.entries.map((entry) {
                        return DropdownMenuItem<ClassType?>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedType = value),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: DropdownButton<int?>(
                      value: selectedLength,
                      underline: SizedBox(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.secondary,  // Use secondary color from theme
                      ),
                      items: lengthOptions.map((length) {
                        return DropdownMenuItem<int?>(
                          value: length,
                          child: Text(length == null ? 'Any length' : '$length min'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedLength = value),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<YogaClass>>(
                stream: getClassesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading classes'));
                  }
                  final allClasses = snapshot.data ?? [];
                  final filtered = allClasses.where((c) {
                    final matchesType = selectedType == null || c.type == selectedType;
                    final matchesLength = selectedLength == null || c.duration == selectedLength;
                    return matchesType && matchesLength;
                  }).toList();
                  if (sortBy == 'rating') {
                    filtered.sort((a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0));
                  } else if (sortBy == 'popular') {
                    filtered.sort((a, b) => (b.views ?? 0).compareTo(a.views ?? 0));
                  } else if (sortBy == 'recent') {
                    filtered.sort((a, b) => (b.uploadTimestamp ?? DateTime(2000))
                        .compareTo(a.uploadTimestamp ?? DateTime(2000)));
                  }
                  return filtered.isEmpty
                      ? const Center(child: Text('No classes match your filters.'))
                      : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return YogaCard(yogaClass: filtered[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<YogaClass>> getClassesStream() {
    return FirebaseFirestore.instance.collection('Classes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return YogaClass.fromMap(data, doc.id);
      }).toList();
    });
  }
}
