import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import '../models/offer_model.dart';

class ProjectService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> createProject(ProjectModel project) async {
    try {
      final doc = await _db.collection('projects').add(project.toMap());
      return doc.id;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<List<ProjectModel>> streamProjects({String? locationFilter, double? minBudget, double? maxBudget}) {
    Query query = _db.collection('projects').where('status', isEqualTo: 'Pending');
    if (locationFilter != null && locationFilter.isNotEmpty) query = query.where('location', isEqualTo: locationFilter);
    return query.snapshots().map((snap) => snap.docs.map((d) => ProjectModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());
  }

  Future<bool> submitOffer(OfferModel offer) async {
    try {
      await _db.collection('projects').doc(offer.projectId).collection('offers').add(offer.toMap());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Stream<List<OfferModel>> streamOffersForProject(String projectId) {
    return _db.collection('projects').doc(projectId).collection('offers').snapshots().map((snap) =>
      snap.docs.map((d) => OfferModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());
  }

  Future<bool> acceptOffer(String projectId, String offerId, OfferModel offer) async {
    try {
      // mark offer accepted
      final offerRef = _db.collection('projects').doc(projectId).collection('offers').doc(offerId);
      await offerRef.update({'status': 'Accepted'});
      // mark project active and set selectedOffer
      await _db.collection('projects').doc(projectId).update({'status': 'Active', 'selectedOffer': offerId, 'contractorId': offer.contractorId});
      // add simple notification for contractor
      try {
        final notif = {
          'type': 'offer_accepted',
          'projectId': projectId,
          'offerId': offerId,
          'message': 'Your offer was accepted',
          'createdAt': Timestamp.now(),
          'read': false,
        };
        await _db.collection('users').doc(offer.contractorId).collection('notifications').add(notif);
      } catch (e) {
        print('Notification write failed: $e');
      }

      // enqueue email request for background processor (Cloud Function or external worker)
      try {
        // read contractor email
        final uDoc = await _db.collection('users').doc(offer.contractorId).get();
        final contractorEmail = (uDoc.data() as Map<String, dynamic>?)?['email'] ?? '';
        final mailRequest = {
          'to': contractorEmail,
          'subject': 'Your offer was accepted',
          'body': 'Congratulations — your offer on project $projectId was accepted.',
          'projectId': projectId,
          'offerId': offerId,
          'createdAt': Timestamp.now(),
          'processed': false,
        };
        await _db.collection('mail_requests').add(mailRequest);
      } catch (e) {
        print('Mail enqueue failed: $e');
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
