import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateProjectView extends StatefulWidget {
  const CreateProjectView({super.key});

  @override
  State<CreateProjectView> createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends State<CreateProjectView> {
  final _typeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _minBudgetCtrl = TextEditingController();
  final _maxBudgetCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final ProjectService _service = ProjectService();

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().userModel;
    return Scaffold(
      appBar: AppBar(title: const Text('Create Project')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(controller: _typeCtrl, decoration: const InputDecoration(labelText: 'Project type')),
              const SizedBox(height: 8),
              TextField(controller: _locationCtrl, decoration: const InputDecoration(labelText: 'Location')),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(controller: _minBudgetCtrl, decoration: const InputDecoration(labelText: 'Min budget'))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _maxBudgetCtrl, decoration: const InputDecoration(labelText: 'Max budget'))),
              ]),
              const SizedBox(height: 8),
              TextField(controller: _descCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (user == null) return;
                  final project = ProjectModel(
                    id: '',
                    clientId: user.uid,
                    type: _typeCtrl.text,
                    location: _locationCtrl.text,
                    minBudget: double.tryParse(_minBudgetCtrl.text) ?? 0,
                    maxBudget: double.tryParse(_maxBudgetCtrl.text) ?? 0,
                    description: _descCtrl.text,
                    status: 'Pending',
                    createdAt: Timestamp.now(),
                  );
                  final id = await _service.createProject(project);
                  if (id != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project submitted')));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Submit project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
