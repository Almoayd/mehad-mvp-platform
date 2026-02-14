import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/project_service.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirebaseService();
    final ps = ProjectService();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: fs.getUsers(null),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final users = snapshot.data!;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, i) => ListTile(title: Text(users[i].name), subtitle: Text(users[i].role)),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: ps.streamProjects(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final projects = snapshot.data!;
                return ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, i) => ListTile(title: Text(projects[i].type), subtitle: Text(projects[i].status)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
