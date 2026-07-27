import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'pet_profile.dart';

class PetManagementScreen extends StatelessWidget {
  const PetManagementScreen({super.key});

  // Open Add New Pet Intake Dialog
  void _showAddPetModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const _AddPetRegistrationDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Shared Navigation Sidebar
          const SidebarMenu(activeRoute: 'pet_management'),

          // Main Workspace Area
          Expanded(
            child: Column(
              children: [
                const _TopHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page Header Title & Action Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Pet Management',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Manage patient records, track medical status, and owner details.',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showAddPetModal(context),
                              icon: const Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Add New Pet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Registry Table Card
                        const _PetRegistryTableCard(),
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
}

// ==========================================
// TOP HEADER
// ==========================================
class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.grid_view,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'Admin Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Clinic Manager',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFE2E8F0),
                child: Icon(Icons.person, color: Color(0xFF64748B), size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// PET REGISTRY TABLE CARD
// ==========================================
class _PetRegistryTableCard extends StatelessWidget {
  const _PetRegistryTableCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Table Search Bar
          Row(
            children: [
              SizedBox(
                width: 300,
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Pet ID or Pet Owner',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF0F172A)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Custom Data Table
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1.8),
              2: FlexColumnWidth(1.8),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.2),
              5: FlexColumnWidth(0.6),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(
                children: [
                  _TableHeader('ID NUMBER'),
                  _TableHeader('PET NAME'),
                  _TableHeader('OWNER\'S NAME'),
                  _TableHeader('BREED'),
                  _TableHeader('STATUS'),
                  _TableHeader('ACTIONS'),
                ],
              ),
              _buildPetRow(
                context,
                '#00001',
                'Ming Ming Agravante',
                'Junexene Agravante',
                'Aspin',
                'Active',
                const Color(0xFFDCFCE7),
                const Color(0xFF166534),
              ),
              _buildPetRow(
                context,
                '#00002',
                'Cooper',
                'Sarah Jenkins',
                'Beagle',
                'In Treatment',
                const Color(0xFFFEF3C7),
                const Color(0xFFD97706),
              ),
              _buildPetRow(
                context,
                '#00003',
                'Luna',
                'Michael Chen',
                'Maine Coon',
                'Discharged',
                const Color(0xFFF1F5F9),
                const Color(0xFF64748B),
              ),
              _buildPetRow(
                context,
                '#00004',
                'Max',
                'Emily Rodriguez',
                'French Bulldog',
                'Active',
                const Color(0xFFDCFCE7),
                const Color(0xFF166534),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pagination Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Showing 1 to 4 of 12 entries',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(color: Color(0xFF0F172A), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildPetRow(
    BuildContext context,
    String id,
    String petName,
    String owner,
    String breed,
    String status,
    Color bg,
    Color fg,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            id,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PetProfileScreen(petName: petName, petId: id),
              ),
            );
          },
          child: Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(Icons.person, size: 14, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 8),
              Text(
                petName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        Text(
          owner,
          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
        ),
        Text(
          breed,
          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: fg,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // TRIPLE DOTS ACTION MENU (PET MANAGEMENT)
        _PetActionsMenu(petName: petName, petId: id),
      ],
    );
  }
}

// ==========================================
// PET MANAGEMENT TRIPLE DOTS ACTION MENU
// ==========================================
class _PetActionsMenu extends StatelessWidget {
  final String petName;
  final String petId;

  const _PetActionsMenu({required this.petName, required this.petId});

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'view_profile':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PetProfileScreen(petName: petName, petId: petId),
          ),
        );
        break;
      case 'edit_pet':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Editing details for $petName ($petId)...')),
        );
        break;
      case 'update_status':
        _showUpdateStatusDialog(context);
        break;
      case 'book_appointment':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening Appointment Booking for $petName...'),
            backgroundColor: const Color(0xFF166534),
          ),
        );
        break;
      case 'add_clinical_note':
        _showAddClinicalNoteDialog(context);
        break;
      case 'archive_delete':
        _showArchiveDeleteDialog(context);
        break;
    }
  }

  // UPDATE PATIENT STATUS DIALOG
  void _showUpdateStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Update Status: $petName',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 18,
                ),
                title: const Text('Active', style: TextStyle(fontSize: 12)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.local_hospital_outlined,
                  color: Colors.orange,
                  size: 18,
                ),
                title: const Text(
                  'In Treatment',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.home_outlined,
                  color: Colors.blue,
                  size: 18,
                ),
                title: const Text('Discharged', style: TextStyle(fontSize: 12)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.grey,
                  size: 18,
                ),
                title: const Text(
                  'Deceased / Inactive',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // ADD CLINICAL NOTE / PRESCRIPTION DIALOG
  void _showAddClinicalNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Add Clinical Note / Prescription ($petName)',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Diagnosis / Medical Findings',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 4),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Enter clinical observations...',
                  hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Prescribed Medication / Treatment Plan',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 4),
              const TextField(
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter dosage and instructions...',
                  hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Clinical note saved for $petName!'),
                    backgroundColor: const Color(0xFF166534),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
              ),
              child: const Text(
                'Save Record',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  // ARCHIVE / DELETE DIALOG
  void _showArchiveDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Archive or Delete Record',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to archive or remove $petName ($petId) from active management?',
            style: const TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$petName ($petId) record archived.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text(
                'Archive / Delete',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, color: Color(0xFF94A3B8), size: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 4,
      onSelected: (String value) => _handleAction(context, value),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        // 1. View Pet Profile / Medical History
        PopupMenuItem<String>(
          value: 'view_profile',
          child: Row(
            children: const [
              Icon(
                Icons.assignment_ind_outlined,
                size: 16,
                color: Color(0xFF0F172A),
              ),
              SizedBox(width: 10),
              Text(
                'View Pet Profile / Medical History',
                style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),

        // 2. Edit Pet Details
        PopupMenuItem<String>(
          value: 'edit_pet',
          child: Row(
            children: const [
              Icon(Icons.edit_outlined, size: 16, color: Color(0xFF475569)),
              SizedBox(width: 10),
              Text(
                'Edit Pet Details',
                style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),

        // 3. Update Patient Status
        PopupMenuItem<String>(
          value: 'update_status',
          child: Row(
            children: const [
              Icon(Icons.sync_alt, size: 16, color: Color(0xFF3B82F6)),
              SizedBox(width: 10),
              Text(
                'Update Patient Status',
                style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),

        // 4. Book Appointment
        PopupMenuItem<String>(
          value: 'book_appointment',
          child: Row(
            children: const [
              Icon(
                Icons.calendar_month_outlined,
                size: 16,
                color: Color(0xFF166534),
              ),
              SizedBox(width: 10),
              Text(
                'Book Appointment',
                style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),

        // 5. Add Clinical Note / Prescription
        PopupMenuItem<String>(
          value: 'add_clinical_note',
          child: Row(
            children: const [
              Icon(Icons.note_add_outlined, size: 16, color: Color(0xFFD97706)),
              SizedBox(width: 10),
              Text(
                'Add Clinical Note / Prescription',
                style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),

        const PopupMenuDivider(height: 1),

        // 6. Archive / Delete Record
        PopupMenuItem<String>(
          value: 'archive_delete',
          child: Row(
            children: const [
              Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                'Archive / Delete Record',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// ADD PET REGISTRATION DIALOG
// ==========================================
class _AddPetRegistrationDialog extends StatefulWidget {
  const _AddPetRegistrationDialog();

  @override
  State<_AddPetRegistrationDialog> createState() =>
      _AddPetRegistrationDialogState();
}

class _AddPetRegistrationDialogState extends State<_AddPetRegistrationDialog> {
  String _ownerType = 'New Owner';

  final TextEditingController _ownerIdController = TextEditingController(
    text: 'OWNER-2026-8941',
  );
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _contactNumController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _speciesBreedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _gender = 'Male';
  String _spayedNeuteredStatus = 'Not Neutered / Spayed';

  void _openOwnerLookupModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _OwnerLookupDialog(
          onSelectOwner: (ownerId, name, phone, address) {
            setState(() {
              _ownerIdController.text = ownerId;
              _fullNameController.text = name;
              _contactNumController.text = phone;
              _addressController.text = address;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected Owner: $name ($ownerId)'),
                backgroundColor: const Color(0xFF166534),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 580,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'New Pet Patient Intake',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Register a new pet patient and manage owner profiles.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Color(0xFFE2E8F0), height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      Icons.assignment_ind_outlined,
                      '1. Owner Registration Status',
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _ownerType = 'New Owner';
                                _ownerIdController.text = 'OWNER-2026-8941';
                                _fullNameController.clear();
                                _contactNumController.clear();
                                _addressController.clear();
                              });
                            },
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: 'New Owner',
                                  groupValue: _ownerType,
                                  onChanged: (v) {
                                    setState(() {
                                      _ownerType = v!;
                                      _ownerIdController.text =
                                          'OWNER-2026-8941';
                                    });
                                  },
                                ),
                                const Text(
                                  'New Owner',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _ownerType = 'Existing Owner';
                                _ownerIdController.clear();
                              });
                            },
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: 'Existing Owner',
                                  groupValue: _ownerType,
                                  onChanged: (v) {
                                    setState(() {
                                      _ownerType = v!;
                                      _ownerIdController.clear();
                                    });
                                  },
                                ),
                                const Text(
                                  'Existing Owner',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_ownerType == 'New Owner') ...[
                      _buildTextField(
                        _ownerIdController,
                        'Generated Unique Owner ID (Auto-Assigned)',
                        'OWNER-2026-8941',
                        isReadOnly: true,
                      ),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _ownerIdController,
                              'Search Owner ID Number*',
                              'e.g., OWNER-2025-1042',
                              isReadOnly: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _openOwnerLookupModal(context),
                            icon: const Icon(
                              Icons.search,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Lookup Directory',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildSectionHeader(
                      Icons.person_outline,
                      '2. Pet Owner Details',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _fullNameController,
                      'Full Name*',
                      'e.g., Juan Dela Cruz',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      _contactNumController,
                      'Contact Number*',
                      'e.g., 09171234567',
                      isNumber: true,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      _addressController,
                      'Residential Address*',
                      'e.g., Street, City, Province',
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader(Icons.pets, '3. Pet Information'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _petNameController,
                            'Pet Name*',
                            'e.g., Milo',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            _speciesBreedController,
                            'Species & Breed*',
                            'e.g., Dog / Golden Retriever',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _ageController,
                            'Age or Date of Birth*',
                            'e.g., 2 Years 4 Months',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gender*',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _gender,
                                decoration: _inputDecoration(),
                                items: ['Male', 'Female']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() => _gender = v!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Neutered or Spayed Status*',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _spayedNeuteredStatus,
                      decoration: _inputDecoration(),
                      items: ['Neutered / Spayed', 'Not Neutered / Spayed']
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _spayedNeuteredStatus = v!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Successfully registered ${_petNameController.text.isEmpty ? "Pet" : _petNameController.text}!',
                        ),
                        backgroundColor: const Color(0xFF166534),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Save & Register Pet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF312E81)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF312E81),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNumber = false,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
          style: TextStyle(
            fontSize: 12,
            color: isReadOnly
                ? const Color(0xFF64748B)
                : const Color(0xFF0F172A),
          ),
          decoration: _inputDecoration(hint: hint, isReadOnly: isReadOnly),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    String hint = '',
    bool isReadOnly = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
      filled: true,
      fillColor: isReadOnly ? const Color(0xFFE2E8F0) : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0F172A)),
      ),
    );
  }
}

// ==========================================
// OWNER LOOKUP SEARCH DIALOG
// ==========================================
class _OwnerLookupDialog extends StatefulWidget {
  final Function(String id, String name, String phone, String address)
  onSelectOwner;

  const _OwnerLookupDialog({required this.onSelectOwner});

  @override
  State<_OwnerLookupDialog> createState() => _OwnerLookupDialogState();
}

class _OwnerLookupDialogState extends State<_OwnerLookupDialog> {
  String _searchQuery = '';

  final List<Map<String, String>> _ownerDatabase = [
    {
      'id': 'OWNER-2025-0012',
      'name': 'Sarah Jenkins',
      'phone': '+63 917 123 4567',
      'address': 'Quezon City, Metro Manila',
    },
    {
      'id': 'OWNER-2025-0045',
      'name': 'Junexene Agravante',
      'phone': '+63 918 987 6543',
      'address': 'Pasig City, Metro Manila',
    },
    {
      'id': 'OWNER-2025-0102',
      'name': 'Michael Chen',
      'phone': '+63 920 333 4444',
      'address': 'Mandaluyong City, Metro Manila',
    },
    {
      'id': 'OWNER-2025-0189',
      'name': 'Emily Rodriguez',
      'phone': '+63 915 555 7788',
      'address': 'Makati City, Metro Manila',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredOwners = _ownerDatabase.where((owner) {
      final q = _searchQuery.toLowerCase();
      return owner['id']!.toLowerCase().contains(q) ||
          owner['name']!.toLowerCase().contains(q) ||
          owner['phone']!.toLowerCase().contains(q);
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 650,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.search, size: 20, color: Color(0xFF0F172A)),
                    SizedBox(width: 8),
                    Text(
                      'Select Existing Owner',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by Owner ID, Name, or Phone Number...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF0F172A)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.5),
                    1: FlexColumnWidth(1.8),
                    2: FlexColumnWidth(1.5),
                    3: FlexColumnWidth(1.0),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    const TableRow(
                      children: [
                        _TableHeader('OWNER ID'),
                        _TableHeader('FULL NAME'),
                        _TableHeader('PHONE'),
                        _TableHeader('ACTION'),
                      ],
                    ),
                    for (var owner in filteredOwners)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(
                              owner['id']!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                owner['name']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                owner['address']!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            owner['phone']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              widget.onSelectOwner(
                                owner['id']!,
                                owner['name']!,
                                owner['phone']!,
                                owner['address']!,
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              'Select',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// TABLE HEADER HELPER
// ==========================================
class _TableHeader extends StatelessWidget {
  final String label;
  const _TableHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
