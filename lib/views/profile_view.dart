import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/storage_service.dart';
import '../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final StorageService _storage = StorageService();
  final _db = FirebaseFirestore.instance;
  bool _loading = false;

  Future<void> _uploadPortfolio() async {
    final auth = context.read<AuthProvider>();
    final uid = auth.userModel?.uid;
    if (uid == null) return;
    final result = await FilePicker.platform.pickFiles(withData: true, allowMultiple: true);
    if (result == null) return;
    setState(() => _loading = true);
    final urls = <String>[];
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null) continue;
      final path = 'users/$uid/portfolio/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final url = await _storage.uploadBytes(path, bytes, contentType: file.mimeType);
      if (url != null) urls.add(url);
    }
    if (urls.isNotEmpty) {
      final ref = _db.collection('users').doc(uid);
      await ref.set({'portfolio': FieldValue.arrayUnion(urls)}, SetOptions(merge: true));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Text(user?.name ?? '—', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(user?.description ?? ''),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loading ? null : _uploadPortfolio,
                icon: const Icon(Icons.upload_file),
                label: Text(_loading ? 'Uploading...' : 'Upload portfolio'),
              ),
              const SizedBox(height: 16),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox();
                  final data = snap.data!.data() as Map<String, dynamic>?;
                  final portfolio = data?['portfolio'] as List<dynamic>? ?? [];
                  if (portfolio.isEmpty) return const Text('No portfolio items');
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: portfolio.map((p) => SizedBox(width: 120, height: 80, child: Image.network(p.toString(), fit: BoxFit.cover))).toList(),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
