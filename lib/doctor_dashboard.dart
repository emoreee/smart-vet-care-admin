import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_dashboard.dart';
import 'doctor_patient_directory.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _currentDoctorId = 'DOC-00001';
  final String _currentDoctorName = 'Dr. Tamesis';

  // Filter state for top cards: 'Patients Today', 'Pending Lab Results', 'Urgent Consultations'
  String _selectedDoctorFilter = 'Patients Today';

  String _formatDateToWords(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'No Date';
    try {
      final DateTime parsedDate = DateTime.parse(dateStr);
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
      final monthName = months[parsedDate.month - 1];
      final dayStr = parsedDate.day.toString().padLeft(2, '0');
      return '$monthName $dayStr, ${parsedDate.year}';
    } catch (e) {
      return dateStr;
    }
  }

  // DYNAMIC PET NAME RESOLVER FROM 'pets' COLLECTION IF MISSING
  Future<String> _resolvePetName(Map<String, dynamic> data) async {
    if (data['petName'] != null &&
        data['petName'].toString().trim().isNotEmpty) {
      return data['petName'].toString().trim();
    }
    if (data['name'] != null && data['name'].toString().trim().isNotEmpty) {
      return data['name'].toString().trim();
    }

    final petId = data['petId']?.toString().trim();
    if (petId != null && petId.isNotEmpty) {
      try {
        final query = await _db
            .collection('pets')
            .where('petId', isEqualTo: petId)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          final pData = query.docs.first.data();
          return (pData['name'] ?? pData['petName'] ?? petId).toString();
        }
      } catch (e) {
        // Fallback
      }
    }

    return petId ?? 'Pet Patient';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          _buildDoctorSidebar(context),
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning, $_currentDoctorName',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Here are your scheduled patient consultations and clinic activities for today.',
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 24),

                        // 1.) CLICKABLE STAT CARDS CONNECTED TO FIRESTORE
                        _buildStatCardsRow(),
                        const SizedBox(height: 24),

                        // 2.) NEXT PATIENT CONSULTATION CARD WITH DYNAMIC PET NAME
                        _buildNextPatientCard(),
                        const SizedBox(height: 24),

                        // 3.) RECENT LAB RESULTS CARD
                        _buildRecentLabResultsCard(),
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
          _buildSidebarNavItem(
              context: context,
              icon: Icons.dashboard_outlined,
              label: 'Main Dashboard',
              isActive: true,
              onTap: () {}),
          _buildSidebarNavItem(
              context: context,
              icon: Icons.pets_outlined,
              label: 'Patient Directory',
              isActive: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorPatientDirectoryScreen(),
                  ),
                );
              }),
          _buildSidebarNavItem(
              context: context,
              icon: Icons.mail_outline,
              label: 'Messages',
              isActive: false,
              onTap: () {}),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const DoctorPatientDirectoryScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
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
                            'Switch to Admin Portal ➔',
                            style: TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 9,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem(
      {required BuildContext context,
      required IconData icon,
      required String label,
      required bool isActive,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E293B) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon,
                    color: isActive ? Colors.white : const Color(0xFF94A3B8),
                    size: 18),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF94A3B8),
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
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
              borderRadius: BorderRadius.circular(20),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search patients, records, or labs...',
                hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
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
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: Color(0xFF22C55E)),
                    SizedBox(width: 6),
                    Text('Clinic Status: ONLINE',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardsRow() {
    final todayStr = DateTime.now().toString().split(' ')[0];

    return Row(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: _db.collection('appointments').snapshots(),
          builder: (context, snapshot) {
            int activeCount = 0;
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              activeCount = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final status = (data['status'] ?? '').toString().toLowerCase();
                final date = (data['date'] ?? '').toString();

                return status != 'completed' &&
                    status != 'cancelled' &&
                    date == todayStr;
              }).length;
            }

            return _buildStatCard(
              title: 'PATIENTS TODAY',
              value: activeCount < 10 ? '0$activeCount' : '$activeCount',
              subtext: activeCount > 0
                  ? '↑ Active schedule today'
                  : 'No patients queued',
              subtextColor: activeCount > 0
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF64748B),
              icon: Icons.calendar_today,
              isSelected: _selectedDoctorFilter == 'Patients Today',
              onTap: () =>
                  setState(() => _selectedDoctorFilter = 'Patients Today'),
            );
          },
        ),
        const SizedBox(width: 16),
        StreamBuilder<QuerySnapshot>(
          stream: _db.collection('health_monitoring').snapshots(),
          builder: (context, snapshot) {
            int pendingLabs = 0;
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              pendingLabs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final status = (data['status'] ?? data['labStatus'] ?? '')
                    .toString()
                    .toLowerCase();
                return status.contains('pending') ||
                    status.contains('progress');
              }).length;
            }

            return _buildStatCard(
              title: 'PENDING LAB RESULTS',
              value: pendingLabs < 10 ? '0$pendingLabs' : '$pendingLabs',
              subtext: pendingLabs > 0
                  ? '$pendingLabs test(s) ready for review'
                  : 'All lab reports complete',
              subtextColor: const Color(0xFF64748B),
              icon: Icons.science,
              isSelected: _selectedDoctorFilter == 'Pending Lab Results',
              onTap: () =>
                  setState(() => _selectedDoctorFilter = 'Pending Lab Results'),
            );
          },
        ),
        const SizedBox(width: 16),
        StreamBuilder<QuerySnapshot>(
          stream: _db.collection('appointments').snapshots(),
          builder: (context, snapshot) {
            int urgentCount = 0;
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              urgentCount = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final isUrgent = data['isUrgent'] ?? false;
                final status = (data['status'] ?? '').toString().toLowerCase();
                final isActive = status != 'completed' && status != 'cancelled';
                return isUrgent == true && isActive;
              }).length;
            }

            return _buildStatCard(
              title: 'URGENT CONSULTATIONS',
              value: urgentCount < 10 ? '0$urgentCount' : '$urgentCount',
              subtext: urgentCount > 0
                  ? '✶ Requires immediate attention'
                  : 'No urgent cases',
              subtextColor: urgentCount > 0
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF64748B),
              icon: Icons.warning_amber_rounded,
              isUrgent: urgentCount > 0,
              isSelected: _selectedDoctorFilter == 'Urgent Consultations',
              onTap: () => setState(
                  () => _selectedDoctorFilter = 'Urgent Consultations'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtext,
    required Color subtextColor,
    required IconData icon,
    bool isUrgent = false,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isUrgent
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF0F172A))
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 2.2 : 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                if (isUrgent)
                  Container(width: 4, color: const Color(0xFFEF4444)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(title,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF94A3B8))),
                            const SizedBox(height: 4),
                            Text(value,
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A))),
                            const SizedBox(height: 4),
                            Text(subtext,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: subtextColor)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isUrgent
                                ? const Color(0xFFFEF2F2)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon,
                              color: isUrgent
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF0284C7),
                              size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextPatientCard() {
    final todayStr = DateTime.now().toString().split(' ')[0];

    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('appointments').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyPatientCard();
        }

        final activeAppointments = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = (data['status'] ?? '').toString().toLowerCase();
          final date = (data['date'] ?? '').toString();
          final isUrgent = data['isUrgent'] ?? false;

          if (_selectedDoctorFilter == 'Urgent Consultations') {
            return isUrgent == true &&
                status != 'completed' &&
                status != 'cancelled';
          } else {
            return status != 'completed' &&
                status != 'cancelled' &&
                date == todayStr;
          }
        }).toList();

        if (activeAppointments.isEmpty) {
          return _buildEmptyPatientCard();
        }

        final data = activeAppointments.first.data() as Map<String, dynamic>;
        final breed = data['breed'] ?? data['species'] ?? 'Dog';
        final owner =
            data['ownerName'] ?? data['owner'] ?? 'Edelle Beil Bosito';
        final reason = data['service'] ?? data['reason'] ?? 'General Checkup';
        final time = data['time'] ?? '09:00 AM - 10:30 AM';
        final note = data['notes'] ?? 'No prior medical notes';
        final isUrgent = data['isUrgent'] ?? false;
        final petId = data['petId'];

        return FutureBuilder<String>(
          future: _resolvePetName(data),
          builder: (context, petSnapshot) {
            final petName = petSnapshot.data ?? 'Dheron';

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isUrgent
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: isUrgent
                          ? const Color(0xFFFEF2F2)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.pets,
                        size: 40,
                        color: isUrgent
                            ? const Color(0xFFDC2626)
                            : const Color(0xFFD97706)),
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
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text('NEXT PATIENT • $time',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            if (isUrgent == true) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: const Color(0xFFFCA5A5))),
                                child: const Text('URGENT CASE',
                                    style: TextStyle(
                                        color: Color(0xFFDC2626),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ] else ...[
                              const Text('Confirmed Visit',
                                  style: TextStyle(
                                      color: Color(0xFF16A34A),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(petName,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A))),
                        Text('$breed • Owner: $owner',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildInfoTag('REASON FOR VISIT', reason),
                            const SizedBox(width: 12),
                            _buildInfoTag('PREVIOUS NOTE', note),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Start Consultation',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () => _showStartConsultationDialog(
                        context, data, petName, petId),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyPatientCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_available_outlined,
              size: 40, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(
            'No Active ${_selectedDoctorFilter} Scheduled',
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'There are currently no active appointments matching this filter.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8))),
          Text(value,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155))),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Lab Results',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A))),
              TextButton(
                onPressed: () {},
                child: const Text('View All Records',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: _db.collection('health_monitoring').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.hasData ? snapshot.data!.docs : [];

              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text(
                      'No pending laboratory records for review.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }

              return Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.8),
                  1: FlexColumnWidth(2.2),
                  2: FlexColumnWidth(1.8),
                  3: FlexColumnWidth(1.5),
                  4: FlexColumnWidth(0.8),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  const TableRow(
                    children: [
                      _DoctorTableHeader('PATIENT'),
                      _DoctorTableHeader('TEST TYPE'),
                      _DoctorTableHeader('REQUESTED BY'),
                      _DoctorTableHeader('STATUS'),
                      _DoctorTableHeader('ACTION'),
                    ],
                  ),
                  ...docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final patient =
                        data['patientName'] ?? data['petName'] ?? 'Patient';
                    final test = data['testType'] ?? 'Checkup Test';
                    final doctor = data['requestedBy'] ?? _currentDoctorName;
                    final status = (data['status'] ?? 'Completed')
                        .toString()
                        .toUpperCase();
                    final isDone = status.contains('COMPLETED');

                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(patient,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A))),
                        ),
                        Text(test,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF334155))),
                        Text(doctor,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF334155))),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDone
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(status,
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isDone
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFF64748B))),
                        ),
                        const Icon(Icons.description_outlined,
                            size: 18, color: Color(0xFF64748B)),
                      ],
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // START CONSULTATION DIALOG WITH REAL-TIME VITAL SIGNS FETCHED FROM CHECKUP / HEALTH_MONITORING
  void _showStartConsultationDialog(BuildContext context,
      Map<String, dynamic> data, String petName, String? petId) {
    final diagnosisController = TextEditingController();
    final prescriptionController = TextEditingController();
    final doctorNotesController = TextEditingController();

    final owner = data['ownerName'] ?? 'Owner';
    final service = data['service'] ?? 'General Checkup';
    final isUrgent = data['isUrgent'] ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: 680,
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: const Icon(Icons.medical_services_rounded,
                                color: Color(0xFF0284C7), size: 26),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Consultation: $petName',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (isUrgent == true) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: const Color(0xFFFCA5A5)),
                                      ),
                                      child: const Text(
                                        'URGENT',
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFDC2626)),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Owner: $owner • Service: $service',
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 22, color: Color(0xFF94A3B8)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // REAL-TIME VITAL SIGNS FETCHED FROM CHECKUP / HEALTH_MONITORING DATABASE
                  const Text(
                    'PATIENT VITAL SIGNS (RECORDED BY ADMIN)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<QuerySnapshot>(
                    future: petId != null
                        ? _db
                            .collection('checkup_records')
                            .where('petId', isEqualTo: petId)
                            .orderBy('createdAt', descending: true)
                            .limit(1)
                            .get()
                        : null,
                    builder: (context, vitalsSnapshot) {
                      String weight = 'N/A';
                      String temp = 'N/A';
                      String pulse = 'N/A';

                      if (vitalsSnapshot.hasData &&
                          vitalsSnapshot.data!.docs.isNotEmpty) {
                        final vData = vitalsSnapshot.data!.docs.first.data()
                            as Map<String, dynamic>;
                        weight = '${vData['weight'] ?? '12.0'} kg';
                        temp = '${vData['temperature'] ?? '38.5'} °C';
                        pulse = '${vData['pulse'] ?? '110'} bpm';
                      }

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildVitalBadge('Weight', weight,
                                Icons.monitor_weight_outlined),
                            _buildVitalBadge(
                                'Temperature', temp, Icons.thermostat_outlined),
                            _buildVitalBadge(
                                'Pulse / HR', pulse, Icons.favorite_border),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // FIELD 1: CLINICAL DIAGNOSIS
                  const Text(
                    'CLINICAL DIAGNOSIS*',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: diagnosisController,
                    minLines: 3,
                    maxLines: 6,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF0F172A), height: 1.4),
                    decoration: InputDecoration(
                      hintText:
                          'Enter detailed clinical findings or diagnosis...',
                      hintStyle: const TextStyle(
                          fontSize: 13, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF0F172A), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // FIELD 2: PRESCRIBED MEDICATIONS / TREATMENT
                  const Text(
                    'PRESCRIBED MEDICATIONS / TREATMENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: prescriptionController,
                    minLines: 3,
                    maxLines: 6,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF0F172A), height: 1.4),
                    decoration: InputDecoration(
                      hintText:
                          'List prescribed meds, dosage, and frequency...',
                      hintStyle: const TextStyle(
                          fontSize: 13, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF0F172A), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // FIELD 3: VETERINARIAN NOTES
                  const Text(
                    'VETERINARIAN NOTES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: doctorNotesController,
                    minLines: 4,
                    maxLines: 8,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF0F172A), height: 1.4),
                    decoration: InputDecoration(
                      hintText:
                          'Add follow-up instructions, diet advice, or special remarks...',
                      hintStyle: const TextStyle(
                          fontSize: 13, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF0F172A), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ACTION BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 26, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text(
                          'Complete Consultation',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Consultation for $petName completed successfully!'),
                            ),
                          );
                        },
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
  }

  Widget _buildVitalBadge(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF16A34A)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534))),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A))),
          ],
        ),
      ],
    );
  }
}

class _DoctorTableHeader extends StatelessWidget {
  final String label;
  const _DoctorTableHeader(this.label);

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
