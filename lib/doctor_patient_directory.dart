import 'package:flutter/material.dart';
import 'doctor_dashboard.dart';

class DoctorPatientDirectoryScreen extends StatefulWidget {
  const DoctorPatientDirectoryScreen({super.key});

  @override
  State<DoctorPatientDirectoryScreen> createState() =>
      _DoctorPatientDirectoryScreenState();
}

class _DoctorPatientDirectoryScreenState
    extends State<DoctorPatientDirectoryScreen> {
  String _selectedSpecies = 'All Species';
  String _selectedStatus = 'Any Status';

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
                            fontFamily: 'Serif',
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Manage and monitor health records for all registered patients.',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 24),

                        // Top Stat Cards Row
                        Row(
                          children: [
                            const _StatCard(
                              title: 'TOTAL PATIENTS',
                              value: '1,284',
                              subtext: '+12% this month',
                              subtextColor: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 16),
                            const _StatCard(
                              title: 'IN TREATMENT',
                              value: '42',
                              subtext: 'Requires daily monitoring',
                              subtextColor: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 16),
                            const _StatCard(
                              title: 'PENDING FOLLOW-UPS',
                              value: '18',
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

                        // Main Table Container
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

                                    // Extra Filter Icon
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

                              // Patient Directory Table
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 12.0),
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(2.2), // PATIENT NAME
                                    1: FlexColumnWidth(1.8), // SPECIES / BREED
                                    2: FlexColumnWidth(2.0), // OWNER NAME
                                    3: FlexColumnWidth(1.8), // LAST VISIT
                                    4: FlexColumnWidth(1.6), // HEALTH STATUS
                                    5: FlexColumnWidth(1.0), // ACTIONS
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
                                    _buildPatientRow(
                                      name: 'Luna',
                                      id: '#PT-8821',
                                      species: 'Canine',
                                      breed: 'Golden Retriever',
                                      owner: 'Robert Harrison',
                                      visitDate: 'Oct 12, 2023',
                                      visitType: 'Routine Checkup',
                                      status: 'STABLE',
                                      statusType: 'stable',
                                    ),
                                    _buildPatientRow(
                                      name: 'Oliver',
                                      id: '#PT-9012',
                                      species: 'Feline',
                                      breed: 'Siamese',
                                      owner: 'Sarah Miller',
                                      visitDate: 'Oct 21, 2023',
                                      visitType: 'Post-Surgery',
                                      status: 'IN TREATMENT',
                                      statusType: 'treatment',
                                    ),
                                    _buildPatientRow(
                                      name: 'Coco',
                                      id: '#PT-1154',
                                      species: 'Avian',
                                      breed: 'Amazon Parrot',
                                      owner: 'James Wilson',
                                      visitDate: 'Oct 18, 2023',
                                      visitType: 'Vaccination',
                                      status: 'FOLLOW-UP',
                                      statusType: 'followup',
                                    ),
                                    _buildPatientRow(
                                      name: 'Max',
                                      id: '#PT-4423',
                                      species: 'Canine',
                                      breed: 'Beagle',
                                      owner: 'Emily Davis',
                                      visitDate: 'Oct 05, 2023',
                                      visitType: 'Dental Cleaning',
                                      status: 'STABLE',
                                      statusType: 'stable',
                                    ),
                                  ],
                                ),
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
                                    const Text('Showing 1-10 of 1,284 patients',
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
                                        _buildPageBadge('2'),
                                        _buildPageBadge('3'),
                                        const Text('  ...  128  ',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B))),
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

  // 1. Sidebar Widget
  Widget _buildDoctorSidebar(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF0A0F1D),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'VetClinic Pro',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Serif'),
                ),
                SizedBox(height: 2),
                Text("DOCTOR'S PORTAL",
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5)),
              ],
            ),
          ),
          _buildNavItem(
              context, Icons.grid_view_rounded, 'Main Dashboard', false, () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const DoctorDashboardScreen()));
          }),
          _buildNavItem(
              context, Icons.pets_outlined, 'Patient Directory', true, null),
          _buildNavItem(context, Icons.mail_outline, 'Messages', false, () {}),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFF131C31),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFCBD5E1),
                  child: Icon(Icons.person, color: Color(0xFF0F172A), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Dr. Sarah Chen',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      SizedBox(height: 2),
                      Text('Senior Veterinarian',
                          style:
                              TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String title,
      bool isActive, VoidCallback? onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E293B) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon,
            color: isActive ? Colors.white : const Color(0xFF64748B), size: 18),
        title: Text(
          title,
          style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
        ),
        onTap: onTap,
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
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search patients by name, owner, or ID...',
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

  // Patient Table Row Builder
  TableRow _buildPatientRow({
    required String name,
    required String id,
    required String species,
    required String breed,
    required String owner,
    required String visitDate,
    required String visitType,
    required String status,
    required String statusType,
  }) {
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
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: visitType == 'Post-Surgery'
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF16A34A),
              ),
            ),
          ],
        ),
        _buildStatusBadge(status, statusType),
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

  Widget _buildStatusBadge(String text, String type) {
    Color bg = const Color(0xFFDCFCE7);
    Color color = const Color(0xFF16A34A);

    if (type == 'treatment') {
      bg = const Color(0xFFE0E7FF);
      color = const Color(0xFF3730A3);
    } else if (type == 'followup') {
      bg = const Color(0xFFF1F5F9);
      color = const Color(0xFF475569);
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
                    color: Color(0xFF0F172A),
                    fontFamily: 'Serif')),
            const SizedBox(height: 4),
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
