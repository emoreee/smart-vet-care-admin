import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sidebar.dart';

class HealthMonitoringScreen extends StatefulWidget {
  const HealthMonitoringScreen({super.key});

  @override
  State<HealthMonitoringScreen> createState() => _HealthMonitoringScreenState();
}

class _HealthMonitoringScreenState extends State<HealthMonitoringScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _selectedServiceFilter = 'Checkup';
  final String _currentDoctorName = 'Dr. Tamesis';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openServiceRecordModal(
      String serviceType, Map<String, dynamic> petData) {
    showDialog(
      context: context,
      builder: (context) => ServiceRecordFormModal(
        serviceType: serviceType,
        petData: petData,
        attendingDoctor: _currentDoctorName,
      ),
    );
  }

  void _showAddServiceChoiceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String chosenService = 'Checkup';
        Map<String, dynamic>? selectedPetData;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: 580,
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.90),
                padding: const EdgeInsets.all(28),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Add Patient Record',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A))),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('1. SELECT SERVICE TYPE',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.5)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _DialogServiceCard(
                              title: 'CHECKUP',
                              icon: Icons.medical_services_outlined,
                              color: const Color(0xFF2563EB),
                              bgColor: const Color(0xFFEFF6FF),
                              isSelected: chosenService == 'Checkup',
                              onTap: () => setDialogState(
                                  () => chosenService = 'Checkup'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DialogServiceCard(
                              title: 'VACCINE',
                              icon: Icons.vaccines_outlined,
                              color: const Color(0xFF16A34A),
                              bgColor: const Color(0xFFF0FDF4),
                              isSelected: chosenService == 'Vaccination',
                              onTap: () => setDialogState(
                                  () => chosenService = 'Vaccination'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _DialogServiceCard(
                              title: 'SURGERY',
                              icon: Icons.healing_outlined,
                              color: const Color(0xFFDC2626),
                              bgColor: const Color(0xFFFEF2F2),
                              isSelected: chosenService == 'Surgery',
                              onTap: () => setDialogState(
                                  () => chosenService = 'Surgery'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DialogServiceCard(
                              title: 'GROOMING',
                              icon: Icons.content_cut_outlined,
                              color: const Color(0xFFD97706),
                              bgColor: const Color(0xFFFFFBEB),
                              isSelected: chosenService == 'Grooming',
                              onTap: () => setDialogState(
                                  () => chosenService = 'Grooming'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('2A. QUICK SELECT FROM CURRENT APPOINTMENTS',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                              letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      StreamBuilder<QuerySnapshot>(
                        stream: _db.collection('appointments').snapshots(),
                        builder: (context, apptSnapshot) {
                          final apptDocs = apptSnapshot.data?.docs ?? [];
                          final activeAppts = apptDocs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final status =
                                (data['status'] ?? '').toString().toLowerCase();
                            return status == 'confirmed' || status == 'pending';
                          }).toList();

                          if (activeAppts.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Text(
                                  'No active appointments at the moment.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                      fontStyle: FontStyle.italic)),
                            );
                          }

                          return Container(
                            constraints: const BoxConstraints(maxHeight: 140),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: activeAppts.length,
                              itemBuilder: (context, index) {
                                final apptData = activeAppts[index].data()
                                    as Map<String, dynamic>;
                                final petName = apptData['petName'] ??
                                    apptData['name'] ??
                                    'Pet';
                                final petId = apptData['petId'] ?? 'PET-00000';
                                final ownerName =
                                    apptData['ownerName'] ?? 'Owner';
                                final service =
                                    apptData['service'] ?? 'General Checkup';

                                final isSelected =
                                    selectedPetData?['petId'] == petId;

                                return ListTile(
                                  dense: true,
                                  selected: isSelected,
                                  selectedTileColor: const Color(0xFFEEF2FF),
                                  title: Text(
                                      '$petName ($petId) — Owner: $ownerName',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? const Color(0xFF4F46E5)
                                              : const Color(0xFF0F172A))),
                                  subtitle: Text(
                                      'Service: $service | Date: ${apptData['date'] ?? 'Today'}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B))),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle,
                                          color: Color(0xFF4F46E5), size: 18)
                                      : const Icon(Icons.radio_button_unchecked,
                                          color: Color(0xFF94A3B8), size: 18),
                                  onTap: () {
                                    setDialogState(() {
                                      selectedPetData = {
                                        'petId': petId,
                                        'petName': petName,
                                        'ownerName': ownerName,
                                        'breed': apptData['breed'] ?? 'Mixed',
                                      };
                                    });
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Center(
                          child: Text('— OR SEARCH FOR WALK-IN CLIENTS —',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.bold))),
                      const SizedBox(height: 12),
                      const Text('2B. SEARCH WALK-IN PATIENT',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      StreamBuilder<QuerySnapshot>(
                        stream: _db.collection('pets').snapshots(),
                        builder: (context, petSnapshot) {
                          final petDocs = petSnapshot.data?.docs ?? [];

                          return StreamBuilder<QuerySnapshot>(
                            stream: _db.collection('users').snapshots(),
                            builder: (context, userSnapshot) {
                              final userDocs = userSnapshot.data?.docs ?? [];

                              Map<String, String> userNames = {};
                              for (var uDoc in userDocs) {
                                final uData =
                                    uDoc.data() as Map<String, dynamic>;
                                final uName = uData['fullName'] ??
                                    uData['name'] ??
                                    'Owner';
                                final ownerId = uData['ownerId'] ??
                                    uData['ownerID'] ??
                                    uDoc.id;
                                userNames[ownerId.toString()] = uName;
                                userNames[uDoc.id] = uName;
                              }

                              List<Map<String, dynamic>> allPatients =
                                  petDocs.map((doc) {
                                final pData =
                                    doc.data() as Map<String, dynamic>;
                                final petName = pData['name'] ??
                                    pData['petName'] ??
                                    'Unnamed Pet';
                                final petId = pData['petId'] ?? doc.id;
                                final ownerIdKey =
                                    (pData['ownerId'] ?? pData['userId'] ?? '')
                                        .toString();
                                final resolvedOwner = pData['ownerName'] ??
                                    pData['fullName'] ??
                                    userNames[ownerIdKey] ??
                                    'N/A';
                                final ownerId =
                                    ownerIdKey.isNotEmpty ? ownerIdKey : 'N/A';

                                return {
                                  'petId': petId,
                                  'petName': petName,
                                  'ownerName': resolvedOwner,
                                  'ownerId': ownerId,
                                  'breed': pData['breed'] ??
                                      pData['species'] ??
                                      'Mixed',
                                };
                              }).toList();

                              return Autocomplete<Map<String, dynamic>>(
                                displayStringForOption: (option) =>
                                    'Owner: ${option['ownerName']} — Pet: ${option['petName']}',
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.trim().isEmpty) {
                                    return const Iterable<
                                        Map<String, dynamic>>.empty();
                                  }
                                  final query =
                                      textEditingValue.text.toLowerCase();
                                  return allPatients.where((patient) {
                                    final owner = patient['ownerName']
                                        .toString()
                                        .toLowerCase();
                                    final pet = patient['petName']
                                        .toString()
                                        .toLowerCase();
                                    return owner.contains(query) ||
                                        pet.contains(query);
                                  });
                                },
                                onSelected: (Map<String, dynamic> selection) {
                                  setDialogState(() {
                                    selectedPetData = selection;
                                  });
                                },
                                fieldViewBuilder: (context, controller,
                                    focusNode, onFieldSubmitted) {
                                  return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    style: const TextStyle(fontSize: 13),
                                    decoration: _inputDeco(
                                        'Type walk-in owner or pet name...'),
                                  );
                                },
                                optionsViewBuilder:
                                    (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4.0,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 464,
                                        constraints: const BoxConstraints(
                                            maxHeight: 180),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: options.length,
                                          itemBuilder: (context, index) {
                                            final option =
                                                options.elementAt(index);
                                            return InkWell(
                                              onTap: () => onSelected(option),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 10),
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          color: Color(
                                                              0xFFF1F5F9))),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Owner: ${option['ownerName']}  •  Pet: ${option['petName']}',
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                              0xFF0F172A)),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Pet ID: ${option['petId']}   |   Owner ID: ${option['ownerId']}',
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Color(
                                                              0xFF64748B)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      if (selectedPetData != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Text(
                            'Selected: ${selectedPetData!['petName']} (${selectedPetData!['petId']}) — Owner: ${selectedPetData!['ownerName']}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF166534)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              if (selectedPetData != null) {
                                Navigator.pop(context);
                                _openServiceRecordModal(
                                    chosenService, selectedPetData!);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please select an appointment or search a patient first!')),
                                );
                              }
                            },
                            child: const Text('Proceed to Record',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          const SidebarMenu(activeRoute: 'health_monitoring'),
          Expanded(
            child: Column(
              children: [
                const _TopHeader(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _db.collection('health_monitoring').snapshots(),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? [];

                      final filteredDocs = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final petName =
                            (data['petName'] ?? '').toString().toLowerCase();
                        final petId =
                            (data['petId'] ?? '').toString().toLowerCase();
                        final ownerName =
                            (data['ownerName'] ?? '').toString().toLowerCase();
                        final breed = (data['breed'] ?? data['species'] ?? '')
                            .toString()
                            .toLowerCase();

                        return petName.contains(_searchQuery) ||
                            petId.contains(_searchQuery) ||
                            ownerName.contains(_searchQuery) ||
                            breed.contains(_searchQuery);
                      }).toList();

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Monitoring > Pet Search',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B))),
                                    SizedBox(height: 4),
                                    Text(
                                      'Health Monitoring - Patient Registry',
                                      style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A)),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Manage separate Firestore databases for Checkup, Vaccination, Surgery, and Grooming logs.',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  onPressed: _showAddServiceChoiceDialog,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Add Patient Record',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                Expanded(
                                  child: _ServiceHeaderCard(
                                    title: 'CHECKUP',
                                    subtitle: 'Vitals & Diagnosis',
                                    icon: Icons.medical_services_outlined,
                                    color: const Color(0xFF2563EB),
                                    bgColor: const Color(0xFFEFF6FF),
                                    isSelected:
                                        _selectedServiceFilter == 'Checkup',
                                    onTap: () => setState(() =>
                                        _selectedServiceFilter = 'Checkup'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _ServiceHeaderCard(
                                    title: 'VACCINATION',
                                    subtitle: 'Batch & Administered',
                                    icon: Icons.vaccines_outlined,
                                    color: const Color(0xFF16A34A),
                                    bgColor: const Color(0xFFF0FDF4),
                                    isSelected:
                                        _selectedServiceFilter == 'Vaccination',
                                    onTap: () => setState(() =>
                                        _selectedServiceFilter = 'Vaccination'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _ServiceHeaderCard(
                                    title: 'SURGERY',
                                    subtitle: 'Treatment & Labs',
                                    icon: Icons.healing_outlined,
                                    color: const Color(0xFFDC2626),
                                    bgColor: const Color(0xFFFEF2F2),
                                    isSelected:
                                        _selectedServiceFilter == 'Surgery',
                                    onTap: () => setState(() =>
                                        _selectedServiceFilter = 'Surgery'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _ServiceHeaderCard(
                                    title: 'GROOMING',
                                    subtitle: 'Instructions & Allergies',
                                    icon: Icons.content_cut_outlined,
                                    color: const Color(0xFFD97706),
                                    bgColor: const Color(0xFFFFFBEB),
                                    isSelected:
                                        _selectedServiceFilter == 'Grooming',
                                    onTap: () => setState(() =>
                                        _selectedServiceFilter = 'Grooming'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          'Patient Registry — View Service: $_selectedServiceFilter',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A))),
                                      Container(
                                        width: 280,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: TextField(
                                          controller: _searchController,
                                          style: const TextStyle(fontSize: 12),
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Search by name, owner, or ID...',
                                            hintStyle: TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF94A3B8)),
                                            prefixIcon: Icon(Icons.search,
                                                size: 16,
                                                color: Color(0xFF94A3B8)),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(1.2),
                                      1: FlexColumnWidth(1.6),
                                      2: FlexColumnWidth(1.8),
                                      3: FlexColumnWidth(1.4),
                                      4: FlexColumnWidth(1.8),
                                      5: FlexColumnWidth(1.2),
                                    },
                                    defaultVerticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    children: [
                                      const TableRow(
                                        children: [
                                          _TableHeader('PET ID'),
                                          _TableHeader('PET NAME'),
                                          _TableHeader('OWNER'),
                                          _TableHeader('STATUS'),
                                          _TableHeader('WARD / BAY'),
                                          _TableHeader('ACTION'),
                                        ],
                                      ),
                                      for (var doc in filteredDocs)
                                        _buildRow(doc),
                                    ],
                                  ),
                                  if (filteredDocs.isEmpty)
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 40.0),
                                      child: Center(
                                        child: Text(
                                            'No patients found in registry.',
                                            style: TextStyle(
                                                color: Color(0xFF94A3B8),
                                                fontSize: 13,
                                                fontStyle: FontStyle.italic)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildRow(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final petId = data['petId'] ?? 'PET-00000';
    final petName = data['petName'] ?? data['name'] ?? 'Pet';
    final ownerName = data['ownerName'] ?? 'Owner';
    final status = (data['status'] ?? 'STABLE').toString().toUpperCase();
    final locationBay = data['locationBay'] ?? 'Recovery Bay';

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(petId,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
        Text(petName,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF0F172A))),
        Text(ownerName,
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
        _buildStatusBadge(status),
        Text(locationBay,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        InkWell(
          onTap: () => _openServiceRecordModal(_selectedServiceFilter, data),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text('Add $_selectedServiceFilter',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color textColor = const Color(0xFF16A34A);
    if (status == 'URGENT' || status == 'CRITICAL') {
      textColor = const Color(0xFFDC2626);
    } else if (status == 'RECOVERED' || status == 'DISCHARGED') {
      textColor = const Color(0xFF0D9488);
    } else if (status == 'OBSERVATION') {
      textColor = const Color(0xFFD97706);
    }
    return Text(status,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: textColor));
  }
}

InputDecoration _inputDeco(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
        fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5)),
  );
}

class _DialogServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _DialogServiceCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2.2 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : const Color(0xFF0F172A))),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 10, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

class _ServiceHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceHeaderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2.2 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : const Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

class ServiceRecordFormModal extends StatefulWidget {
  final String serviceType;
  final Map<String, dynamic> petData;
  final String attendingDoctor;

  const ServiceRecordFormModal({
    super.key,
    required this.serviceType,
    required this.petData,
    required this.attendingDoctor,
  });

  @override
  State<ServiceRecordFormModal> createState() => _ServiceRecordFormModalState();
}

class _ServiceRecordFormModalState extends State<ServiceRecordFormModal> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isSaving = false;
  bool _isLoadingAppointment = true;

  final TextEditingController _weightController =
      TextEditingController(text: '12.0');
  final TextEditingController _tempController =
      TextEditingController(text: '38.5');
  final TextEditingController _pulseController =
      TextEditingController(text: '110');

  String _selectedVaccineName = 'Anti-Rabies Vaccine';
  final TextEditingController _batchNumberController = TextEditingController();
  final TextEditingController _dateAdministeredController =
      TextEditingController(
    text: DateTime.now().toString().split(' ')[0],
  );
  final TextEditingController _administeredByController =
      TextEditingController();

  String _retrievedGroomingNotes =
      'Fetching grooming instructions and allergies from appointments...';
  final TextEditingController _groomingRemarksController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _administeredByController.text = widget.attendingDoctor;
    if (widget.serviceType == 'Grooming') {
      _fetchGroomingDataFromAppointments();
    } else {
      _isLoadingAppointment = false;
    }
  }

  void _fetchGroomingDataFromAppointments() async {
    try {
      final petId = widget.petData['petId'];
      final query = await _db
          .collection('appointments')
          .where('petId', isEqualTo: petId)
          .where('service', isEqualTo: 'Grooming')
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _retrievedGroomingNotes =
              data['notes'] ?? 'No specific instructions or allergies listed.';
          _isLoadingAppointment = false;
        });
      } else {
        setState(() {
          _retrievedGroomingNotes =
              'No matching Grooming appointment found. Default: No allergies specified.';
          _isLoadingAppointment = false;
        });
      }
    } catch (e) {
      setState(() {
        _retrievedGroomingNotes = 'Error retrieving appointment data: $e';
        _isLoadingAppointment = false;
      });
    }
  }

  void _saveRecord() async {
    setState(() => _isSaving = true);
    try {
      final petId = widget.petData['petId'] ?? 'PET-00000';
      final petName =
          widget.petData['petName'] ?? widget.petData['name'] ?? 'Pet';
      final ownerName = widget.petData['ownerName'] ?? 'Owner';

      String targetCollection = '';
      Map<String, dynamic> recordData = {
        'petId': petId,
        'petName': petName,
        'ownerName': ownerName,
        'doctor': widget.attendingDoctor,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (widget.serviceType == 'Checkup') {
        targetCollection = 'checkup_records';
        recordData.addAll({
          'weight': _weightController.text,
          'temperature': _tempController.text,
          'pulse': _pulseController.text,
        });
      } else if (widget.serviceType == 'Vaccination') {
        targetCollection = 'vaccination_records';
        recordData.addAll({
          'vaccineName': _selectedVaccineName,
          'batchLotNumber': _batchNumberController.text,
          'dateAdministered': _dateAdministeredController.text,
          'administeredBy': _administeredByController.text,
        });
      } else if (widget.serviceType == 'Surgery') {
        targetCollection = 'surgery_records';
        recordData.addAll({
          'weight': _weightController.text,
          'temperature': _tempController.text,
          'pulse': _pulseController.text,
        });
      } else if (widget.serviceType == 'Grooming') {
        targetCollection = 'grooming_records';
        recordData.addAll({
          'specialInstructionsAndAllergies': _retrievedGroomingNotes,
          'adminRemarks': _groomingRemarksController.text,
          'groomingStatus': 'Completed',
        });
      }

      await _db.collection(targetCollection).add(recordData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${widget.serviceType} record saved to "$targetCollection"!'),
              backgroundColor: const Color(0xFF166534)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error saving record: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final petName =
        widget.petData['petName'] ?? widget.petData['name'] ?? 'Pet';
    final petId = widget.petData['petId'] ?? 'PET-00000';

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('New ${widget.serviceType} Record ($petName - $petId)',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A))),
                IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.serviceType == 'Checkup' ||
                        widget.serviceType == 'Surgery') ...[
                      const Text('1. VITAL SIGNS (ADMIN RECORD)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                                  controller: _weightController,
                                  decoration: _inputDeco('Weight (kg)'))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: TextField(
                                  controller: _tempController,
                                  decoration: _inputDeco('Temp (°C)'))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: TextField(
                                  controller: _pulseController,
                                  decoration: _inputDeco('Pulse / HR'))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Text(
                          'Note: Clinical assessment, diagnosis, and treatment plans are handled directly by the attending veterinarian in the Doctor\'s Portal.',
                          style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF1E40AF),
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    if (widget.serviceType == 'Vaccination') ...[
                      const Text('VACCINATION LOG DETAILS',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16A34A))),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedVaccineName,
                        decoration: _inputDeco('1. Vaccine Name'),
                        items: const [
                          DropdownMenuItem(
                              value: 'Anti-Rabies Vaccine',
                              child: Text('Anti-Rabies Vaccine',
                                  style: TextStyle(fontSize: 13))),
                          DropdownMenuItem(
                              value: '5-in-1 Vaccine (DHPPiL / DHLPP)',
                              child: Text('5-in-1 Vaccine (DHPPiL / DHLPP)',
                                  style: TextStyle(fontSize: 13))),
                          DropdownMenuItem(
                              value: '4-in-1 Vaccine (FVRCP)',
                              child: Text('4-in-1 Vaccine (FVRCP)',
                                  style: TextStyle(fontSize: 13))),
                          DropdownMenuItem(
                              value: 'Feline Leukemia Vaccine (FeLV)',
                              child: Text('Feline Leukemia Vaccine (FeLV)',
                                  style: TextStyle(fontSize: 13))),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedVaccineName = val!),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                          controller: _batchNumberController,
                          decoration: _inputDeco('2. Batch / Lot Number')),
                      const SizedBox(height: 12),
                      TextField(
                          controller: _dateAdministeredController,
                          decoration: _inputDeco('3. Date Administered')),
                      const SizedBox(height: 12),
                      TextField(
                          controller: _administeredByController,
                          decoration: _inputDeco('4. Administered By / Staff')),
                    ],
                    if (widget.serviceType == 'Grooming') ...[
                      const Text('GROOMING — LINKED APPOINTMENT DATA',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD97706))),
                      const SizedBox(height: 12),
                      _isLoadingAppointment
                          ? const Center(child: CircularProgressIndicator())
                          : Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                      'Retrieved from Appointments Collection:',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFB45309))),
                                  const SizedBox(height: 6),
                                  Text(_retrievedGroomingNotes,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF78350F))),
                                ],
                              ),
                            ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _groomingRemarksController,
                        maxLines: 2,
                        decoration: _inputDeco(
                            'Admin Remarks / Completed Grooming Notes'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveRecord,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14)),
                  child: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Save to Firestore',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5)),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Smart Vet Care Portal',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF0F172A))),
          Row(
            children: const [
              Icon(Icons.help_outline, color: Color(0xFF64748B), size: 20),
              SizedBox(width: 12),
              Icon(Icons.grid_view, color: Color(0xFF64748B), size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String label;
  const _TableHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8))),
    );
  }
}
