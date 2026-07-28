import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sidebar.dart';

class PetManagementScreen extends StatefulWidget {
  const PetManagementScreen({super.key});

  @override
  State<PetManagementScreen> createState() => _PetManagementScreenState();
}

class _PetManagementScreenState extends State<PetManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  // Open "Add New Pet" Dialog
  Future<void> _openAddPetModal(int currentPetCount) async {
    final nextPetId = 'PET-${(currentPetCount + 1).toString().padLeft(5, '0')}';

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddPetModal(nextPetId: nextPetId),
    );
  }

  // Open "View Pet Details" Dialog
  void _openViewPetDetailsModal(Map<String, dynamic> pet, String ownerDocId) {
    showDialog(
      context: context,
      builder: (context) =>
          ViewPetDetailsModal(pet: pet, ownerDocId: ownerDocId),
    );
  }

  // 2. Upgraded "Update Patient Status" Dialog (Interactive Colored Cards)
  Future<void> _openUpdateStatusModal(
      String petDocId, String currentStatus) async {
    String selectedStatus = currentStatus;

    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(28),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Update Patient Status',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A))),
                      IconButton(
                        icon: const Icon(Icons.close,
                            size: 20, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                      'Select current health or clinic status of patient.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 20),
                  _buildStatusOptionCard(
                      'Active',
                      'Routine checkup / Outpatient',
                      const Color(0xFFDCFCE7),
                      const Color(0xFF15803D),
                      selectedStatus,
                      (val) => setModalState(() => selectedStatus = val)),
                  _buildStatusOptionCard(
                      'In Treatment',
                      'Under medical care or confinement',
                      const Color(0xFFFEF3C7),
                      const Color(0xFFD97706),
                      selectedStatus,
                      (val) => setModalState(() => selectedStatus = val)),
                  _buildStatusOptionCard(
                      'Discharged',
                      'Completed treatment & sent home',
                      const Color(0xFFF1F5F9),
                      const Color(0xFF475569),
                      selectedStatus,
                      (val) => setModalState(() => selectedStatus = val)),
                  _buildStatusOptionCard(
                      'Deceased',
                      'Patient passed away',
                      const Color(0xFFFEE2E2),
                      const Color(0xFFDC2626),
                      selectedStatus,
                      (val) => setModalState(() => selectedStatus = val)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                            style: TextStyle(color: Color(0xFF64748B))),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, selectedStatus),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Save Status',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    if (newStatus != null && mounted) {
      await FirebaseFirestore.instance.collection('pets').doc(petDocId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Patient status updated to $newStatus'),
            backgroundColor: const Color(0xFF166534),
          ),
        );
      }
    }
  }

  // 3. Open "Edit Pet Details" Dialog (Clickable & Functional)
  Future<void> _openEditPetModal(
      String petDocId, Map<String, dynamic> currentPet) async {
    await showDialog(
      context: context,
      builder: (context) =>
          EditPetModal(petDocId: petDocId, currentPet: currentPet),
    );
  }

  Widget _buildStatusOptionCard(String value, String subtitle, Color bgColor,
      Color textColor, String groupVal, Function(String) onTap) {
    final bool isSelected = value == groupVal;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => onTap(value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? bgColor.withOpacity(0.5) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isSelected ? textColor : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1.0),
          ),
          child: Row(
            children: [
              Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? textColor : const Color(0xFF94A3B8),
                  size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isSelected
                              ? textColor
                              : const Color(0xFF0F172A))),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          const SidebarMenu(activeRoute: 'pet_management'),
          Expanded(
            child: Column(
              children: [
                const _TopHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Title & ADD Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Pet Management',
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A)),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Manage patient records, track medical status, and owner details.',
                                  style: TextStyle(
                                      color: Color(0xFF64748B), fontSize: 13),
                                ),
                              ],
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('pets')
                                  .snapshots(),
                              builder: (context, snap) {
                                final count = snap.data?.docs.length ?? 0;
                                return ElevatedButton.icon(
                                  onPressed: () => _openAddPetModal(count),
                                  icon: const Icon(Icons.add,
                                      size: 18, color: Colors.white),
                                  label: const Text('Add New Pet',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 18),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Search & Table Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 360,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                    hintText: 'Search Pet ID or Pet Owner...',
                                    hintStyle: TextStyle(
                                        fontSize: 12, color: Color(0xFF94A3B8)),
                                    prefixIcon: Icon(Icons.search,
                                        size: 18, color: Color(0xFF94A3B8)),
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('pets')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(40.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  final allDocs = snapshot.data?.docs ?? [];

                                  final filteredDocs = allDocs.where((doc) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final petName = (data['petName'] ?? '')
                                        .toString()
                                        .toLowerCase();
                                    final petId = (data['petId'] ?? '')
                                        .toString()
                                        .toLowerCase();
                                    final ownerId = (data['ownerId'] ??
                                            data['ownerID'] ??
                                            '')
                                        .toString()
                                        .toLowerCase();

                                    return petName.contains(_searchQuery) ||
                                        petId.contains(_searchQuery) ||
                                        ownerId.contains(_searchQuery);
                                  }).toList();

                                  return Column(
                                    children: [
                                      Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(1.2), // PET ID
                                          1: FlexColumnWidth(2.0), // PET NAME
                                          2: FlexColumnWidth(
                                              2.2), // OWNER'S NAME
                                          3: FlexColumnWidth(1.8), // BREED
                                          4: FlexColumnWidth(1.5), // STATUS
                                          5: FlexColumnWidth(0.8), // ACTIONS
                                        },
                                        defaultVerticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        children: [
                                          const TableRow(
                                            children: [
                                              _TableHeader(
                                                  'PET ID'), // 4. RENAMED TO PET ID
                                              _TableHeader('PET NAME'),
                                              _TableHeader("OWNER'S NAME"),
                                              _TableHeader('BREED'),
                                              _TableHeader('STATUS'),
                                              _TableHeader('ACTIONS'),
                                            ],
                                          ),
                                          for (var doc in filteredDocs)
                                            _buildPetRow(doc),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Showing 1 to ${filteredDocs.length} of ${allDocs.length} entries',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B)),
                                          ),
                                          Row(
                                            children: [
                                              OutlinedButton(
                                                onPressed: null,
                                                style: OutlinedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 12)),
                                                child: const Text('Previous',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF94A3B8))),
                                              ),
                                              const SizedBox(width: 8),
                                              OutlinedButton(
                                                onPressed: null,
                                                style: OutlinedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 12)),
                                                child: const Text('Next',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF94A3B8))),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildPetRow(QueryDocumentSnapshot doc) {
    final pet = doc.data() as Map<String, dynamic>;
    final petDocId = doc.id;
    final petDisplayId = pet['petId'] ?? '#00000';
    final petName = pet['petName'] ?? 'N/A';
    final breed = pet['breed'] ?? 'N/A';
    final status = pet['status'] ?? 'Active';
    final ownerDocId = pet['ownerDocId'] ?? '';

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: Text(petDisplayId,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ),
        Row(
          children: [
            const Icon(Icons.pets, size: 16, color: Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Text(petName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF0F172A))),
          ],
        ),

        FutureBuilder<DocumentSnapshot>(
          future: ownerDocId.isNotEmpty
              ? FirebaseFirestore.instance
                  .collection('users')
                  .doc(ownerDocId.trim())
                  .get()
              : null,
          builder: (context, userSnap) {
            String ownerName = pet['ownerId'] ?? 'N/A';
            if (userSnap.hasData && userSnap.data!.exists) {
              final userData = userSnap.data!.data() as Map<String, dynamic>?;
              ownerName = userData?['fullName'] ?? ownerName;
            }
            return Text(ownerName,
                style: const TextStyle(fontSize: 13, color: Color(0xFF334155)));
          },
        ),

        Text(breed,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),

        Align(
          alignment: Alignment.centerLeft,
          child: _buildStatusBadge(status),
        ),

        // 1. ICONS INSIDE TRIPPLE DOTS MENU
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz, color: Color(0xFF94A3B8)),
          onSelected: (action) {
            if (action == 'view_pet') {
              _openViewPetDetailsModal(pet, ownerDocId);
            } else if (action == 'update_status') {
              _openUpdateStatusModal(petDocId, status);
            } else if (action == 'edit_pet') {
              _openEditPetModal(petDocId, pet);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_pet',
              child: Row(
                children: [
                  Icon(Icons.remove_red_eye_outlined,
                      size: 16, color: Color(0xFF4F46E5)),
                  SizedBox(width: 10),
                  Text('View Pet Details',
                      style: TextStyle(fontSize: 12, color: Color(0xFF0F172A))),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'update_status',
              child: Row(
                children: [
                  Icon(Icons.published_with_changes,
                      size: 16, color: Color(0xFF0F172A)),
                  SizedBox(width: 10),
                  Text('Update Patient Status',
                      style: TextStyle(fontSize: 12, color: Color(0xFF0F172A))),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit_pet',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 10),
                  Text('Edit Pet Details',
                      style: TextStyle(fontSize: 12, color: Color(0xFF0F172A))),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'In Treatment':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        break;
      case 'Discharged':
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
        break;
      case 'Deceased':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case 'Active':
      default:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }
}

// ==========================================
// 5. REDESIGNED VIEW PET DETAILS MODAL (HERO)
// ==========================================
class ViewPetDetailsModal extends StatelessWidget {
  final Map<String, dynamic> pet;
  final String ownerDocId;

  const ViewPetDetailsModal({
    super.key,
    required this.pet,
    required this.ownerDocId,
  });

  Widget _buildInfoCard(String label, String value, IconData icon,
      {Color? accentColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (accentColor ?? const Color(0xFF4F46E5)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon,
                size: 16, color: accentColor ?? const Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value.isNotEmpty ? value : 'N/A',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A)),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petName = pet['petName'] ?? 'N/A';
    final petId = pet['petId'] ?? '#00000';
    final species = pet['species'] ?? 'N/A';
    final breed = pet['breed'] ?? 'N/A';
    final gender = pet['gender'] ?? 'N/A';
    final birthDate = pet['birthDate'] ?? 'N/A';
    final markings = pet['petColorAndMarkings'] ?? 'None specified';
    final status = pet['status'] ?? 'Active';

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.pets,
                            size: 26, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(petName,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(height: 2),
                          Text('Pet ID: $petId',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 20, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Owner Details Card
            FutureBuilder<DocumentSnapshot>(
              future: ownerDocId.isNotEmpty
                  ? FirebaseFirestore.instance
                      .collection('users')
                      .doc(ownerDocId.trim())
                      .get()
                  : null,
              builder: (context, userSnap) {
                String ownerName = pet['ownerId'] ?? 'N/A';
                String phone = 'N/A';
                if (userSnap.hasData && userSnap.data!.exists) {
                  final userData =
                      userSnap.data!.data() as Map<String, dynamic>?;
                  ownerName = userData?['fullName'] ?? ownerName;
                  phone = userData?['phone'] ?? phone;
                }
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_pin_outlined,
                          color: Color(0xFF4F46E5), size: 24),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('REGISTERED OWNER',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4F46E5))),
                          Text('$ownerName (${pet['ownerId'] ?? ''})',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A))),
                          Text('Contact: $phone',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Details Grid
            Row(
              children: [
                Expanded(
                    child: _buildInfoCard(
                        "SPECIES", species, Icons.category_outlined)),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildInfoCard(
                        "BREED", breed, Icons.merge_type_outlined)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _buildInfoCard("GENDER", gender, Icons.wc_outlined)),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildInfoCard(
                        "DATE OF BIRTH", birthDate, Icons.cake_outlined)),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
                "COLOR & MARKINGS", markings, Icons.palette_outlined),
            const SizedBox(height: 10),
            _buildInfoCard("PATIENT STATUS", status, Icons.info_outline,
                accentColor: const Color(0xFF166534)),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Close Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 1. UPGRADED EDIT PET DETAILS MODAL
// ==========================================
class EditPetModal extends StatefulWidget {
  final String petDocId;
  final Map<String, dynamic> currentPet;

  const EditPetModal({
    super.key,
    required this.petDocId,
    required this.currentPet,
  });

  @override
  State<EditPetModal> createState() => _EditPetModalState();
}

class _EditPetModalState extends State<EditPetModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _petNameController;
  late TextEditingController _breedController;
  late TextEditingController _birthDateController;
  late TextEditingController _markingsController;

  late String _species;
  late String _gender;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _petNameController =
        TextEditingController(text: widget.currentPet['petName'] ?? '');
    _breedController =
        TextEditingController(text: widget.currentPet['breed'] ?? '');
    _birthDateController =
        TextEditingController(text: widget.currentPet['birthDate'] ?? '');
    _markingsController = TextEditingController(
        text: widget.currentPet['petColorAndMarkings'] ?? '');

    _species = widget.currentPet['species'] ?? 'Dog';
    _gender = widget.currentPet['gender'] ?? 'Male';
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    _birthDateController.dispose();
    _markingsController.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(String label, {String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5)),
    );
  }

  // Calendar Picker Function
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F172A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final formattedMonth = picked.month.toString().padLeft(2, '0');
        final formattedDay = picked.day.toString().padLeft(2, '0');
        controller.text = "${picked.year}-$formattedMonth-$formattedDay";
      });
    }
  }

  void _updatePetInFirestore() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        await FirebaseFirestore.instance
            .collection('pets')
            .doc(widget.petDocId)
            .update({
          'petName': _petNameController.text.trim(),
          'species': _species,
          'breed': _breedController.text.trim(),
          'birthDate': _birthDateController.text.trim(),
          'gender': _gender,
          'petColorAndMarkings': _markingsController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pet details updated successfully!'),
              backgroundColor: Color(0xFF166534),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error updating pet: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final petDisplayId = widget.currentPet['petId'] ?? '#00000';

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Styled Header with Pet ID Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("Edit Pet Details",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A))),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(petDisplayId,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4F46E5))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                          "Update patient information and medical attributes.",
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Pet Name
              TextFormField(
                controller: _petNameController,
                decoration: _inputDeco('Pet Name*'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Species & Gender Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _species,
                      decoration: _inputDeco('Species*'),
                      items: ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => _species = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: _inputDeco('Gender*'),
                      items: ['Male', 'Female']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => _gender = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Breed & Date of Birth (with Calendar Popup)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _breedController,
                      decoration: _inputDeco('Breed*'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _birthDateController,
                      readOnly: true,
                      onTap: () => _selectDate(context, _birthDateController),
                      decoration: _inputDeco(
                        'Date of Birth*',
                        hint: 'YYYY-MM-DD',
                        suffixIcon: const Icon(Icons.calendar_today_outlined,
                            size: 18, color: Color(0xFF64748B)),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Color & Markings
              TextFormField(
                controller: _markingsController,
                decoration: _inputDeco('Color & Markings'),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _updatePetInFirestore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Update Pet Record',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. UPGRADED ADD NEW PET MODAL (WITH CALENDAR)
// ==========================================
class AddPetModal extends StatefulWidget {
  final String nextPetId;
  const AddPetModal({super.key, required this.nextPetId});

  @override
  State<AddPetModal> createState() => _AddPetModalState();
}

class _AddPetModalState extends State<AddPetModal> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedOwnerDocId;
  String? _selectedOwnerId;
  String? _selectedOwnerName;

  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _markingsController = TextEditingController();

  String _species = 'Dog';
  String _gender = 'Male';
  bool _isSaving = false;

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    _birthDateController.dispose();
    _markingsController.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(String label,
      {String? hint, Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5)),
    );
  }

  // Calendar Picker Function
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F172A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final formattedMonth = picked.month.toString().padLeft(2, '0');
        final formattedDay = picked.day.toString().padLeft(2, '0');
        controller.text = "${picked.year}-$formattedMonth-$formattedDay";
      });
    }
  }

  void _savePetToFirestore() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedOwnerDocId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select a Pet Owner first!'),
              backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isSaving = true);

      try {
        await FirebaseFirestore.instance.collection('pets').add({
          'petId': widget.nextPetId,
          'petName': _petNameController.text.trim(),
          'species': _species,
          'breed': _breedController.text.trim(),
          'birthDate': _birthDateController.text.trim(),
          'gender': _gender,
          'petColorAndMarkings': _markingsController.text.trim(),
          'ownerDocId': _selectedOwnerDocId,
          'ownerId': _selectedOwnerId,
          'status': 'Active',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Successfully registered ${_petNameController.text.trim()}!'),
              backgroundColor: const Color(0xFF166534),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error saving pet: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add New Pet',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      Text('Assigned Pet ID: ${widget.nextPetId}',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_selectedOwnerDocId != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_pin_outlined,
                              color: Color(0xFF4F46E5), size: 22),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_selectedOwnerName ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF0F172A))),
                              Text('ID: ${_selectedOwnerId ?? ''}',
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedOwnerDocId = null;
                            _selectedOwnerId = null;
                            _selectedOwnerName = null;
                          });
                        },
                        child: const Text('Change Owner',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4F46E5),
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, userSnap) {
                    final users = userSnap.data?.docs ?? [];

                    return Autocomplete<QueryDocumentSnapshot>(
                      displayStringForOption: (doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = data['fullName'] ?? '';
                        final id = data['ownerID'] ?? data['ownerId'] ?? '';
                        return '$name ($id)';
                      },
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.trim().isEmpty) {
                          return const Iterable<QueryDocumentSnapshot>.empty();
                        }
                        final query = textEditingValue.text.toLowerCase();
                        return users.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name =
                              (data['fullName'] ?? '').toString().toLowerCase();
                          final id = (data['ownerID'] ?? data['ownerId'] ?? '')
                              .toString()
                              .toLowerCase();
                          final phone =
                              (data['phone'] ?? '').toString().toLowerCase();
                          return name.contains(query) ||
                              id.contains(query) ||
                              phone.contains(query);
                        });
                      },
                      onSelected: (doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        setState(() {
                          _selectedOwnerDocId = doc.id;
                          _selectedOwnerId =
                              data['ownerID'] ?? data['ownerId'] ?? '';
                          _selectedOwnerName = data['fullName'] ?? '';
                        });
                      },
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: _inputDeco(
                            'Search Pet Owner*',
                            hint: 'Type Owner Name or Owner ID...',
                            prefixIcon: const Icon(Icons.search,
                                size: 18, color: Color(0xFF94A3B8)),
                          ),
                          validator: (v) => _selectedOwnerDocId == null
                              ? 'Please select a pet owner'
                              : null,
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 456,
                              constraints: const BoxConstraints(maxHeight: 180),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(
                                        height: 1, color: Color(0xFFF1F5F9)),
                                itemBuilder: (BuildContext context, int index) {
                                  final doc = options.elementAt(index);
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final name = data['fullName'] ?? 'Unknown';
                                  final ownerId = data['ownerID'] ??
                                      data['ownerId'] ??
                                      'OWN-00000';
                                  final phone = data['phone'] ?? '';

                                  return ListTile(
                                    dense: true,
                                    title: Text(name,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A))),
                                    subtitle: Text('$ownerId • $phone',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B))),
                                    onTap: () => onSelected(doc),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _petNameController,
                decoration: _inputDeco('Pet Name*', hint: 'e.g., Mokang'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter pet name'
                    : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _species,
                      decoration: _inputDeco('Species*'),
                      items: ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => _species = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: _inputDeco('Gender*'),
                      items: ['Male', 'Female']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => _gender = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _breedController,
                      decoration: _inputDeco('Breed*', hint: 'e.g., Shih Tzu'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _birthDateController,
                      readOnly: true,
                      onTap: () => _selectDate(context, _birthDateController),
                      decoration: _inputDeco(
                        'Date of Birth*',
                        hint: 'YYYY-MM-DD',
                        suffixIcon: const Icon(Icons.calendar_today_outlined,
                            size: 18, color: Color(0xFF64748B)),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _markingsController,
                decoration: _inputDeco('Color & Markings',
                    hint: 'e.g., Brown with white paws'),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _savePetToFirestore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Register Pet Record',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
              SizedBox(width: 16),
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
