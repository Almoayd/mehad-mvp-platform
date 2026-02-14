import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/storage_service.dart';

class ProjectWorkspaceView extends StatefulWidget {
  final String projectId;
  const ProjectWorkspaceView({super.key, required this.projectId});

  @override
  State<ProjectWorkspaceView> createState() => _ProjectWorkspaceViewState();
}

class _ProjectWorkspaceViewState extends State<ProjectWorkspaceView> {
  final _msgCtrl = TextEditingController();
  final _db = FirebaseFirestore.instance;
  final _storage = StorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Workspace')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('projects').doc(widget.projectId).collection('messages').orderBy('createdAt').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(d['text'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (d['attachmentUrl'] != null) Text('Attachment: ${d['attachmentName']}', style: const TextStyle(fontSize: 12)),
                          Text(d['sender'] ?? ''),
                        ],
                      ),
                      onTap: d['attachmentUrl'] != null ? () {
                        // For MVP: open link in new tab (web) or print link
                        final url = d['attachmentUrl'];
                        print('Attachment URL: $url');
                      } : null,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Expanded(child: TextField(controller: _msgCtrl, decoration: const InputDecoration(hintText: 'Message'))),
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(withData: true);
                  if (result == null || result.files.isEmpty) return;
                  final file = result.files.first;
                  final bytes = file.bytes;
                  if (bytes == null) return;
                  final path = 'projects/${widget.projectId}/attachments/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
                  final url = await _storage.uploadBytes(path, bytes, contentType: file.mimeType);
                  if (url != null) {
                    await _db.collection('projects').doc(widget.projectId).collection('messages').add({
                      'text': _msgCtrl.text.trim(),
                      'sender': 'me',
                      'createdAt': Timestamp.now(),
                      'attachmentUrl': url,
                      'attachmentName': file.name,
                    });
                    _msgCtrl.clear();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  final text = _msgCtrl.text.trim();
                  if (text.isEmpty) return;
                  await _db.collection('projects').doc(widget.projectId).collection('messages').add({
                    'text': text,
                    'sender': 'me',
                    'createdAt': Timestamp.now(),
                  });
                  _msgCtrl.clear();
                },
              )
            ]),
          )
        ],
      ),
    );
  }
}
