import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sidebar.dart';

class AppointmentManagementScreen extends StatefulWidget {
  const AppointmentManagementScreen({super.key});

  @override
  State<AppointmentManagementScreen> createState() =>
      _AppointmentManagementScreenState();
}

class _AppointmentManagementScreenState
    extends State<AppointmentManagementScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _searchQuery = '';
  String _selectedFilter = 'All';

  bool _isDateInCurrentWeek(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      final appDate = DateTime.parse(dateStr);
      final now = DateTime.now();

      final startOfWeek =
          DateTime(now.year, now.month, now.day - now.weekday % 7);
      final endOfWeek = startOfWeek
          .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      return appDate
              .isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
          appDate.isBefore(endOfWeek);
    } catch (e) {
      return false;
    }
  }

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

  DateTime _getAppointmentBookingTime(Map<String, dynamic> data) {
    try {
      if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
        return (data['createdAt'] as Timestamp).toDate();
      }
      final dateStr = data['date']?.toString().trim() ?? '';
      if (dateStr.isNotEmpty) {
        return DateTime.parse(dateStr);
      }
    } catch (e) {
      // Fallback
    }
    return DateTime(2026, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          const SidebarMenu(activeRoute: '/appointments'),
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 24.0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _db.collection('appointments').snapshots(),
                      builder: (context, snapshot) {
                        final docs =
                            snapshot.hasData ? snapshot.data!.docs : [];

                        final allCount = docs.length;

                        // PENDING ONLY
                        final pendingCount = docs.where((d) {
                          final status =
                              (d.data() as Map<String, dynamic>)['status'] ??
                                  '';
                          return status.toString().toLowerCase() == 'pending';
                        }).length;

                        // CONFIRMED ONLY (EXCLUDES COMPLETED)
                        final confirmedTodayCount = docs.where((d) {
                          final status =
                              (d.data() as Map<String, dynamic>)['status'] ??
                                  '';
                          return status.toString().toLowerCase() == 'confirmed';
                        }).length;

                        // UPCOMING THIS WEEK ONLY (ACTIVE STATUSES ONLY: PENDING / CONFIRMED)
                        final upcomingWeekCount = docs.where((d) {
                          final data = d.data() as Map<String, dynamic>;
                          final status =
                              (data['status'] ?? '').toString().toLowerCase();
                          final dateStr = data['date']?.toString();
                          final isActive =
                              status == 'pending' || status == 'confirmed';
                          return isActive && _isDateInCurrentWeek(dateStr);
                        }).length;

                        // URGENT CASES ONLY (EXCLUDES COMPLETED)
                        final urgentCasesCount = docs.where((d) {
                          final data = d.data() as Map<String, dynamic>;
                          final isUrgent = data['isUrgent'] ?? false;
                          final status =
                              (data['status'] ?? '').toString().toLowerCase();
                          final isActive =
                              status != 'completed' && status != 'cancelled';
                          return isUrgent == true && isActive;
                        }).length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Appointment Management',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  onPressed: () =>
                                      _showScheduleAppointmentDialog(context),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Schedule Appointment',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: TextField(
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val.toLowerCase().trim();
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText:
                                      'Search by Pet ID, Pet Name, Owner, Service, or Doctor...',
                                  hintStyle: TextStyle(
                                      fontSize: 12, color: Color(0xFF94A3B8)),
                                  prefixIcon: Icon(Icons.search,
                                      size: 18, color: Color(0xFF94A3B8)),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 11),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMetricCard(
                                    title: 'ALL APPOINTMENTS',
                                    count: allCount.toString().padLeft(2, '0'),
                                    icon: Icons.grid_view_rounded,
                                    color: const Color(0xFF0F172A),
                                    bgColor: const Color(0xFFF1F5F9),
                                    onTap: () =>
                                        setState(() => _selectedFilter = 'All'),
                                    isSelected: _selectedFilter == 'All',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMetricCard(
                                    title: 'PENDING REQUESTS',
                                    count:
                                        pendingCount.toString().padLeft(2, '0'),
                                    icon: Icons.assignment_outlined,
                                    color: const Color(0xFFD97706),
                                    bgColor: const Color(0xFFFEF3C7),
                                    onTap: () => setState(() =>
                                        _selectedFilter = 'Pending Requests'),
                                    isSelected:
                                        _selectedFilter == 'Pending Requests',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMetricCard(
                                    title: 'CONFIRMED TODAY',
                                    count: confirmedTodayCount
                                        .toString()
                                        .padLeft(2, '0'),
                                    icon: Icons.check_circle_outline,
                                    color: const Color(0xFF16A34A),
                                    bgColor: const Color(0xFFDCFCE7),
                                    onTap: () => setState(() =>
                                        _selectedFilter = 'Confirmed Today'),
                                    isSelected:
                                        _selectedFilter == 'Confirmed Today',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMetricCard(
                                    title: 'UPCOMING THIS WEEK',
                                    count: upcomingWeekCount
                                        .toString()
                                        .padLeft(2, '0'),
                                    icon: Icons.calendar_today_outlined,
                                    color: const Color(0xFF4F46E5),
                                    bgColor: const Color(0xFFEEF2FF),
                                    onTap: () => setState(() =>
                                        _selectedFilter = 'Upcoming This Week'),
                                    isSelected:
                                        _selectedFilter == 'Upcoming This Week',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMetricCard(
                                    title: 'URGENT CASES',
                                    count: urgentCasesCount
                                        .toString()
                                        .padLeft(2, '0'),
                                    icon: Icons.warning_amber_rounded,
                                    color: const Color(0xFFDC2626),
                                    bgColor: const Color(0xFFFEF2F2),
                                    onTap: () => setState(
                                        () => _selectedFilter = 'Urgent Cases'),
                                    isSelected:
                                        _selectedFilter == 'Urgent Cases',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Builder(
                                builder: (context) {
                                  var filteredDocs = docs.where((doc) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final owner = (data['ownerName'] ?? '')
                                        .toString()
                                        .toLowerCase();
                                    final petId = (data['petId'] ?? '')
                                        .toString()
                                        .toLowerCase();
                                    final petName =
                                        (data['petName'] ?? data['name'] ?? '')
                                            .toString()
                                            .toLowerCase();
                                    final service = (data['service'] ?? '')
                                        .toString()
                                        .toLowerCase();
                                    final doctor = (data['doctor'] ?? '')
                                        .toString()
                                        .toLowerCase();
                                    final status = (data['status'] ?? 'Pending')
                                        .toString()
                                        .trim()
                                        .toLowerCase();
                                    final isUrgent = data['isUrgent'] ?? false;
                                    final dateStr = data['date']?.toString();

                                    final matchesSearch =
                                        owner.contains(_searchQuery) ||
                                            petId.contains(_searchQuery) ||
                                            petName.contains(_searchQuery) ||
                                            service.contains(_searchQuery) ||
                                            doctor.contains(_searchQuery);

                                    bool matchesFilter = true;
                                    if (_selectedFilter == 'Pending Requests') {
                                      matchesFilter = (status == 'pending');
                                    } else if (_selectedFilter ==
                                        'Confirmed Today') {
                                      matchesFilter = (status == 'confirmed');
                                    } else if (_selectedFilter ==
                                        'Upcoming This Week') {
                                      matchesFilter = (status == 'pending' ||
                                              status == 'confirmed') &&
                                          _isDateInCurrentWeek(dateStr);
                                    } else if (_selectedFilter ==
                                        'Urgent Cases') {
                                      matchesFilter = (isUrgent == true) &&
                                          (status != 'completed' &&
                                              status != 'cancelled');
                                    }

                                    return matchesSearch && matchesFilter;
                                  }).toList();

                                  filteredDocs.sort((a, b) {
                                    final aData =
                                        a.data() as Map<String, dynamic>;
                                    final bData =
                                        b.data() as Map<String, dynamic>;

                                    final aDateTime =
                                        _getAppointmentBookingTime(aData);
                                    final bDateTime =
                                        _getAppointmentBookingTime(bData);

                                    return aDateTime.compareTo(bDateTime);
                                  });

                                  if (filteredDocs.isEmpty) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 40.0),
                                      child: Center(
                                        child: Text(
                                          'No appointments found for this view.',
                                          style: TextStyle(
                                              fontSize: 13,
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
                                          0: FlexColumnWidth(1.2),
                                          1: FlexColumnWidth(1.5),
                                          2: FlexColumnWidth(1.8),
                                          3: FlexColumnWidth(2.0),
                                          4: FlexColumnWidth(1.5),
                                          5: FlexColumnWidth(1.2),
                                        },
                                        defaultVerticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        children: [
                                          const TableRow(
                                            children: [
                                              _TableHeader('PET ID'),
                                              _TableHeader('PET INFO'),
                                              _TableHeader('OWNER'),
                                              _TableHeader('DATE & TIME'),
                                              _TableHeader('SERVICES'),
                                              _TableHeader('ACTIONS'),
                                            ],
                                          ),
                                          ...filteredDocs.map((doc) {
                                            final data = doc.data()
                                                as Map<String, dynamic>;

                                            final petId =
                                                data['petId'] ?? 'PET-00000';
                                            final petName = data['petName'] ??
                                                data['name'] ??
                                                'Pet';
                                            final species = data['species'] ??
                                                data['breed'] ??
                                                'Dog';
                                            final owner =
                                                data['ownerName'] ?? 'Owner';
                                            final rawDate =
                                                data['date'] ?? '2026-08-05';
                                            final formattedDate =
                                                _formatDateToWords(
                                                    rawDate.toString());
                                            final time = data['time'] ??
                                                '09:00 AM - 10:30 AM';
                                            final service = data['service'] ??
                                                'General Checkup';
                                            final status =
                                                (data['status'] ?? 'Pending')
                                                    .toString();

                                            return TableRow(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 14.0),
                                                  child: Text(petId,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                              0xFF64748B))),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(petName,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13,
                                                            color: Color(
                                                                0xFF0F172A))),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                          color: const Color(
                                                              0xFFF1F5F9),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4)),
                                                      child: Text(species,
                                                          style: const TextStyle(
                                                              fontSize: 10,
                                                              color: Color(
                                                                  0xFF64748B))),
                                                    ),
                                                  ],
                                                ),
                                                Text(owner,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF334155))),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(formattedDate,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                            color: Color(
                                                                0xFF0F172A))),
                                                    Text(time,
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xFF64748B))),
                                                  ],
                                                ),
                                                Text(
                                                  service,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF334155),
                                                  ),
                                                ),
                                                if (status.toLowerCase() ==
                                                    'confirmed') ...[
                                                  ElevatedButton.icon(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFF16A34A),
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 8),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                      elevation: 0,
                                                    ),
                                                    onPressed: () {
                                                      _db
                                                          .collection(
                                                              'appointments')
                                                          .doc(doc.id)
                                                          .update({
                                                        'status': 'Completed'
                                                      });
                                                    },
                                                    icon: const Icon(
                                                        Icons.check_circle,
                                                        size: 14),
                                                    label: const Text(
                                                        'Complete',
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                ] else if (status
                                                        .toLowerCase() ==
                                                    'pending') ...[
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.check_circle,
                                                            color: Colors.green,
                                                            size: 20),
                                                        onPressed: () => _db
                                                            .collection(
                                                                'appointments')
                                                            .doc(doc.id)
                                                            .update({
                                                          'status': 'Confirmed'
                                                        }),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.cancel,
                                                            color: Colors.red,
                                                            size: 20),
                                                        onPressed: () => _db
                                                            .collection(
                                                                'appointments')
                                                            .doc(doc.id)
                                                            .update({
                                                          'status': 'Cancelled'
                                                        }),
                                                      ),
                                                    ],
                                                  ),
                                                ] else ...[
                                                  Text(
                                                    status,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          status.toLowerCase() ==
                                                                  'completed'
                                                              ? const Color(
                                                                  0xFF16A34A)
                                                              : const Color(
                                                                  0xFFDC2626),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            );
                                          }),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Showing 1 to ${filteredDocs.length} of ${filteredDocs.length} entries',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF94A3B8)),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
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

  Widget _buildMetricCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : const Color(0xFF94A3B8),
                          letterSpacing: 0.3)),
                  const SizedBox(height: 2),
                  Text(count,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  void _showScheduleAppointmentDialog(BuildContext context) {
    String? selectedOwnerName;
    String? selectedOwnerId;
    String? selectedPetId;

    String selectedService = 'General Checkup';
    String selectedDoctor = 'Dr. James Nico Martinez';

    // Dynamic fields based on service selection
    final chiefComplaintController = TextEditingController();
    String selectedVaccineType = 'Anti-Rabies Vaccine';
    final groomingNotesController = TextEditingController();

    final dateController = TextEditingController(
      text: DateTime.now().toString().split(' ')[0],
    );

    String selectedTimeSlot = '09:00 AM - 10:30 AM';
    final List<String> clinicTimeSlots = [
      '09:00 AM - 10:30 AM',
      '11:00 AM - 12:30 PM',
      '01:00 PM - 02:30 PM',
      '03:00 PM - 04:30 PM',
      '05:00 PM - 06:30 PM',
    ];

    final notesController = TextEditingController();
    bool isUrgentCase = false;

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Schedule Appointment',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A))),
                          IconButton(
                              icon: const Icon(Icons.close,
                                  size: 20, color: Color(0xFF94A3B8)),
                              onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                                child: Text(
                                    '$selectedOwnerName ($selectedOwnerId)',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xFF0F172A))),
                              ),
                              GestureDetector(
                                onTap: () => setDialogState(() {
                                  selectedOwnerName = null;
                                  selectedOwnerId = null;
                                  selectedPetId = null;
                                }),
                                child: const Text('Change',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4F46E5))),
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
                                  'name':
                                      (d['fullName'] ?? d['name'] ?? 'Owner')
                                          .toString(),
                                  'ownerId':
                                      (d['ownerId'] ?? doc.id).toString(),
                                };
                              }).toList();
                            }

                            return DropdownButtonFormField<String>(
                              decoration: _buildInputDecoration(
                                  labelText: 'PET OWNER*',
                                  hintText: 'Search owner name or ID...'),
                              items: ownerOptions.map((o) {
                                return DropdownMenuItem(
                                    value: o['name'],
                                    child: Text(
                                        '${o['name']} (${o['ownerId']})',
                                        style: const TextStyle(fontSize: 13)));
                              }).toList(),
                              onChanged: (val) {
                                final match = ownerOptions.firstWhere(
                                    (e) => e['name'] == val,
                                    orElse: () => {'name': '', 'ownerId': ''});
                                setDialogState(() {
                                  selectedOwnerName = match['name'];
                                  selectedOwnerId = match['ownerId'];
                                  selectedPetId = null;
                                });
                              },
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (selectedOwnerName == null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline,
                                  size: 16, color: Color(0xFF64748B)),
                              SizedBox(width: 8),
                              Text(
                                  'Please select an owner above first to view their pets.',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                      ] else ...[
                        StreamBuilder<QuerySnapshot>(
                          stream: _db.collection('pets').snapshots(),
                          builder: (context, snapshot) {
                            List<Map<String, String>> petList = [];
                            if (snapshot.hasData) {
                              petList = snapshot.data!.docs.where((doc) {
                                final pData =
                                    doc.data() as Map<String, dynamic>;
                                final pOwner = (pData['fullName'] ??
                                        pData['ownerName'] ??
                                        pData['owner'] ??
                                        '')
                                    .toString()
                                    .toLowerCase();
                                final pOwnerId =
                                    (pData['ownerId'] ?? '').toString();
                                return pOwner ==
                                        selectedOwnerName!.toLowerCase() ||
                                    (selectedOwnerId!.isNotEmpty &&
                                        pOwnerId == selectedOwnerId);
                              }).map((doc) {
                                final pData =
                                    doc.data() as Map<String, dynamic>;
                                return {
                                  'petName': (pData['name'] ??
                                          pData['petName'] ??
                                          'Pet')
                                      .toString(),
                                  'petId':
                                      (pData['petId'] ?? doc.id).toString(),
                                  'breed':
                                      (pData['breed'] ?? pData['species'] ?? '')
                                          .toString(),
                                };
                              }).toList();
                            }

                            return DropdownButtonFormField<String>(
                              value: selectedPetId,
                              decoration: _buildInputDecoration(
                                  labelText: 'SELECT PET PATIENT*',
                                  hintText: petList.isEmpty
                                      ? 'No pets registered'
                                      : 'Select pet...'),
                              items: petList.map((p) {
                                return DropdownMenuItem(
                                    value: p['petId'],
                                    child: Text(
                                        '${p['petName']} (${p['breed']})',
                                        style: const TextStyle(fontSize: 13)));
                              }).toList(),
                              onChanged: petList.isEmpty
                                  ? null
                                  : (val) =>
                                      setDialogState(() => selectedPetId = val),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedService,
                              decoration:
                                  _buildInputDecoration(labelText: 'SERVICE*'),
                              items: const [
                                DropdownMenuItem(
                                    value: 'General Checkup',
                                    child: Text('General Checkup',
                                        style: TextStyle(fontSize: 13))),
                                DropdownMenuItem(
                                    value: 'Vaccination',
                                    child: Text('Vaccination',
                                        style: TextStyle(fontSize: 13))),
                                DropdownMenuItem(
                                    value: 'Surgery',
                                    child: Text('Surgery',
                                        style: TextStyle(fontSize: 13))),
                                DropdownMenuItem(
                                    value: 'Grooming',
                                    child: Text('Grooming',
                                        style: TextStyle(fontSize: 13))),
                              ],
                              onChanged: (val) =>
                                  setDialogState(() => selectedService = val!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedDoctor,
                              decoration: _buildInputDecoration(
                                  labelText: 'ASSIGNED DOCTOR*'),
                              items: const [
                                DropdownMenuItem(
                                    value: 'Dr. James Nico Martinez',
                                    child: Text('Dr. James Nico Martinez',
                                        style: TextStyle(fontSize: 13))),
                                DropdownMenuItem(
                                    value: 'Dr. Tamesis',
                                    child: Text('Dr. Tamesis',
                                        style: TextStyle(fontSize: 13))),
                              ],
                              onChanged: (val) =>
                                  setDialogState(() => selectedDoctor = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // DYNAMIC FIELDS BASED ON SELECTED SERVICE
                      if (selectedService == 'General Checkup' ||
                          selectedService == 'Surgery') ...[
                        TextField(
                          controller: chiefComplaintController,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 13),
                          decoration: _buildInputDecoration(
                            labelText: 'CHIEF COMPLAINT*',
                            hintText: 'Enter reason for checkup or surgery...',
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else if (selectedService == 'Vaccination') ...[
                        DropdownButtonFormField<String>(
                          value: selectedVaccineType,
                          isExpanded: true,
                          decoration: _buildInputDecoration(
                              labelText: 'WHAT TYPE OF VACCINE*'),
                          items: const [
                            DropdownMenuItem(
                              value: 'Anti-Rabies Vaccine',
                              child: Text('Anti-Rabies Vaccine',
                                  style: TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            DropdownMenuItem(
                              value: '5-in-1 Vaccine (DHPPiL / DHLPP)',
                              child: Text(
                                  '5-in-1 Vaccine (DHPPiL / DHLPP) - Distemper, Hepatitis, Parvovirus',
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            DropdownMenuItem(
                              value: '4-in-1 Vaccine (FVRCP / Feline Tri-Cat)',
                              child: Text(
                                  '4-in-1 Vaccine (FVRCP / Feline Tri-Cat) - Rhinotracheitis, Calicivirus',
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            DropdownMenuItem(
                              value: 'Feline Leukemia Vaccine (FeLV)',
                              child: Text('Feline Leukemia Vaccine (FeLV)',
                                  style: TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                          onChanged: (val) =>
                              setDialogState(() => selectedVaccineType = val!),
                        ),
                        const SizedBox(height: 16),
                      ] else if (selectedService == 'Grooming') ...[
                        TextField(
                          controller: groomingNotesController,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 13),
                          decoration: _buildInputDecoration(
                            labelText: 'SPECIAL INSTRUCTIONS / ALLERGIES',
                            hintText:
                                'Add special care instructions or product allergies...',
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: dateController,
                              readOnly: true,
                              style: const TextStyle(fontSize: 13),
                              onTap: () async {
                                final DateTime? pickedDate =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (pickedDate != null) {
                                  final formattedDate =
                                      pickedDate.toString().split(' ')[0];
                                  setDialogState(() {
                                    dateController.text = formattedDate;
                                  });
                                }
                              },
                              decoration: _buildInputDecoration(
                                labelText: 'APPOINTMENT DATE*',
                                suffixIcon: const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 18,
                                    color: Color(0xFF64748B)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedTimeSlot,
                              decoration: _buildInputDecoration(
                                  labelText: 'TIME SLOT*'),
                              items: clinicTimeSlots.map((slot) {
                                return DropdownMenuItem(
                                    value: slot,
                                    child: Text(slot,
                                        style: const TextStyle(fontSize: 12)));
                              }).toList(),
                              onChanged: (val) =>
                                  setDialogState(() => selectedTimeSlot = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                size: 20, color: Color(0xFFDC2626)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'MARK AS URGENT / EMERGENCY CASE',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFDC2626),
                                        letterSpacing: 0.3),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Prioritizes this walk-in patient in clinic queue',
                                    style: TextStyle(
                                        fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: isUrgentCase,
                              activeColor: const Color(0xFFDC2626),
                              onChanged: (val) => setDialogState(
                                  () => isUrgentCase = val ?? false),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: notesController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 13),
                        decoration: _buildInputDecoration(
                          labelText: 'NOTES / SPECIAL REQUESTS',
                          hintText: 'Add medical notes or specific requests...',
                        ),
                      ),
                      const SizedBox(height: 24),
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
                              if (selectedOwnerName != null &&
                                  selectedPetId != null) {
                                String serviceSpecificDetails = '';
                                if (selectedService == 'General Checkup' ||
                                    selectedService == 'Surgery') {
                                  serviceSpecificDetails =
                                      'Chief Complaint: ${chiefComplaintController.text}';
                                } else if (selectedService == 'Vaccination') {
                                  serviceSpecificDetails =
                                      'Vaccine Type: $selectedVaccineType';
                                } else if (selectedService == 'Grooming') {
                                  serviceSpecificDetails =
                                      'Instructions/Allergies: ${groomingNotesController.text}';
                                }

                                final finalNotes = notesController.text.isEmpty
                                    ? serviceSpecificDetails
                                    : '${notesController.text} | $serviceSpecificDetails';

                                await _db.collection('appointments').add({
                                  'ownerName': selectedOwnerName,
                                  'ownerId': selectedOwnerId,
                                  'petId': selectedPetId ?? 'PET-00000',
                                  'service': selectedService,
                                  'doctor': selectedDoctor,
                                  'date': dateController.text,
                                  'time': selectedTimeSlot,
                                  'notes': finalNotes,
                                  'isUrgent': isUrgentCase,
                                  'priority': isUrgentCase ? 'High' : 'Normal',
                                  'status': 'Confirmed',
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Appointment booked successfully!')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please select an owner and a pet first.')),
                                );
                              }
                            },
                            child: const Text('Book Appointment',
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

  InputDecoration _buildInputDecoration(
      {String? labelText, String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.5),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5)),
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
