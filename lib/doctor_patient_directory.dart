import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_dashboard.dart';

class DoctorPatientDirectoryScreen extends StatefulWidget {
  const DoctorPatientDirectoryScreen({super.key});

  @override
  State<DoctorPatientDirectoryScreen> createState() =>
      _DoctorPatientDirectoryScreenState();
}

class _DoctorPatientDirectoryScreenState
    extends State<DoctorPatientDirectoryScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _currentDoctorName = 'Dr. Tamesis';

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSpecies = 'All Species';
  String _selectedStatus = 'Any Status';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // 1. DOCTOR SIDEBAR
          _buildDoctorSidebar(context),

          // 2. MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                // Top Search Bar
                _buildTopBar(),

                // Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Header
                        const Text(
                          'Patient Directory',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Manage and monitor health records for patients assigned to Dr. Tamesis.',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 24),

                        // Top Stat Cards Row
                        Row(
                          children: [
                            const _StatCard(
                              title: 'ASSIGNED PATIENTS',
                              value: '04',
                              subtext: 'Active under Dr. Tamesis',
                              subtextColor: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 16),
                            const _StatCard(
                              title: 'IN TREATMENT',
                              value: '02',
                              subtext: 'Requires daily monitoring',
                              subtextColor: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 16),
                            const _StatCard(
                              title: 'PENDING FOLLOW-UPS',
                              value: '01',
                              subtext: 'Scheduled for this week',
                              subtextColor: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 16),

                            // Weekly Schedule Quick Action Card
                            Expanded(
                              child: Container(
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: InkWell(
                                  onTap: () {},
                                  borderRadius: BorderRadius.circular(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.calendar_month_outlined,
                                          color: Color(0xFF475569), size: 24),
                                      SizedBox(height: 8),
                                      Text(
                                        'View Weekly Schedule',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Main Table Container Connected to Firestore
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              // Filter Controls Top Bar
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    const Text('Filter by:',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF64748B))),
                                    const SizedBox(width: 12),

                                    // Species Dropdown Filter
                                    _buildFilterDropdown(
                                      value: _selectedSpecies,
                                      items: [
                                        'All Species',
                                        'Canine',
                                        'Feline',
                                        'Avian'
                                      ],
                                      onChanged: (val) => setState(
                                          () => _selectedSpecies = val!),
                                    ),
                                    const SizedBox(width: 12),

                                    // Status Dropdown Filter
                                    _buildFilterDropdown(
                                      value: _selectedStatus,
                                      items: [
                                        'Any Status',
                                        'Stable',
                                        'In Treatment',
                                        'Follow-up'
                                      ],
                                      onChanged: (val) => setState(
                                          () => _selectedStatus = val!),
                                    ),

                                    const Spacer(),

                                    // Quick Toggle Pills
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          _buildFilterPill('Recent Visits',
                                              isSelected: true),
                                          _buildFilterPill('Critical Care',
                                              isSelected: false),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.filter_list,
                                          size: 18, color: Color(0xFF475569)),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                  height: 1, color: Color(0xFFE2E8F0)),

                              // Real-Time StreamBuilder for Doctor's Patients
                              StreamBuilder<QuerySnapshot>(
                                stream: _db
                                    .collection('appointments')
                                    .where('doctor',
                                        isEqualTo: _currentDoctorName)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 40.0),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  }

                                  final docs = snapshot.hasData
                                      ? snapshot.data!.docs
                                      : [];

                                  final filteredDocs = docs.where((doc) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final petName =
                                        (data['petName'] ?? data['name'] ?? '')
                                            .toString()
                                            .toLowerCase();
                                    final owner = (data['ownerName'] ?? '')
                                        .toString()
                                        .toLowerCase();
                                    final petId = (data['petId'] ?? '')
                                        .toString()
                                        .toLowerCase();

                                    return petName.contains(_searchQuery) ||
                                        owner.contains(_searchQuery) ||
                                        petId.contains(_searchQuery);
                                  }).toList();

                                  if (filteredDocs.isEmpty) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 40.0),
                                      child: Center(
                                        child: Text(
                                          'No patients currently assigned to Dr. Tamesis.',
                                          style: TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    );
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0, vertical: 12.0),
                                    child: Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(2.2),
                                        1: FlexColumnWidth(1.8),
                                        2: FlexColumnWidth(2.0),
                                        3: FlexColumnWidth(1.8),
                                        4: FlexColumnWidth(1.6),
                                        5: FlexColumnWidth(1.0),
                                      },
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      children: [
                                        const TableRow(
                                          children: [
                                            _TableHeader('PATIENT NAME'),
                                            _TableHeader('SPECIES / BREED'),
                                            _TableHeader('OWNER NAME'),
                                            _TableHeader('LAST VISIT'),
                                            _TableHeader('HEALTH STATUS'),
                                            _TableHeader('ACTIONS'),
                                          ],
                                        ),
                                        for (var doc in filteredDocs)
                                          _buildPatientRowFromFirestore(doc),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              const Divider(
                                  height: 1, color: Color(0xFFE2E8F0)),

                              // Table Pagination Footer
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                        'Showing active assigned patients',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B))),
                                    Row(
                                      children: [
                                        const IconButton(
                                            icon: Icon(Icons.chevron_left,
                                                size: 18,
                                                color: Color(0xFF94A3B8)),
                                            onPressed: null),
                                        _buildPageBadge('1', isSelected: true),
                                        const IconButton(
                                            icon: Icon(Icons.chevron_right,
                                                size: 18,
                                                color: Color(0xFF475569)),
                                            onPressed: null),
                                      ],
                                    ),
                                  ],
                                ),
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

  // 1. Sidebar Widget (MATCHED WITH MAIN DASHBOARD DESIGN & ZERO TRANSITION)
  Widget _buildDoctorSidebar(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                const Icon(Icons.pets, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Furry Friends',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Text(
                      'Doctor\'s Portal',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildNavItem(
              context, Icons.dashboard_outlined, 'Main Dashboard', false, () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    const DoctorDashboardScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }),
          _buildNavItem(
              context, Icons.pets_outlined, 'Patient Directory', true, null),
          _buildNavItem(context, Icons.mail_outline, 'Messages', false, () {}),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF0284C7),
                    child: Icon(Icons.medical_services_outlined,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentDoctorName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        const Text(
                          'Attending Veterinarian',
                          style:
                              TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
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
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String title,
      bool isActive, VoidCallback? onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E293B) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon,
            color: isActive ? Colors.white : const Color(0xFF94A3B8), size: 18),
        title: Text(
          title,
          style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  // Top Bar
  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 380,
            height: 38,
            decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20)),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Search assigned patients by name or ID...',
                hintStyle: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                prefixIcon:
                    Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.notifications_none,
                      color: Color(0xFF64748B), size: 20),
                  onPressed: () {}),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('New Patient',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Filter Dropdown Helper
  Widget _buildFilterDropdown(
      {required String value,
      required List<String> items,
      required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155)),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        boxShadow: isSelected
            ? [const BoxShadow(color: Colors.black12, blurRadius: 2)]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color:
                isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B)),
      ),
    );
  }

  // Patient Table Row Builder from Firestore Document
  TableRow _buildPatientRowFromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['petName'] ?? data['name'] ?? 'Pet Patient';
    final id = data['petId'] ?? 'PET-00000';
    final species = data['species'] ?? 'Canine';
    final breed = data['breed'] ?? 'Mixed Breed';
    final owner = data['ownerName'] ?? 'Owner';
    final visitDate = data['date'] ?? 'Today';
    final visitType = data['service'] ?? 'General Checkup';
    final status = (data['status'] ?? 'Stable').toString().toUpperCase();

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFE2E8F0),
                child: Icon(Icons.pets, size: 18, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text('ID: $id',
                      style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(species,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155))),
            Text(breed,
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          ],
        ),
        Text(owner,
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(visitDate,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A))),
            Text(
              visitType,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF16A34A),
              ),
            ),
          ],
        ),
        _buildStatusBadge(status),
        Row(
          children: [
            IconButton(
                icon: const Icon(Icons.description_outlined,
                    size: 18, color: Color(0xFF475569)),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.chat_bubble_outline,
                    size: 18, color: Color(0xFF475569)),
                onPressed: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String text) {
    Color bg = const Color(0xFFDCFCE7);
    Color color = const Color(0xFF16A34A);

    if (text.contains('TREATMENT') || text.contains('URGENT')) {
      bg = const Color(0xFFFEF2F2);
      color = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text,
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildPageBadge(String page, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        page,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF64748B)),
      ),
    );
  }
}

// Top Stat Card Helper
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final Color subtextColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtext,
    required this.subtextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8))),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 1),
            Text(subtext,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: subtextColor)),
          ],
        ),
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
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8))),
    );
  }
}
