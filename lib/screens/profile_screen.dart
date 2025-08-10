import 'package:bloom_app/theme/theme_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  User? user;
  Map<String, dynamic> userData = {};
  int classesThisWeek = 0;
  int totalClassesCompleted = 0;
  bool isVerifyingEmail = false;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  Future<void> _loadUserData() async {
    user = _auth.currentUser;
    if (user == null) return;
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    userData = doc.data() ?? {};
    await _countClasses();
    setState(() => isLoading = false);
  }
  Future<void> _countClasses() async {
    final now = DateTime.now();
    final startOfWeek =
    DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final snapshot = await FirebaseFirestore.instance
        .collection('user_progress')
        .doc(user!.uid)
        .collection('classes')
        .get();
    classesThisWeek = snapshot.docs.fold(0, (sum, doc) {
      final data = doc.data();
      final lastWatched = data['lastWatched'];
      final timesCompleted = (data['timesCompleted'] ?? 1);
      if (lastWatched is Timestamp &&
          lastWatched.toDate().isAfter(startOfWeek)) {
        return sum + (timesCompleted is int ? timesCompleted : 0);
      }
      return sum;
    });
    totalClassesCompleted = snapshot.docs.fold(0, (sum, doc) {
      final data = doc.data();
      final timesCompleted = data['timesCompleted'];
      return sum + (timesCompleted is int ? timesCompleted : 1);
    });
  }
  Future<void> _updateField(String field, String value) async {
    userData[field] = value;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({field: value});
    setState(() {});
  }
  Future<void> _updateGoal(int goal) async {
    userData['goalPerWeek'] = goal;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({'goalPerWeek': goal});
    setState(() {});
  }
  Future<void> _changeEmail(String newEmail) async {
    try {
      await user!.updateEmail(newEmail);
      await user!.sendEmailVerification();
      _showMessage('Email updated. Please verify.');
      _loadUserData();
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    }
  }
  Future<void> _resetPassword() async {
    await _auth.sendPasswordResetEmail(email: user!.email!);
    _showMessage('Password reset email sent.');
  }
  Future<void> _sendEmailVerification() async {
    setState(() => isVerifyingEmail = true);
    await user?.sendEmailVerification();
    int retries = 20;
    while (retries-- > 0) {
      await Future.delayed(const Duration(seconds: 3));
      await user?.reload();
      user = _auth.currentUser;
      if (user!.emailVerified) break;
    }
    setState(() => isVerifyingEmail = false);
    _showMessage(user!.emailVerified ? 'Email verified!' : 'Still not verified.');
  }
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
  @override
  Widget build(BuildContext context) {
    final fullName =
    '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
    final email = user?.email ?? '';
    final goal = userData['goalPerWeek'] ?? 3;
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          buildEditableField('Name', fullName, (value) {
            final parts = value.trim().split(' ');
            _updateField('firstName', parts.first);
            if (parts.length > 1) {
              _updateField('lastName', parts.sublist(1).join(' '));
            }
          }),
          buildEditableField('Email', email, (value) => _changeEmail(value)),
          if (user != null && !user!.emailVerified)
            ListTile(
              title: const Text('Email not verified'),
              trailing: ElevatedButton(
                onPressed: isVerifyingEmail ? null : _sendEmailVerification,
                child: const Text('Verify Now'),
              ),
            ),
          const Divider(height: 26),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Reset Password'),
            onTap: _resetPassword,
          ),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Manage Payment Method'),
            onTap: () {
              // TODO: Hook to Stripe/RevenueCat
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel),
            title: const Text('Cancel Subscription'),
            onTap: () {
              // TODO: Cancel logic
            },
          ),
          const Divider(height: 26),
          Text('Weekly Progress',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('You\'ve taken $classesThisWeek classes this week.'),
          Text('Total complete: $totalClassesCompleted'),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Weekly Goal:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: goal,
                onChanged: (val) {
                  if (val != null) _updateGoal(val);
                },
                items: List.generate(7, (i) => i + 1)
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
              ),
            ],
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Toggle Dark Mode'),
            onTap: () => ThemeController.toggleTheme(),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(height: 16),
          const Center(
              child:
              Text('Bloom v1.0.0', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
  Widget buildEditableField(String label, String value, Function(String) onSave) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          String temp = value;
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Edit $label'),
                content: TextField(
                  autofocus: true,
                  controller: TextEditingController(text: value),
                  onChanged: (val) => temp = val,
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () {
                      onSave(temp);
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
