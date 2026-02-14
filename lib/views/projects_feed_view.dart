import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/project_service.dart';
import '../models/project_model.dart';
import '../models/offer_model.dart';
import '../providers/auth_provider.dart';
import 'project_workspace_view.dart';

class ProjectsFeedView extends StatefulWidget {
  const ProjectsFeedView({super.key});

  @override
  State<ProjectsFeedView> createState() => _ProjectsFeedViewState();
}

class _ProjectsFeedViewState extends State<ProjectsFeedView> {
  final ProjectService _service = ProjectService();

  @override
  Widget build(BuildContext context) {
    final contractorId = context.read<AuthProvider>().userModel?.uid ?? 'contractorId';

    return Scaffold(
      appBar: AppBar(title: const Text('Projects Feed')),
      body: StreamBuilder<List<ProjectModel>>(
        stream: _service.streamProjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final projects = snapshot.data ?? [];
          if (projects.isEmpty) return const Center(child: Text('No projects yet'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, i) {
              final p = projects[i];
              return Card(
                child: ListTile(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectWorkspaceView(projectId: p.id))),
                  title: Text(p.type),
                  subtitle: Text('${p.location} • ${p.minBudget.toInt()} - ${p.maxBudget.toInt()}'),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: () => _showOfferDialog(context, p, contractorId),
                    child: const Text('Offer'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showOfferDialog(BuildContext context, ProjectModel project, String contractorId) {
    final _priceCtrl = TextEditingController();
    final _msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Submit Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Price')),
            TextField(controller: _msgCtrl, decoration: const InputDecoration(labelText: 'Message')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final offer = OfferModel(id: '', projectId: project.id, contractorId: contractorId, price: double.tryParse(_priceCtrl.text) ?? 0, message: _msgCtrl.text, status: 'Submitted', createdAt: project.createdAt);
              final ok = await _service.submitOffer(offer);
              Navigator.pop(context);
              if (ok && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offer submitted')));
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
