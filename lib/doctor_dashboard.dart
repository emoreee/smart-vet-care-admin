import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_dashboard.dart';
import 'doctor_messages.dart';
import 'doctor_patient_directory.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Target Doctor Info based on Firestore Schema
  final String _currentDoctorId = 'DOC-00001';
  final String _currentDoctorName = 'Dr. Tamesis';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // 1. DOCTOR SIDEBAR MENU
          _buildDoctorSidebar(context),

          // 2. MAIN DOCTOR DASHBOARD CONTENT
          Expanded(
            child: Column(
              children: [
                // Top Header Search Bar
                _buildTopHeader(context),

                // Main Scrollable Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dynamic Welcome Header
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

                        // 1.) FIRESTORE CONNECTED TOP STAT CARDS
                        _buildStatCardsRow(),
                        const SizedBox(height: 24),

                        // MAIN MIDDLE ROW: Next Patient Consultation + Daily Schedule
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Side: Next Patient Card & Recent Lab Results
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  // 2.) NEXT PATIENT ASSIGNED TO DR. TAMESIS
                                  _buildNextPatientCard(),
                                  const SizedBox(height: 24),

                                  // 4.) RECENT LAB RESULTS (UI MAINTAINED)
                                  _buildRecentLabResultsCard(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),

                            // Right Side: 3.) DAILY SCHEDULE FOR DR. TAMESIS
                            Expanded(
                              flex: 2,
                              child: _buildDailyScheduleCard(),
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
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // DOCTOR SIDEBAR WITH DR. TAMESIS PROFILE
  // -------------------------------------------------------------
  Widget _buildDoctorSidebar(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          // Logo & App Name
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

          // Navigation Links
          _buildSidebarNavItem(
              icon: Icons.dashboard_outlined,
              label: 'Main Dashboard',
              isActive: true),
          _buildSidebarNavItem(
              icon: Icons.pets_outlined,
              label: 'Patient Directory',
              isActive: false),
          _buildSidebarNavItem(
              icon: Icons.mail_outline, label: 'Messages', isActive: false),

          const Spacer(),

          // 🔄 DR. TAMESIS PROFILE TILE
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen()),
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
      {required IconData icon, required String label, required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E293B) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isActive ? Colors.white : const Color(0xFF94A3B8), size: 18),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  // -------------------------------------------------------------
  // TOP HEADER WIDGET
  // -------------------------------------------------------------
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

  // -------------------------------------------------------------
  // FIRESTORE CONNECTED STAT CARDS FOR DR. TAMESIS
  // -------------------------------------------------------------
  Widget _buildStatCardsRow() {
    return Row(
      children: [
        // 1. PATIENTS TODAY (ACTIVE / CONFIRMED FOR DR. TAMESIS)
        StreamBuilder<QuerySnapshot>(
          stream: _db.collection('appointments').snapshots(),
          builder: (context, snapshot) {
            int activeCount = 0;
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              activeCount = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final docName =
                    (data['doctor'] ?? data['assignedDoctor'] ?? '').toString();
                final docId = (data['doctorId'] ?? '').toString();
                final status = (data['status'] ?? '').toString().toLowerCase();

                bool isMyDoctor =
                    docName.contains('Tamesis') || docId == _currentDoctorId;
                bool isActiveStatus =
                    status == 'confirmed' || status == 'in progress';

                return isMyDoctor && isActiveStatus;
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
            );
          },
        ),
        const SizedBox(width: 16),

        // 2. PENDING LAB RESULTS (CONNECTS TO HEALTH_MONITORING / LABS)
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
            );
          },
        ),
        const SizedBox(width: 16),

        // 3. URGENT CONSULTATIONS (CONNECTS TO URGENT STATUS IN FIRESTORE)
        StreamBuilder<QuerySnapshot>(
          stream: _db.collection('appointments').snapshots(),
          builder: (context, snapshot) {
            int urgentCount = 0;
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              urgentCount = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final status = (data['status'] ?? data['priority'] ?? '')
                    .toString()
                    .toLowerCase();
                final docName =
                    (data['doctor'] ?? data['assignedDoctor'] ?? '').toString();
                final docId = (data['doctorId'] ?? '').toString();

                bool isMyDoctor =
                    docName.contains('Tamesis') || docId == _currentDoctorId;
                bool isUrgent = status == 'urgent' || status == 'emergency';

                return isMyDoctor && isUrgent;
              }).length;
            }

            return _buildStatCard(
              title: 'URGENT CONSULTATIONS',
              value: urgentCount < 10 ? '0$urgentCount' : '$urgentCount',
              subtext: urgentCount > 0
                  ? 'Immediate attention required'
                  : 'No urgent cases',
              subtextColor: urgentCount > 0
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF64748B),
              icon: Icons.error_outline,
              isUrgent: urgentCount > 0,
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
  }) {
    return Expanded(
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  isUrgent ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              if (isUrgent) Container(width: 4, color: const Color(0xFFEF4444)),
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
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF94A3B8))),
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
    );
  }

  // -------------------------------------------------------------
  // NEXT PATIENT CARD (SYNCED WITH ADMIN CONFIRMED APPOINTMENTS)
  // -------------------------------------------------------------
  Widget _buildNextPatientCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('appointments').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyPatientCard();
        }

        // Filter: Assigned to Dr. Tamesis AND Status must be 'Confirmed' or 'In Progress'
        final activeAppointments = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final docName =
              (data['doctor'] ?? data['assignedDoctor'] ?? '').toString();
          final docId = (data['doctorId'] ?? '').toString();
          final status = (data['status'] ?? '').toString().toLowerCase();

          bool isMyDoctor =
              docName.contains('Tamesis') || docId == _currentDoctorId;
          bool isActiveStatus =
              status == 'confirmed' || status == 'in progress';

          return isMyDoctor && isActiveStatus;
        }).toList();

        // Kapag walang Confirmed appointment sa Admin
        if (activeAppointments.isEmpty) {
          return _buildEmptyPatientCard();
        }

        final data = activeAppointments.first.data() as Map<String, dynamic>;
        final petName = data['patientName'] ?? data['petName'] ?? 'Pet Patient';
        final breed = data['breed'] ?? data['species'] ?? 'Pet';
        final owner = data['ownerName'] ?? data['owner'] ?? 'Pet Owner';
        final petDetails = '$breed • Owner: $owner';
        final reason = data['service'] ?? data['reason'] ?? 'Consultation';
        final time = data['time'] ?? '09:30 AM';
        final note = data['notes'] ?? 'No prior medical notes';

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    const Icon(Icons.pets, size: 40, color: Color(0xFFD97706)),
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
                        const Text('Confirmed Visit',
                            style: TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(petName,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A))),
                    Text(petDetails,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Start Consultation',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  // EMPTY STATE CONTAINER FOR NEXT PATIENT
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
        children: const [
          Icon(Icons.event_available_outlined,
              size: 40, color: Color(0xFF94A3B8)),
          SizedBox(height: 12),
          Text(
            'No Confirmed Patients Scheduled',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A)),
          ),
          SizedBox(height: 4),
          Text(
            'There are currently no confirmed appointments for Dr. Tamesis.',
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

  // -------------------------------------------------------------
  // 4.) RECENT LAB RESULTS CARD (STAY TUNED - UI MAINTAINED)
  // -------------------------------------------------------------
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
                      color: Color(0xFF0F172A))),
              TextButton(
                  onPressed: () {},
                  child: const Text('View All Records',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B)))),
            ],
          ),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(2.0),
              2: FlexColumnWidth(1.5),
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
              _buildLabRow('Luna\n(Feline)', 'Complete Blood Count',
                  'Dr. Tamesis', 'COMPLETED', true),
              _buildLabRow('Max\n(Canine)', 'Urinalysis Panel', 'Dr. Tamesis',
                  'PENDING', false),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildLabRow(
      String patient, String test, String doctor, String status, bool isDone) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(patient,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A))),
        ),
        Text(test,
            style: const TextStyle(fontSize: 11, color: Color(0xFF334155))),
        Text(doctor,
            style: const TextStyle(fontSize: 11, color: Color(0xFF334155))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
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
            size: 16, color: Color(0xFF64748B)),
      ],
    );
  }

  // -------------------------------------------------------------
  // DAILY SCHEDULE TIMELINE (ONLY SHOWS CONFIRMED/IN PROGRESS)
  // -------------------------------------------------------------
  Widget _buildDailyScheduleCard() {
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
                      color: Color(0xFF0F172A))),
              Text('Today',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: _db.collection('appointments').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyScheduleText();
              }

              final doctorSchedule = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final docName =
                    (data['doctor'] ?? data['assignedDoctor'] ?? '').toString();
                final docId = (data['doctorId'] ?? '').toString();
                final status = (data['status'] ?? '').toString().toLowerCase();

                bool isMyDoctor =
                    docName.contains('Tamesis') || docId == _currentDoctorId;
                bool isActiveStatus =
                    status == 'confirmed' || status == 'in progress';

                return isMyDoctor && isActiveStatus;
              }).toList();

              if (doctorSchedule.isEmpty) {
                return _buildEmptyScheduleText();
              }

              return Column(
                children: doctorSchedule.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final pet =
                      data['patientName'] ?? data['petName'] ?? 'Pet Patient';
                  final service =
                      data['service'] ?? data['reason'] ?? 'Checkup';
                  final owner =
                      data['ownerName'] ?? data['owner'] ?? 'Pet Owner';
                  final time = data['time'] ?? '09:30 AM';
                  final isUrgent =
                      (data['status'] ?? '').toString() == 'Urgent';

                  return _buildScheduleTimelineItem(
                      time, '$pet ($service)', owner,
                      isUrgent: isUrgent);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScheduleText() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: Text(
          'No scheduled checkups for today.',
          style: TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildScheduleTimelineItem(String time, String title, String subtitle,
      {bool isActive = false, bool isUrgent = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Text(time,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isUrgent
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF64748B))),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUrgent
                    ? const Color(0xFFFEF2F2)
                    : (isActive
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isUrgent
                        ? const Color(0xFFFECACA)
                        : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isUrgent
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF0F172A))),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ),
        ],
      ),
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
