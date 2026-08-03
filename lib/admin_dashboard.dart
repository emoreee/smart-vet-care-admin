import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sidebar.dart';

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
          // Sidebar Component
          const SidebarMenu(activeRoute: '/dashboard'),

          // Main Admin Content Area
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

                        // STAT CARDS ROW
                        _buildStatCardsRow(),
                        const SizedBox(height: 24),

                        // MAIN MIDDLE ROW: Upcoming Appointments Table + Demographics
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              flex: 3,
                              child: UpcomingAppointmentsCardWidget(),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 2,
                              child: _buildDemographicsCard(),
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

  // Header Search & Admin Profile Bar
  Widget _buildTopHeader() {
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
                hintText: 'Search patients, owners, or records...',
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
                icon: const Icon(Icons.help_outline,
                    color: Color(0xFF64748B), size: 20),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.grid_view,
                    color: Color(0xFF64748B), size: 20),
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Admin Profile',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A))),
                  Text('Clinic Manager',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
              const SizedBox(width: 8),
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

  // Stat Cards (Appointments Today Filtered for Active Only)
  Widget _buildStatCardsRow() {
    return Row(
      children: [
        // 1. APPOINTMENTS TODAY
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('appointments').snapshots(),
            builder: (context, snapshot) {
              int count = 0;
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                count = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status =
                      (data['status'] ?? '').toString().toLowerCase();
                  return status != 'completed' && status != 'cancelled';
                }).length;
              }

              return _buildSingleStatCard(
                title: 'APPOINTMENTS TODAY',
                count: '$count',
                subtext: count > 0 ? '↑ Active schedule' : 'No appointments',
                subtextColor: const Color(0xFF16A34A),
                borderColor: const Color(0xFF22C55E),
              );
            },
          ),
        ),
        const SizedBox(width: 16),

        // 2. IN-PATIENT (DYNAMIC FROM FIRESTORE PETS)
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('pets').snapshots(),
            builder: (context, snapshot) {
              int admittedCount = 0;
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                admittedCount = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status =
                      (data['status'] ?? data['admissionStatus'] ?? '')
                          .toString()
                          .toLowerCase();
                  return status == 'admitted' || status == 'in-patient';
                }).length;
              }

              return _buildSingleStatCard(
                title: 'IN-PATIENT',
                count:
                    admittedCount < 10 ? '0$admittedCount' : '$admittedCount',
                subtext: admittedCount > 0
                    ? '— Active admissions'
                    : '— No admitted patients',
                subtextColor: const Color(0xFF64748B),
                borderColor: const Color(0xFF3B82F6),
              );
            },
          ),
        ),
        const SizedBox(width: 16),

        // 3. URGENT CASES
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db
                .collection('appointments')
                .where('status', isEqualTo: 'Urgent')
                .snapshots(),
            builder: (context, snapshot) {
              int urgentCount =
                  snapshot.hasData ? snapshot.data!.docs.length : 0;
              return _buildSingleStatCard(
                title: 'URGENT CASES',
                count: urgentCount < 10 ? '0$urgentCount' : '$urgentCount',
                subtext: urgentCount > 0
                    ? '✶ Requires immediate attention'
                    : 'No urgent cases',
                subtextColor: urgentCount > 0
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF64748B),
                borderColor: const Color(0xFFEF4444),
              );
            },
          ),
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
    return Container(
      height: 110,
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF94A3B8))),
                    const SizedBox(height: 4),
                    Text(count,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DYNAMIC PATIENT'S DEMOGRAPHICS FROM FIRESTORE 'PETS' COLLECTION
  Widget _buildDemographicsCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Patient\'s Demographics',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A))),
              Icon(Icons.info_outline, size: 18, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 24),
          StreamBuilder<QuerySnapshot>(
            stream: _db.collection('pets').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final docs = snapshot.hasData ? snapshot.data!.docs : [];
              final totalPets = docs.length;

              int dogs = 0;
              int cats = 0;
              int others = 0;

              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final species =
                    (data['species'] ?? data['type'] ?? data['petType'] ?? '')
                        .toString()
                        .toLowerCase();

                if (species.contains('dog') || species.contains('canine')) {
                  dogs++;
                } else if (species.contains('cat') ||
                    species.contains('feline')) {
                  cats++;
                } else {
                  others++;
                }
              }

              double dogsPct = totalPets > 0 ? (dogs / totalPets) * 100 : 0;
              double catsPct = totalPets > 0 ? (cats / totalPets) * 100 : 0;
              double othersPct = totalPets > 0 ? (others / totalPets) * 100 : 0;

              return Column(
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: totalPets > 0 ? (dogs / totalPets) : 0,
                            strokeWidth: 16,
                            backgroundColor: const Color(0xFF334155),
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('TOTAL',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.bold)),
                            Text('$totalPets',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDemographicRow(
                      color: const Color(0xFF334155),
                      label: 'Dogs',
                      percentage: '${dogsPct.toStringAsFixed(1)}%'),
                  const SizedBox(height: 8),
                  _buildDemographicRow(
                      color: const Color(0xFF94A3B8),
                      label: 'Cats',
                      percentage: '${catsPct.toStringAsFixed(1)}%'),
                  const SizedBox(height: 8),
                  _buildDemographicRow(
                      color: const Color(0xFFEF4444),
                      label: 'Others',
                      percentage: '${othersPct.toStringAsFixed(1)}%'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicRow(
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
            const SizedBox(width: 8),
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
// UPCOMING APPOINTMENTS CARD WIDGET WITH LOCAL DIALOGS
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
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
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
                    color: Color(0xFF0F172A)),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
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

              final allDocs = snapshot.hasData ? snapshot.data!.docs : [];
              final docs = allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final status = (data['status'] ?? '').toString().toLowerCase();
                return status != 'completed' && status != 'cancelled';
              }).toList();

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

              if (totalItems == 0) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Text(
                      'No upcoming appointments scheduled.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }

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
                      ...pageDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        final name = data['patientName'] ??
                            data['petName'] ??
                            data['patient'] ??
                            data['name'] ??
                            'Pet Patient';
                        final breed = data['breed'] ?? data['species'] ?? 'Pet';
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
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Showing ${startIndex + 1}-$endIndex of $totalItems upcoming appointments',
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(patientName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF0F172A))),
              Text(breed,
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
        Text(service,
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
        Text(time,
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
        _buildStatusBadge(status),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF64748B)),
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  Text('Change Status',
                      style: TextStyle(fontSize: 12, color: Color(0xFF0F172A))),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 16, color: Color(0xFF475569)),
                  SizedBox(width: 10),
                  Text('Edit Details',
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

    switch (status.toLowerCase()) {
      case 'confirmed':
        bgColor = const Color(0xFFE0F2FE);
        textColor = const Color(0xFF0284C7);
        break;
      case 'in progress':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        break;
      case 'completed':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        break;
      case 'pending':
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  // Local Method: Change Status Dialog
  void _showChangeStatusDialog(
      BuildContext context, String docId, String currentStatus) {
    String selectedStatus = currentStatus;

    final List<Map<String, dynamic>> statusOptions = [
      {
        'title': 'Confirmed',
        'subtitle': 'Appointment is verified and scheduled',
        'color': const Color(0xFF0284C7),
        'bgColor': const Color(0xFFF0F9FF)
      },
      {
        'title': 'In Progress',
        'subtitle': 'Patient is undergoing procedure',
        'color': const Color(0xFFD97706),
        'bgColor': const Color(0xFFFFFBEB)
      },
      {
        'title': 'Completed',
        'subtitle': 'Checkup finished and record updated',
        'color': const Color(0xFF16A34A),
        'bgColor': const Color(0xFFF0FDF4)
      },
      {
        'title': 'Pending',
        'subtitle': 'Awaiting confirmation or client check-in',
        'color': const Color(0xFF64748B),
        'bgColor': const Color(0xFFF8FAFC)
      },
      {
        'title': 'Cancelled',
        'subtitle': 'Appointment was called off',
        'color': const Color(0xFFDC2626),
        'bgColor': const Color(0xFFFEF2F2)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Update Appointment Status',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A))),
                        IconButton(
                            icon: const Icon(Icons.close,
                                size: 20, color: Color(0xFF64748B)),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ...statusOptions.map((opt) {
                      final isSelected = selectedStatus == opt['title'];
                      final Color statusColor = opt['color'] as Color;
                      final Color cardBg = opt['bgColor'] as Color;

                      return GestureDetector(
                        onTap: () => setDialogState(
                            () => selectedStatus = opt['title'] as String),
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
                                width: isSelected ? 2.0 : 1.0),
                          ),
                          child: Row(
                            children: [
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
                                      width: 2),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                        size: 14, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(opt['title'] as String,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? statusColor
                                                : const Color(0xFF334155))),
                                    Text(opt['subtitle'] as String,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: isSelected
                                                ? statusColor.withOpacity(0.85)
                                                : const Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel',
                                style: TextStyle(color: Color(0xFF64748B)))),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white),
                          onPressed: () {
                            if (!docId.startsWith('mock_')) {
                              _db
                                  .collection('appointments')
                                  .doc(docId)
                                  .update({'status': selectedStatus});
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('Status updated to $selectedStatus')));
                          },
                          child: const Text('Save Status'),
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

  // Local Method: Edit Details Dialog
  void _showEditAppointmentDialog(
      BuildContext context, String docId, String currentService) {
    final TextEditingController serviceController =
        TextEditingController(text: currentService);
    final TextEditingController doctorController =
        TextEditingController(text: 'Dr. Tamesis');

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Appointment Details',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 16),
                TextField(
                  controller: serviceController,
                  decoration: const InputDecoration(
                      labelText: 'Service', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: doctorController,
                  decoration: const InputDecoration(
                      labelText: 'Assigned Doctor',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white),
                      onPressed: () {
                        if (!docId.startsWith('mock_')) {
                          _db.collection('appointments').doc(docId).update({
                            'service': serviceController.text,
                            'doctor': doctorController.text,
                          });
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Details updated!')));
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
