import 'package:flutter/material.dart';
import 'pet_management.dart'; // or your path

void main() {
  runApp(const SmartVetCareAdmin());
}

class SmartVetCareAdmin extends StatelessWidget {
  const SmartVetCareAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Vet Care Admin',
      home: const PetManagementScreen(), // Set to PetManagementScreen
    );
  }
}
