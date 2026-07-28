import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // 1. GET ALL PET OWNERS (Real-time Stream)
  // ==========================================
  Stream<QuerySnapshot> getPetOwners() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'Pet Owner')
        .snapshots();
  }

  // ==========================================
  // 2. ADD NEW PET OWNER
  // ==========================================
  Future<String> addPetOwner({
    required String ownerId,
    required String fullName,
    required String phone,
    required String address,
    required String password,
  }) async {
    final emailHandle = fullName.toLowerCase().replaceAll(' ', '.');
    final generatedEmail = '$emailHandle@furryfriends.com';

    DocumentReference docRef = await _db.collection('users').add({
      'ownerId': ownerId,
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'email': generatedEmail,
      'password': password,
      'role': 'Pet Owner',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id; // Isinasauli ang Firestore Document ID
  }

  // ==========================================
  // 3. GET PETS OF A SPECIFIC OWNER
  // ==========================================
  Stream<QuerySnapshot> getPetsByOwnerDocId(String ownerDocId) {
    return _db
        .collection('pets')
        .where('ownerDocId', isEqualTo: ownerDocId)
        .snapshots();
  }

  // ==========================================
  // 4. ADD NEW PET LINKED TO AN OWNER
  // ==========================================
  Future<void> addPetToOwner({
    required String petId,
    required String ownerDocId,
    required String ownerId,
    required String petName,
    required String species,
    required String breed,
    required String gender,
    required String birthDate,
  }) async {
    await _db.collection('pets').add({
      'petId': petId,
      'ownerDocId': ownerDocId,
      'ownerId': ownerId,
      'petName': petName,
      'species': species,
      'breed': breed,
      'gender': gender,
      'birthDate': birthDate,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
