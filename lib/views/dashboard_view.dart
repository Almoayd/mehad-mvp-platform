import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'create_project_view.dart';
import 'projects_feed_view.dart';
import 'offers_view.dart';
import 'admin_view.dart';
import 'profile_view.dart';
import 'project_workspace_view.dart';
import 'notifications_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.userModel?.role ?? 'Client';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // unread notifications badge
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(auth.userModel?.uid).collection('notifications').where('read', isEqualTo: false).snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox.shrink();
              final count = snap.data!.docs.length;
              return IconButton(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications),
                    if (count > 0)
                      Positioned(
                        right: 0,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      )
                  ],
                ),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsView())),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(child: Text(auth.userModel?.name ?? 'Mehad')),
            ListTile(title: const Text('Profile'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileView()))),
            ListTile(title: const Text('Notifications'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsView()))),
            if (role == 'Client') ListTile(title: const Text('Create Project'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateProjectView()))),
            if (role == 'Contractor') ListTile(title: const Text('Projects Feed'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsFeedView()))),
            ListTile(title: const Text('Offers'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OffersView()))),
            ListTile(title: const Text('Admin'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminView()))),
            ListTile(title: const Text('Logout'), onTap: () => context.read<AuthProvider>().signOut()),
          ],
        ),
      ),
      body: Center(
        child: Text('Welcome, ${auth.userModel?.name ?? 'User'} — Role: $role'),
      ),
    );
  }
}
