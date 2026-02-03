import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class DiscoveryView extends StatefulWidget {
  const DiscoveryView({super.key});

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  String _selectedFilter = 'All';
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final roles = ['All', 'Client', 'Contractor', 'Consultant'];

    return Scaffold(
      appBar: AppBar(
        title: Text('discovery'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              if (context.locale == const Locale('en')) {
                context.setLocale(const Locale('ar'));
              } else {
                context.setLocale(const Locale('en'));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('${'filter_by_role'.tr()}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: roles.map((role) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(role == 'All' ? 'all'.tr() : role.toLowerCase().tr()),
                          selected: _selectedFilter == role,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedFilter = role);
                          },
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _firebaseService.getUsers(_selectedFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // For MVP Mocking if Firebase is not connected
                final users = snapshot.hasData && snapshot.data!.isNotEmpty 
                  ? snapshot.data! 
                  : _getMockUsers(_selectedFilter);

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(user.name[0], style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.role.toLowerCase().tr(), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500)),
                            Text(user.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            Text(user.rating.toString()),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<UserModel> _getMockUsers(String filter) {
    final allMocks = [
      UserModel(uid: '1', email: 'a@m.com', name: 'Ahmed Ali', role: 'Contractor', description: 'Expert in building foundations and structure.', rating: 4.8),
      UserModel(uid: '2', email: 'b@m.com', name: 'Sara Smith', role: 'Consultant', description: 'Interior design consultant with 10 years experience.', rating: 4.9),
      UserModel(uid: '3', email: 'c@m.com', name: 'John Doe', role: 'Client', description: 'Looking for a new home construction.', rating: 4.5),
      UserModel(uid: '4', email: 'd@m.com', name: 'Khalid Mansour', role: 'Contractor', description: 'Specialized in electrical systems.', rating: 4.7),
    ];
    if (filter == 'All') return allMocks;
    return allMocks.where((u) => u.role == filter).toList();
  }
}
