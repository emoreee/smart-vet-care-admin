import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sidebar.dart';
import 'user_account.dart';

class PetManagementScreen extends StatefulWidget {
  const PetManagementScreen({super.key});

  @override
  State<PetManagementScreen> createState() => _PetManagementScreenState();
}

class _PetManagementScreenState extends State<PetManagementScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _searchQuery = '';
  String _selectedStatusFilter = 'All'; // 'All', 'Active', 'Deceased'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar Component
          const SidebarMenu(activeRoute: '/pets'),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Bar & Add Pet Button
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
                                SizedBox(height: 2),
                                Text(
                                  'Manage patient records, track medical status, and owner details.',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF64748B)),
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
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _showAddPetChoiceDialog(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add New Pet',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Main Card Container
                        Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search Field & Filter Tabs Row
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: TextField(
                                        onChanged: (val) {
                                          setState(() {
                                            _searchQuery =
                                                val.toLowerCase().trim();
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          hintText:
                                              'Search Pet ID, Pet Name, or Owner...',
                                          hintStyle: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF94A3B8)),
                                          prefixIcon: Icon(Icons.search,
                                              size: 18,
                                              color: Color(0xFF94A3B8)),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Status Filter Tabs
                                  Container(
                                    height: 42,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildFilterTab('All'),
                                        _buildFilterTab('Active'),
                                        _buildFilterTab('Deceased'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Table Stream View
                              StreamBuilder<QuerySnapshot>(
                                stream: _db.collection('pets').snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Padding(
                                      padding: EdgeInsets.all(40.0),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  }

                                  final rawDocs = snapshot.hasData
                                      ? snapshot.data!.docs
                                      : [];

                                  // FILTER BY SEARCH & CASE-INSENSITIVE STATUS
                                  var filteredDocs = rawDocs.where((doc) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final petId =
                                        (data['petId'] ?? data['id'] ?? doc.id)
                                            .toString()
                                            .toLowerCase();
                                    final ownerName = (data['fullName'] ??
                                            data['ownerName'] ??
                                            data['owner'] ??
                                            '')
                                        .toString()
                                        .toLowerCase();
                                    final petName =
                                        (data['name'] ?? data['petName'] ?? '')
                                            .toString()
                                            .toLowerCase();

                                    final status = (data['status'] ?? 'active')
                                        .toString()
                                        .trim()
                                        .toLowerCase();

                                    final matchesSearch =
                                        petId.contains(_searchQuery) ||
                                            ownerName.contains(_searchQuery) ||
                                            petName.contains(_searchQuery);

                                    bool matchesStatus = true;
                                    if (_selectedStatusFilter == 'Active') {
                                      matchesStatus = (status == 'active');
                                    } else if (_selectedStatusFilter ==
                                        'Deceased') {
                                      matchesStatus = (status == 'deceased');
                                    }

                                    return matchesSearch && matchesStatus;
                                  }).toList();

                                  // SORT SEQUENTIALLY FROM PET-00001 TO LATEST
                                  filteredDocs.sort((a, b) {
                                    final dataA =
                                        a.data() as Map<String, dynamic>;
                                    final dataB =
                                        b.data() as Map<String, dynamic>;

                                    final idA =
                                        (dataA['petId'] ?? a.id).toString();
                                    final idB =
                                        (dataB['petId'] ?? b.id).toString();

                                    return idA.compareTo(idB);
                                  });

                                  if (filteredDocs.isEmpty) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 40.0),
                                      child: Center(
                                        child: Text(
                                          'No pet records found matching criteria.',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF94A3B8),
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    );
                                  }

                                  return Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(1.5),
                                      1: FlexColumnWidth(1.8),
                                      2: FlexColumnWidth(2.0),
                                      3: FlexColumnWidth(1.5),
                                      4: FlexColumnWidth(1.2),
                                      5: FlexColumnWidth(0.8),
                                    },
                                    defaultVerticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    children: [
                                      const TableRow(
                                        children: [
                                          _TableHeader('PET ID'),
                                          _TableHeader('PET NAME'),
                                          _TableHeader('OWNER\'S NAME'),
                                          _TableHeader('BREED'),
                                          _TableHeader('STATUS'),
                                          _TableHeader('ACTIONS'),
                                        ],
                                      ),
                                      ...filteredDocs.map((doc) {
                                        final data =
                                            doc.data() as Map<String, dynamic>;

                                        final petId = data['petId'] ?? doc.id;
                                        final name = data['name'] ??
                                            data['petName'] ??
                                            'Unnamed';
                                        final breed = data['breed'] ??
                                            data['species'] ??
                                            'Mixed';
                                        final status =
                                            data['status'] ?? 'Active';

                                        return TableRow(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12.0),
                                              child: Text(
                                                petId,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Color(0xFF0F172A)),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.pets,
                                                    size: 14,
                                                    color: Color(0xFF64748B)),
                                                const SizedBox(width: 8),
                                                Text(name,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xFF0F172A))),
                                              ],
                                            ),

                                            // DYNAMIC OWNER'S NAME RESOLVER FROM USERS COLLECTION
                                            _buildOwnerNameCell(data),

                                            Text(breed,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF334155))),
                                            _buildStatusBadge(status),
                                            PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_horiz,
                                                  size: 18,
                                                  color: Color(0xFF64748B)),
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              onSelected: (val) {
                                                if (val == 'toggle_status') {
                                                  final currentStatusStr =
                                                      status
                                                          .toString()
                                                          .trim()
                                                          .toLowerCase();
                                                  final newStatus =
                                                      (currentStatusStr ==
                                                              'active')
                                                          ? 'Deceased'
                                                          : 'Active';
                                                  _db
                                                      .collection('pets')
                                                      .doc(doc.id)
                                                      .update({
                                                    'status': newStatus
                                                  });
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  value: 'toggle_status',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        status
                                                                    .toString()
                                                                    .trim()
                                                                    .toLowerCase() ==
                                                                'active'
                                                            ? Icons
                                                                .cancel_outlined
                                                            : Icons
                                                                .check_circle_outline,
                                                        size: 16,
                                                        color: status
                                                                    .toString()
                                                                    .trim()
                                                                    .toLowerCase() ==
                                                                'active'
                                                            ? Colors.red
                                                            : Colors.green,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        status
                                                                    .toString()
                                                                    .trim()
                                                                    .toLowerCase() ==
                                                                'active'
                                                            ? 'Mark as Deceased'
                                                            : 'Mark as Active',
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }),
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

  // RESOLVES OWNER'S FULLNAME DYNAMICALLY FROM USERS COLLECTION
  Widget _buildOwnerNameCell(Map<String, dynamic> petData) {
    if (petData['ownerName'] != null &&
        petData['ownerName'].toString().trim().isNotEmpty &&
        petData['ownerName'] != 'N/A') {
      return Text(petData['ownerName'].toString(),
          style: const TextStyle(fontSize: 12, color: Color(0xFF334155)));
    }
    if (petData['fullName'] != null &&
        petData['fullName'].toString().trim().isNotEmpty &&
        petData['fullName'] != 'N/A') {
      return Text(petData['fullName'].toString(),
          style: const TextStyle(fontSize: 12, color: Color(0xFF334155)));
    }

    return FutureBuilder<QuerySnapshot>(
      future: _db.collection('users').get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final targetOwnerId = (petData['ownerId'] ??
                  petData['userId'] ??
                  petData['owner'] ??
                  '')
              .toString();

          for (var userDoc in snapshot.data!.docs) {
            final uData = userDoc.data() as Map<String, dynamic>;
            final uOwnerId = (uData['ownerId'] ?? '').toString();
            final uDocId = userDoc.id;

            if ((uOwnerId.isNotEmpty && uOwnerId == targetOwnerId) ||
                uDocId == targetOwnerId) {
              final fetchedName = uData['fullName'] ?? uData['name'] ?? 'N/A';
              return Text(fetchedName,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF334155)));
            }
          }
        }

        final directOwner = petData['owner'] ?? 'N/A';
        return Text(directOwner.toString(),
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155)));
      },
    );
  }

  // Filter Tab Widget
  Widget _buildFilterTab(String label) {
    final isSelected = _selectedStatusFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatusFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 1))
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color:
                isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  // Active / Deceased Status Badge
  Widget _buildStatusBadge(String status) {
    final isActive = status.toString().trim().toLowerCase() == 'active';
    final bgColor =
        isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9);
    final textColor =
        isActive ? const Color(0xFF166534) : const Color(0xFF475569);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          isActive ? 'Active' : 'Deceased',
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }

  // Top Header Bar
  Widget _buildTopHeader() {
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
                  fontSize: 14,
                  color: Color(0xFF0F172A))),
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.help_outline,
                      color: Color(0xFF64748B), size: 20),
                  onPressed: () {}),
              IconButton(
                  icon: const Icon(Icons.grid_view,
                      color: Color(0xFF64748B), size: 20),
                  onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  // DIALOG: CHOICE (EXISTING OWNER vs NEW OWNER WITH DIRECT NAVIGATION)
  void _showAddPetChoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add New Pet Record',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A))),
                    IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Select pet owner status to proceed:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 20),

                // Option 1: Existing Owner
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE2E8F0))),
                  leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF0F9FF),
                      child: Icon(Icons.person, color: Color(0xFF0284C7))),
                  title: const Text('Existing Owner',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Pet owner already has an account',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddPetFormDialog(context);
                  },
                ),
                const SizedBox(height: 12),

                // Option 2: New Owner (Direct Redirect to User Account Screen)
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE2E8F0))),
                  leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFFBEB),
                      child: Icon(Icons.person_add, color: Color(0xFFD97706))),
                  title: const Text('New Owner',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Create a new pet owner account first',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, anim1, anim2) =>
                            const UserAccountScreen(),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // FORM DIALOG FOR ADDING PET DETAILS
  void _showAddPetFormDialog(BuildContext context) {
    String? selectedOwnerName;
    String? selectedOwnerId;

    final petNameController = TextEditingController();
    String selectedAnimalType = 'Dog';
    final customAnimalTypeController = TextEditingController();
    final breedController = TextEditingController();
    String selectedGender = 'Male';

    String selectedMonth = 'January';
    int selectedYear = DateTime.now().year;

    final List<String> animalTypes = ['Dog', 'Cat', 'Bird', 'Others'];
    final List<String> genders = ['Male', 'Female'];
    final List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final List<int> years =
        List.generate(25, (index) => DateTime.now().year - index);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(28),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Title and Close Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add New Pet Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                size: 20, color: Color(0xFF94A3B8)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 1. SELECT PET OWNER DROPDOWN / HIGHLIGHT CARD
                      const Text(
                        'PET OWNER*',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 6),

                      if (selectedOwnerName != null &&
                          selectedOwnerName!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFC7D2FE)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  color: Color(0xFF4F46E5), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: selectedOwnerName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                            fontSize: 13),
                                      ),
                                      TextSpan(
                                        text:
                                            '  (${selectedOwnerId ?? 'OWN-00000'})',
                                        style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    selectedOwnerName = null;
                                    selectedOwnerId = null;
                                  });
                                },
                                child: const Text(
                                  'Change',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4F46E5)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        StreamBuilder<QuerySnapshot>(
                          stream: _db.collection('users').snapshots(),
                          builder: (context, snapshot) {
                            List<Map<String, String>> ownerOptions = [];

                            if (snapshot.hasData) {
                              ownerOptions = snapshot.data!.docs.map((doc) {
                                final d = doc.data() as Map<String, dynamic>;
                                return {
                                  'name': (d['fullName'] ??
                                          d['name'] ??
                                          'Pet Owner')
                                      .toString(),
                                  'ownerId':
                                      (d['ownerId'] ?? doc.id).toString(),
                                };
                              }).toList();
                            }

                            return DropdownButtonFormField<String>(
                              decoration: _buildInputDecoration(
                                  hintText: 'Select owner name or ID...'),
                              items: ownerOptions.map((o) {
                                return DropdownMenuItem<String>(
                                  value: o['name'],
                                  child: Text('${o['name']} (${o['ownerId']})',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF0F172A))),
                                );
                              }).toList(),
                              onChanged: (val) {
                                final match = ownerOptions.firstWhere(
                                    (e) => e['name'] == val,
                                    orElse: () => {'name': '', 'ownerId': ''});
                                setDialogState(() {
                                  selectedOwnerName = match['name'];
                                  selectedOwnerId = match['ownerId'];
                                });
                              },
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),

                      // 2. PET NAME FIELD
                      TextField(
                        controller: petNameController,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF0F172A)),
                        decoration: _buildInputDecoration(
                          labelText: 'PET NAME*',
                          hintText: 'Enter pet name...',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. TYPE OF ANIMAL & GENDER ROW
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedAnimalType,
                              decoration: _buildInputDecoration(
                                  labelText: 'TYPE OF ANIMAL*'),
                              items: animalTypes.map((type) {
                                return DropdownMenuItem(
                                    value: type,
                                    child: Text(type,
                                        style: const TextStyle(fontSize: 13)));
                              }).toList(),
                              onChanged: (val) => setDialogState(
                                  () => selectedAnimalType = val!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedGender,
                              decoration:
                                  _buildInputDecoration(labelText: 'GENDER*'),
                              items: genders.map((g) {
                                return DropdownMenuItem(
                                    value: g,
                                    child: Text(g,
                                        style: const TextStyle(fontSize: 13)));
                              }).toList(),
                              onChanged: (val) =>
                                  setDialogState(() => selectedGender = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // IF "OTHERS" IS SELECTED FOR ANIMAL TYPE
                      if (selectedAnimalType == 'Others') ...[
                        TextField(
                          controller: customAnimalTypeController,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF0F172A)),
                          decoration: _buildInputDecoration(
                            labelText: 'SPECIFY ANIMAL TYPE*',
                            hintText: 'e.g. Rabbit, Hamster, Snake...',
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 4. BREED / SPECIES FIELD
                      TextField(
                        controller: breedController,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF0F172A)),
                        decoration: _buildInputDecoration(
                          labelText: 'BREED / SPECIES*',
                          hintText: 'e.g. Aspin, Golden Retriever, Persian...',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. BIRTH MONTH & YEAR ROW
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedMonth,
                              decoration: _buildInputDecoration(
                                  labelText: 'BIRTH MONTH*'),
                              items: months
                                  .map((m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(m,
                                          style:
                                              const TextStyle(fontSize: 13))))
                                  .toList(),
                              onChanged: (val) =>
                                  setDialogState(() => selectedMonth = val!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: selectedYear,
                              decoration: _buildInputDecoration(
                                  labelText: 'BIRTH YEAR*'),
                              items: years
                                  .map((y) => DropdownMenuItem(
                                      value: y,
                                      child: Text('$y',
                                          style:
                                              const TextStyle(fontSize: 13))))
                                  .toList(),
                              onChanged: (val) =>
                                  setDialogState(() => selectedYear = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Actions Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B))),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              if (petNameController.text.isNotEmpty &&
                                  selectedOwnerName != null) {
                                final petsCount =
                                    (await _db.collection('pets').get())
                                            .docs
                                            .length +
                                        1;
                                final newPetId =
                                    'PET-${petsCount.toString().padLeft(5, '0')}';

                                final finalAnimalType =
                                    (selectedAnimalType == 'Others')
                                        ? customAnimalTypeController.text
                                        : selectedAnimalType;

                                await _db.collection('pets').add({
                                  'petId': newPetId,
                                  'name': petNameController.text,
                                  'ownerName': selectedOwnerName,
                                  'fullName': selectedOwnerName,
                                  'ownerId': selectedOwnerId,
                                  'animalType': finalAnimalType,
                                  'species': finalAnimalType,
                                  'breed': breedController.text,
                                  'gender': selectedGender,
                                  'dob': '$selectedMonth $selectedYear',
                                  'status': 'Active',
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Pet $newPetId added successfully!')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please select an owner and enter pet name.')),
                                );
                              }
                            },
                            child: const Text('Save Pet Record',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold)),
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

  // FLOATING LABELS INPUT DECORATION HELPER
  InputDecoration _buildInputDecoration(
      {String? labelText, String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
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
