import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../services/project_service.dart';
import '../models/offer_model.dart';

class OffersView extends StatelessWidget {
  const OffersView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userId = auth.userModel?.uid;
    final ProjectService _service = ProjectService();

    if (userId == null) return const Scaffold(body: Center(child: Text('Not signed in')));

    return Scaffold(
      appBar: AppBar(title: const Text('Offers')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('projects').where('clientId', isEqualTo: userId).snapshots(),
        builder: (context, projSnap) {
          if (projSnap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final projects = projSnap.data?.docs ?? [];
          if (projects.isEmpty) return const Center(child: Text('You have no projects yet'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, i) {
              final pDoc = projects[i];
              final pData = pDoc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(pData['type'] ?? 'Project'),
                  subtitle: Text(pData['description'] ?? ''),
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('projects').doc(pDoc.id).collection('offers').orderBy('createdAt').snapshots(),
                      builder: (context, offersSnap) {
                        if (!offersSnap.hasData) return const Padding(padding: EdgeInsets.all(12), child: Text('Loading offers...'));
                        final offers = offersSnap.data!.docs;
                        if (offers.isEmpty) return const Padding(padding: EdgeInsets.all(12), child: Text('No offers yet'));
                        return Column(
                          children: offers.map((o) {
                            final data = o.data() as Map<String, dynamic>;
                            final offer = OfferModel.fromMap(data, o.id);
                            return ListTile(
                              title: Text('${offer.price.toStringAsFixed(0)}'),
                              subtitle: Text(offer.message),
                              trailing: offer.status == 'Submitted'
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        final ok = await _service.acceptOffer(pDoc.id, o.id, offer);
                                        if (ok && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offer accepted')));
                                      },
                                      child: const Text('Accept'),
                                    )
                                  : Text(offer.status),
                            );
                          }).toList(),
                        );
                      },
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
