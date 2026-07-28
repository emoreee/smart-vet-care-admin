import 'package:flutter/material.dart';
import 'doctor_messages.dart';
import 'doctor_patient_directory.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  String _activeTab = 'Main Dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // 1. DOCTOR'S SIDEBAR
          _buildDoctorSidebar(),

          // 2. DYNAMIC MAIN CONTENT VIEW
          Expanded(
            child: _activeTab == 'Patient Directory'
                ? const DoctorPatientDirectoryScreenView()
                : (_activeTab == 'Messages'
                    ? const DoctorMessagesScreenView()
                    : _buildMainDashboardView()),
          ),
        ],
      ),
    );
  }

  // 1. Doctor Sidebar Widget
  Widget _buildDoctorSidebar() {
    return Container(
      width: 240,
      color: const Color(0xFF0A0F1D), // Dark Navy
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branding
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Furry Friends Animal Clinic',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Serif',
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Doctor's Portal",
                  style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Nav Items with Click Actions
          _buildSidebarNavItem(
            Icons.grid_view_rounded,
            'Main Dashboard',
            onTap: () => setState(() => _activeTab = 'Main Dashboard'),
          ),
          _buildSidebarNavItem(
            Icons.pets_outlined,
            'Patient Directory',
            onTap: () => setState(() => _activeTab = 'Patient Directory'),
          ),
          _buildSidebarNavItem(
            Icons.mail_outline,
            'Messages',
            onTap: () => setState(() => _activeTab = 'Messages'),
          ),

          const Spacer(),

          // Doctor Profile Footer
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF131C31),
              borderRadius: BorderRadius.circular(12),
            ),
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
                      Text('Dr. Julian Vance',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      SizedBox(height: 2),
                      Text('SENIOR VET',
                          style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600)),
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

  Widget _buildSidebarNavItem(IconData icon, String title,
      {VoidCallback? onTap}) {
    final isActive = _activeTab == title;

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
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  // 2. Main Dashboard View Layout
  Widget _buildMainDashboardView() {
    return Column(
      children: [
        _buildDoctorTopHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good morning, Dr. Vance',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'You have 12 appointments and 4 urgent consultations scheduled for today.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),
                Row(
                  children: const [
                    _DoctorStatCard(
                      label: 'PATIENTS TODAY',
                      count: '12',
                      subtext: '↑ 15% vs. yesterday',
                      subtextColor: Color(0xFF16A34A),
                      icon: Icons.calendar_today_outlined,
                      iconBg: Color(0xFFEEF2FF),
                      iconColor: Color(0xFF4F46E5),
                      accentColor: Color(0xFF0F172A),
                    ),
                    SizedBox(width: 16),
                    _DoctorStatCard(
                      label: 'PENDING LAB RESULTS',
                      count: '08',
                      subtext: '3 results ready for review',
                      subtextColor: Color(0xFF64748B),
                      icon: Icons.science_outlined,
                      iconBg: Color(0xFFEEF2FF),
                      iconColor: Color(0xFF4F46E5),
                      accentColor: Color(0xFF64748B),
                    ),
                    SizedBox(width: 16),
                    _DoctorStatCard(
                      label: 'URGENT CONSULTATIONS',
                      count: '04',
                      subtext: 'Immediate attention required',
                      subtextColor: Color(0xFFDC2626),
                      icon: Icons.emergency_outlined,
                      iconBg: Color(0xFFFEE2E2),
                      iconColor: Color(0xFFDC2626),
                      accentColor: Color(0xFFDC2626),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildNextPatientSpotlight(),
                          const SizedBox(height: 24),
                          _buildRecentLabResultsCard(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: _buildDailyScheduleTimeline(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Top Header
  Widget _buildDoctorTopHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 320,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search patients, records, or labs...',
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
              Container(height: 24, width: 1, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('Clinic Status',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF16A34A), size: 8),
                      SizedBox(width: 4),
                      Text('ONLINE',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16A34A))),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextPatientSpotlight() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 110,
              height: 110,
              color: const Color(0xFFFEF3C7),
              child: const Icon(Icons.pets, size: 50, color: Color(0xFFD97706)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('NEXT PATIENT • 09:30 AM',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    const Text('Check-in Complete',
                        style: TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Cooper',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Serif')),
                const SizedBox(height: 2),
                const Text('Golden Retriever, 4 years • Owner: Martha Stewart',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMiniNote('REASON FOR VISIT', 'Vaccination Booster'),
                    const SizedBox(width: 12),
                    _buildMiniNote(
                        'PREVIOUS NOTE', 'Mild skin allergy (May 2023)'),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon:
                const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
            label: const Text('Start Consultation',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniNote(String title, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(val,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildRecentLabResultsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Lab Results',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Serif')),
              TextButton(
                onPressed: () {},
                child: const Text('View All Records',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.8),
              1: FlexColumnWidth(2.0),
              2: FlexColumnWidth(1.8),
              3: FlexColumnWidth(1.4),
              4: FlexColumnWidth(1.0),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(
                children: [
                  _LabHeader('PATIENT'),
                  _LabHeader('TEST TYPE'),
                  _LabHeader('REQUESTED BY'),
                  _LabHeader('STATUS'),
                  _LabHeader('ACTION'),
                ],
              ),
              _buildLabRow('Luna', 'Feline', 'Complete Blood Count',
                  'Dr. Vance', 'COMPLETED', true),
              _buildLabRow('Max', 'Canine', 'Urinalysis Panel', 'Dr. Sarah L.',
                  'PENDING', false),
              _buildLabRow('Bella', 'Canine', 'Thyroid T4', 'Dr. Vance',
                  'COMPLETED', true),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildLabRow(String pet, String species, String test, String doc,
      String status, bool isDone) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pet,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF0F172A))),
              Text('($species)',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ),
        Text(test,
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
        Text(doc,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color:
                    isDone ? const Color(0xFF16A34A) : const Color(0xFF64748B)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.description_outlined,
              size: 18, color: Color(0xFF475569)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildDailyScheduleTimeline() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Daily Schedule',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Serif')),
              Text('Thursday, Oct 24',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 20),
          _buildScheduleItem(
              '09:30 AM', 'Cooper (Vaccination)', 'Martha Stewart',
              isCurrent: true),
          _buildScheduleItem(
              '10:15 AM', 'Misty (Routine Checkup)', 'James Bond'),
          _buildScheduleItem(
              '11:00 AM • URGENT', 'Rex (Emergency Exam)', 'David Miller',
              isUrgent: true),
          _buildScheduleItem('11:45 AM', 'Daisy (Follow-up)', 'Susan Boyle'),
          _buildScheduleItem('12:30 PM', 'LUNCH BREAK', '', isBreak: true),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String time, String title, String subtitle,
      {bool isCurrent = false, bool isUrgent = false, bool isBreak = false}) {
    Color cardBg = const Color(0xFFF8FAFC);
    Color borderColor = const Color(0xFFE2E8F0);
    Color textColor = const Color(0xFF0F172A);

    if (isUrgent) {
      cardBg = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFFCA5A5);
      textColor = const Color(0xFF991B1B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                isUrgent
                    ? Icons.error
                    : (isCurrent
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked),
                size: 14,
                color: isUrgent
                    ? const Color(0xFFDC2626)
                    : (isCurrent
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF94A3B8)),
              ),
              Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isUrgent
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF64748B))),
                const SizedBox(height: 4),
                if (isBreak)
                  const Text('LUNCH BREAK',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 1.0))
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(subtitle,
                              style: const TextStyle(
                                  fontSize: 10, color: Color(0xFF64748B))),
                        ],
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
}

// -------------------------------------------------------------
// PATIENT DIRECTORY EMBEDDED VIEW (Without duplicating sidebar)
// -------------------------------------------------------------
class DoctorPatientDirectoryScreenView extends StatefulWidget {
  const DoctorPatientDirectoryScreenView({super.key});

  @override
  State<DoctorPatientDirectoryScreenView> createState() =>
      _DoctorPatientDirectoryScreenViewState();
}

class _DoctorPatientDirectoryScreenViewState
    extends State<DoctorPatientDirectoryScreenView> {
  String _selectedSpecies = 'All Species';
  String _selectedStatus = 'Any Status';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Search Bar
        _buildTopBar(),

        // Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
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
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
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
                    Expanded(
                      child: Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
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
                            _buildFilterDropdown(
                              value: _selectedSpecies,
                              items: [
                                'All Species',
                                'Canine',
                                'Feline',
                                'Avian'
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedSpecies = val!),
                            ),
                            const SizedBox(width: 12),
                            _buildFilterDropdown(
                              value: _selectedStatus,
                              items: [
                                'Any Status',
                                'Stable',
                                'In Treatment',
                                'Follow-up'
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedStatus = val!),
                            ),
                            const Spacer(),
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
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      Padding(
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
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Showing 1-10 of 1,284 patients',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF64748B))),
                            Row(
                              children: [
                                const IconButton(
                                    icon: Icon(Icons.chevron_left,
                                        size: 18, color: Color(0xFF94A3B8)),
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
                                        size: 18, color: Color(0xFF475569)),
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
    );
  }

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

// Helpers
class _DoctorStatCard extends StatelessWidget {
  final String label;
  final String count;
  final String subtext;
  final Color subtextColor;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color accentColor;

  const _DoctorStatCard({
    required this.label,
    required this.count,
    required this.subtext,
    required this.subtextColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(width: 4, height: 90, color: accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label,
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF94A3B8))),
                          const SizedBox(height: 4),
                          Text(count,
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: iconBg,
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _LabHeader extends StatelessWidget {
  final String label;
  const _LabHeader(this.label);

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
