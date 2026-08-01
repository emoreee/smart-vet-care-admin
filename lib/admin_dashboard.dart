import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sidebar.dart';
import 'appointment_management.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // 1. SHARED ADMIN SIDEBAR
          const SidebarMenu(activeRoute: 'dashboard'),

          // 2. MAIN DASHBOARD CONTENT AREA
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
                        // Title Section
                        const Text(
                          'Clinic Overview',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Real-time status',
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 24),

                        // 1.) TOP STAT CARDS (FIRESTORE CONNECTED)
                        _buildStatCardsRow(),
                        const SizedBox(height: 24),

                        // GRID ROW: Upcoming Appointments + Patient Demographics
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 2.) UPCOMING APPOINTMENTS TABLE (PAGINATED & FIRESTORE CONNECTED)
                            const Expanded(
                              flex: 3,
                              child: UpcomingAppointmentsCardWidget(),
                            ),
                            const SizedBox(width: 24),

                            // 3.) PATIENT DEMOGRAPHICS CHART (FIRESTORE CONNECTED)
                            Expanded(
                              flex: 2,
                              child: _buildPatientDemographicsCard(),
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
          // Search Input
          Container(
            width: 380,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search patients, owners, or records...',
                hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                prefixIcon:
                    Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),

          // Profile & Role Action
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.help_outline,
                    color: Color(0xFF64748B), size: 20),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.grid_view,
                    color: Color(0xFF64748B), size: 20),
                onPressed: () {},
              ),
              const SizedBox(width: 16),

              // Admin Switch Profile Button
              InkWell(
                onTap: () => SidebarMenu.showRoleSwitcherModal(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('Admin Profile',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF0F172A))),
                          Text('Clinic Manager',
                              style: TextStyle(
                                  fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      ),
                      const SizedBox(width: 10),
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFFCBD5E1),
                        child: Icon(Icons.person,
                            color: Color(0xFF0F172A), size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 1.) FIRESTORE CONNECTED STAT CARDS
  // -------------------------------------------------------------
  Widget _buildStatCardsRow() {
    return Row(
      children: [
        // APPOINTMENTS TODAY
        StreamBuilder<QuerySnapshot>(
          stream: _db.collection('appointments').snapshots(),
          builder: (context, snapshot) {
            int count = snapshot.hasData ? snapshot.data!.docs.length : 24;
            return _buildSingleStatCard(
              title: 'APPOINTMENTS TODAY',
              count: '$count',
              subtext: '↑ +12% from yesterday',
              subtextColor: const Color(0xFF16A34A),
              borderColor: const Color(0xFF22C55E),
            );
          },
        ),
        const SizedBox(width: 16),

        // IN-PATIENT
        StreamBuilder<QuerySnapshot>(
          stream: _db.collection('health_monitoring').snapshots(),
          builder: (context, snapshot) {
            int count = snapshot.hasData ? snapshot.data!.docs.length : 8;
            return _buildSingleStatCard(
              title: 'IN-PATIENT',
              count: count < 10 ? '0$count' : '$count',
              subtext: '— Stable capacity',
              subtextColor: const Color(0xFF64748B),
              borderColor: const Color(0xFF3B82F6),
            );
          },
        ),
        const SizedBox(width: 16),

        // URGENT CASES
        StreamBuilder<QuerySnapshot>(
          stream: _db
              .collection('appointments')
              .where('status', isEqualTo: 'Urgent')
              .snapshots(),
          builder: (context, snapshot) {
            int count = snapshot.hasData ? snapshot.data!.docs.length : 3;
            return _buildSingleStatCard(
              title: 'URGENT CASES',
              count: count < 10 ? '0$count' : '$count',
              subtext: '✶ Requires immediate attention',
              subtextColor: const Color(0xFFDC2626),
              borderColor: const Color(0xFFEF4444),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSingleStatCard({
    required String title,
    required String count,
    required String subtext,
    required Color subtextColor,
    required Color borderColor,
  }) {
    return Expanded(
      child: Container(
        height: 125,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(width: 4, color: borderColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF94A3B8))),
                      const SizedBox(height: 4),
                      Text(count,
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      Text(
                        subtext,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: subtextColor),
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
  // 3.) FIRESTORE CONNECTED PATIENT DEMOGRAPHICS CARD
  // -------------------------------------------------------------
  Widget _buildPatientDemographicsCard() {
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
              const Text('Patient\'s Demographics',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A))),
              IconButton(
                  icon: const Icon(Icons.info_outline,
                      size: 18, color: Color(0xFF94A3B8)),
                  onPressed: () {}),
            ],
          ),
          const SizedBox(height: 20),

          // Real-time Firestore Demographics Calculation
          StreamBuilder<QuerySnapshot>(
            stream: _db.collection('pets').snapshots(),
            builder: (context, snapshot) {
              int total = 1240;
              double dogsPct = 65.2;
              double catsPct = 28.7;
              double othersPct = 6.1;

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                total = snapshot.data!.docs.length;
                int dogs = 0;
                int cats = 0;
                int others = 0;

                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final species =
                      (data['species'] ?? '').toString().toLowerCase();
                  if (species.contains('dog') || species.contains('canine')) {
                    dogs++;
                  } else if (species.contains('cat') ||
                      species.contains('feline')) {
                    cats++;
                  } else {
                    others++;
                  }
                }

                if (total > 0) {
                  dogsPct =
                      double.parse(((dogs / total) * 100).toStringAsFixed(1));
                  catsPct =
                      double.parse(((cats / total) * 100).toStringAsFixed(1));
                  othersPct =
                      double.parse(((others / total) * 100).toStringAsFixed(1));
                }
              }

              return Column(
                children: [
                  // Donut Chart Graphic
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 18,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: (100 - dogsPct) / 100,
                            strokeWidth: 18,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: othersPct / 100,
                            strokeWidth: 18,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('TOTAL',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF94A3B8))),
                            Text('$total',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Legend Items
                  _buildDemographicLegendItem(
                      color: const Color(0xFF0F172A),
                      label: 'Dogs',
                      percentage: '$dogsPct%'),
                  const SizedBox(height: 12),
                  _buildDemographicLegendItem(
                      color: const Color(0xFF64748B),
                      label: 'Cats',
                      percentage: '$catsPct%'),
                  const SizedBox(height: 12),
                  _buildDemographicLegendItem(
                      color: const Color(0xFFEF4444),
                      label: 'Others',
                      percentage: '$othersPct%'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicLegendItem(
      {required Color color,
      required String label,
      required String percentage}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
          ],
        ),
        Text(percentage,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A))),
      ],
    );
  }
}

// -------------------------------------------------------------
// SEPARATE PAGINATED UPCOMING APPOINTMENTS WIDGET CLASS
// -------------------------------------------------------------
class UpcomingAppointmentsCardWidget extends StatefulWidget {
  const UpcomingAppointmentsCardWidget({super.key});

  @override
  State<UpcomingAppointmentsCardWidget> createState() =>
      _UpcomingAppointmentsCardWidgetState();
}

class _UpcomingAppointmentsCardWidgetState
    extends State<UpcomingAppointmentsCardWidget> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  int _currentPage = 0;
  final int _pageSize = 5;

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Upcoming Appointments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const AppointmentManagementScreen()),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _db.collection('appointments').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final docs = snapshot.hasData ? snapshot.data!.docs : [];
              final totalItems = docs.length;

              final totalPages =
                  totalItems > 0 ? (totalItems / _pageSize).ceil() : 1;
              final startIndex = _currentPage * _pageSize;
              final endIndex = (startIndex + _pageSize < totalItems)
                  ? startIndex + _pageSize
                  : totalItems;

              final pageDocs = (startIndex < totalItems)
                  ? docs.sublist(startIndex, endIndex)
                  : [];

              return Column(
                children: [
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2.0),
                      1: FlexColumnWidth(2.2),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(1.5),
                      4: FlexColumnWidth(0.8),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      const TableRow(
                        children: [
                          _TableHeader('PATIENT'),
                          _TableHeader('SERVICE'),
                          _TableHeader('TIME'),
                          _TableHeader('STATUS'),
                          _TableHeader('ACTIONS'),
                        ],
                      ),
                      if (pageDocs.isNotEmpty)
                        ...pageDocs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          final name = data['patientName'] ??
                              data['petName'] ??
                              data['patient'] ??
                              data['name'] ??
                              'Pet Patient';
                          final breed =
                              data['breed'] ?? data['species'] ?? 'Pet';
                          final service = data['service'] ??
                              data['reason'] ??
                              data['type'] ??
                              'Consultation';
                          final time = data['time'] ?? '09:00 AM';
                          final status = data['status'] ?? 'Confirmed';

                          return _buildAppointmentRow(
                            context: context,
                            docId: doc.id,
                            patientName: name,
                            breed: breed,
                            service: service,
                            time: time,
                            status: status,
                          );
                        })
                      else ...[
                        _buildAppointmentRow(
                          context: context,
                          docId: 'mock_1',
                          patientName: 'Cooper',
                          breed: 'Beagle',
                          service: 'Vaccination Booster',
                          time: '09:30 AM',
                          status: 'Confirmed',
                        ),
                        _buildAppointmentRow(
                          context: context,
                          docId: 'mock_2',
                          patientName: 'Luna',
                          breed: 'Maine Coon',
                          service: 'Dental Cleaning',
                          time: '10:15 AM',
                          status: 'In Progress',
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),

                  // Pagination Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        totalItems > 0
                            ? 'Showing ${startIndex + 1}-$endIndex of $totalItems appointments'
                            : 'Showing 0-0 of 0 appointments',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 20),
                            color: const Color(0xFF0F172A),
                            disabledColor: const Color(0xFFCBD5E1),
                            onPressed: _currentPage > 0
                                ? () => setState(() => _currentPage--)
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_currentPage + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, size: 20),
                            color: const Color(0xFF0F172A),
                            disabledColor: const Color(0xFFCBD5E1),
                            onPressed: (_currentPage + 1) < totalPages
                                ? () => setState(() => _currentPage++)
                                : null,
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
    );
  }

  TableRow _buildAppointmentRow({
    required BuildContext context,
    required String docId,
    required String patientName,
    required String breed,
    required String service,
    required String time,
    required String status,
  }) {
    return TableRow(
      children: [
        // PATIENT COLUMN
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patientName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                breed,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),

        // SERVICE COLUMN
        Text(
          service,
          style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
        ),

        // TIME COLUMN
        Text(
          time,
          style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
        ),

        // STATUS BADGE
        _buildStatusBadge(status),

        // ACTIONS MENU (POPUP) - RESCHEDULE REMOVED
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF64748B)),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            if (value == 'status') {
              _showChangeStatusDialog(context, docId, status);
            } else if (value == 'edit') {
              _showEditAppointmentDialog(context, docId, service);
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'status',
              child: Row(
                children: [
                  Icon(Icons.sync, size: 16, color: Color(0xFF0284C7)),
                  SizedBox(width: 10),
                  Text(
                    'Change Status',
                    style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Color(0xFF475569),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Edit Details',
                    style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // COLORFUL & DYNAMIC CHANGE STATUS DIALOG
  // -------------------------------------------------------------
  void _showChangeStatusDialog(
      BuildContext context, String docId, String currentStatus) {
    String selectedStatus = currentStatus;

    // List ng Appointment Statuses na may color thematic mapping
    final List<Map<String, dynamic>> statusOptions = [
      {
        'title': 'Confirmed',
        'subtitle': 'Appointment is verified and scheduled for clinic visit',
        'color': const Color(0xFF0284C7), // Blue
        'bgColor': const Color(0xFFF0F9FF),
      },
      {
        'title': 'In Progress',
        'subtitle':
            'Patient is currently being attended or undergoing procedure',
        'color': const Color(0xFFD97706), // Amber
        'bgColor': const Color(0xFFFFFBEB),
      },
      {
        'title': 'Completed',
        'subtitle': 'Checkup / Treatment finished and record updated',
        'color': const Color(0xFF16A34A), // Green
        'bgColor': const Color(0xFFF0FDF4),
      },
      {
        'title': 'Pending',
        'subtitle': 'Awaiting confirmation or client check-in',
        'color': const Color(0xFF64748B), // Slate Gray
        'bgColor': const Color(0xFFF8FAFC),
      },
      {
        'title': 'Cancelled',
        'subtitle': 'Appointment was called off or missed',
        'color': const Color(0xFFDC2626), // Red
        'bgColor': const Color(0xFFFEF2F2),
      },
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modal Header with Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Update Appointment Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              size: 20, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Select current health or clinic status of patient.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 20),

                    // Colorful Status Cards List
                    ...statusOptions.map((opt) {
                      final isSelected = selectedStatus == opt['title'];
                      final Color statusColor = opt['color'] as Color;
                      final Color cardBg = opt['bgColor'] as Color;

                      return GestureDetector(
                        onTap: () {
                          setDialogState(
                              () => selectedStatus = opt['title'] as String);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? cardBg : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? statusColor
                                  : const Color(0xFFE2E8F0),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: statusColor.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              // Selection Circle with Dynamic Color
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? statusColor
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? statusColor
                                        : const Color(0xFF94A3B8),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                        size: 14, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 14),

                              // Text Titles
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt['title'] as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? statusColor
                                            : const Color(0xFF334155),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      opt['subtitle'] as String,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected
                                            ? statusColor.withOpacity(0.85)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Action Buttons (Cancel & Dynamic Save Status)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (!docId.startsWith('mock_')) {
                              _db
                                  .collection('appointments')
                                  .doc(docId)
                                  .update({'status': selectedStatus});
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Status updated to $selectedStatus'),
                                backgroundColor: const Color(0xFF0F172A),
                              ),
                            );
                          },
                          child: const Text(
                            'Save Status',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------
  // UPDATED EDIT DETAILS DIALOG (MATCHED DESIGN SYSTEM)
  // -------------------------------------------------------------
  void _showEditAppointmentDialog(
      BuildContext context, String docId, String currentService) {
    // Pre-fill existing data
    final TextEditingController serviceController =
        TextEditingController(text: currentService);
    final TextEditingController doctorController =
        TextEditingController(text: 'Dr. James Nico Martinez');
    final TextEditingController dateController =
        TextEditingController(text: '2026-08-02');
    final TextEditingController timeController =
        TextEditingController(text: '09:00 AM - 10:00 AM');
    final TextEditingController notesController =
        TextEditingController(text: '');

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modal Header with Close (X) Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Appointment Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            size: 20, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ROW 1: SERVICE & ASSIGNED DOCTOR
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormInputField(
                          label: 'SERVICE*',
                          child: TextField(
                            controller: serviceController,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF0F172A)),
                            decoration: _getInputDecoration(
                                hint: 'e.g. Vaccination, Checkup'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormInputField(
                          label: 'ASSIGNED DOCTOR*',
                          child: TextField(
                            controller: doctorController,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF0F172A)),
                            decoration: _getInputDecoration(
                              hint: 'Select Doctor',
                              suffixIcon: const Icon(Icons.keyboard_arrow_down,
                                  size: 18, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ROW 2: APPOINTMENT DATE & TIME SLOT
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormInputField(
                          label: 'APPOINTMENT DATE*',
                          child: TextField(
                            controller: dateController,
                            readOnly: true,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF0F172A)),
                            decoration: _getInputDecoration(
                              hint: 'YYYY-MM-DD',
                              suffixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: Color(0xFF64748B)),
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2025),
                                lastDate: DateTime(2030),
                              );
                              if (pickedDate != null) {
                                dateController.text =
                                    "${pickedDate.toLocal()}".split(' ')[0];
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormInputField(
                          label: 'TIME SLOT*',
                          child: TextField(
                            controller: timeController,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF0F172A)),
                            decoration: _getInputDecoration(
                              hint: 'Select Time Slot',
                              suffixIcon: const Icon(Icons.keyboard_arrow_down,
                                  size: 18, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ROW 3: NOTES / SPECIAL REQUESTS
                  _buildFormInputField(
                    label: 'NOTES / SPECIAL REQUESTS',
                    child: TextField(
                      controller: notesController,
                      maxLines: 3,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF0F172A)),
                      decoration: _getInputDecoration(
                        hint: 'Add medical notes or specific requests...',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons (Cancel & Save Changes)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (!docId.startsWith('mock_')) {
                            _db.collection('appointments').doc(docId).update({
                              'service': serviceController.text,
                              'doctor': doctorController.text,
                              'date': dateController.text,
                              'time': timeController.text,
                              'notes': notesController.text,
                            });
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Appointment details updated in Firestore!'),
                              backgroundColor: Color(0xFF0F172A),
                            ),
                          );
                        },
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
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

  // Helper Form Field Wrapper with Label Above
  Widget _buildFormInputField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  // Shared Clean Input Decoration Style
  InputDecoration _getInputDecoration(
      {required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  void _showRescheduleDialog(
      BuildContext context, String docId, String currentTime) {
    final TextEditingController timeController =
        TextEditingController(text: currentTime);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Reschedule Appointment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: timeController,
            decoration: const InputDecoration(
              labelText: 'New Appointment Time (e.g. 02:30 PM)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.access_time),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (!docId.startsWith('mock_')) {
                  _db
                      .collection('appointments')
                      .doc(docId)
                      .update({'time': timeController.text});
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Appointment rescheduled successfully!'),
                      backgroundColor: Color(0xFF0F172A)),
                );
              },
              child: const Text('Confirm Reschedule',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFE0F2FE);
    Color color = const Color(0xFF0284C7);

    if (status == 'In Progress') {
      bg = const Color(0xFFFEF3C7);
      color = const Color(0xFFD97706);
    } else if (status == 'Pending') {
      bg = const Color(0xFFF1F5F9);
      color = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: color)),
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
