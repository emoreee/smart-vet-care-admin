import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'user_account.dart'; // O 'pet_management.dart' / 'admin_dashboard.dart'

void main() async {
  // 1. Siguraduhing handa na ang Flutter engine bindings
  WidgetsFlutterBinding.ensureInitialized();

  // 2. I-initialize si Firebase gamit ang Web Credentials mo
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey:
            "YOUR_API_KEY_HERE", // Palitan ng tunay mong API Key mula sa Firebase Console
        authDomain: "furryfriendsanimalclinic-13da3.firebaseapp.com",
        projectId: "furryfriendsanimalclinic-13da3",
        storageBucket: "furryfriendsanimalclinic-13da3.appspot.com",
        messagingSenderId:
            "YOUR_MESSAGING_SENDER_ID", // Palitan ng Sender ID mo
        appId: "YOUR_APP_ID", // Palitan ng App ID mo
      ),
    );
    debugPrint("Firebase initialized successfully!");
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  runApp(const SmartVetCareAdmin());
}

class SmartVetCareAdmin extends StatelessWidget {
  const SmartVetCareAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Vet Care Admin',
      home:
          const UserAccountScreen(), // Pwede mong gawing UserAccountScreen() para ma-test ang UI!
    );
  }
}
