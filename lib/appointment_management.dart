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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeTab =
      'Pending Requests'; // 'Pending Requests', 'Confirmed', 'Completed'
  DateTime _selectedCalendarDate = DateTime.now();

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

  // Schedule Appointment Modal Launcher
  Future<void> _openScheduleAppointmentModal() async {
    await showDialog(
      context: context,
      builder: (context) => const ScheduleAppointmentModal(),
    );
  }

  // Update Status in Firestore
  Future<void> _updateAppointmentStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment updated to $newStatus'),
            backgroundColor: const Color(0xFF166534),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error updating status: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // Full Calendar Modal Launcher (Google Calendar Style)
  void _openFullCalendarModal(List<QueryDocumentSnapshot> allAppointments) {
    showDialog(
      context: context,
      builder: (context) => FullCalendarModal(allAppointments: allAppointments),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          const SidebarMenu(activeRoute: 'appointment_management'),
          Expanded(
            child: Column(
              children: [
                const _TopHeader(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final allDocs = snapshot.data?.docs ?? [];

                      // Stats logic
                      final now = DateTime.now();
                      final todayStr =
                          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

                      int pendingCount = 0;
                      int confirmedTodayCount = 0;
                      int upcomingWeekCount = 0;

                      for (var doc in allDocs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final status = (data['status'] ?? '').toString();
                        final apptDate = (data['date'] ?? '').toString();

                        if (status == 'Pending') pendingCount++;
                        if (status == 'Confirmed' && apptDate == todayStr)
                          confirmedTodayCount++;

                        try {
                          final parsedDate = DateTime.parse(apptDate);
                          final diff = parsedDate.difference(now).inDays;
                          if (diff >= 0 && diff <= 7 && status == 'Confirmed') {
                            upcomingWeekCount++;
                          }
                        } catch (_) {}
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Appointment Management',
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A)),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _openScheduleAppointmentModal,
                                  icon: const Icon(Icons.add,
                                      size: 18, color: Colors.white),
                                  label: const Text('Schedule Appointment',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Stat Cards Row
                            Row(
                              children: [
                                _StatCard(
                                  label: 'PENDING REQUESTS',
                                  count:
                                      pendingCount.toString().padLeft(2, '0'),
                                  icon: Icons.assignment_outlined,
                                  iconBgColor: const Color(0xFFFEF3C7),
                                  iconColor: const Color(0xFFD97706),
                                  barColor: const Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 20),
                                _StatCard(
                                  label: 'CONFIRMED TODAY',
                                  count: confirmedTodayCount
                                      .toString()
                                      .padLeft(2, '0'),
                                  icon: Icons.check_circle_outline,
                                  iconBgColor: const Color(0xFFDCFCE7),
                                  iconColor: const Color(0xFF16A34A),
                                  barColor: const Color(0xFF10B981),
                                ),
                                const SizedBox(width: 20),
                                _StatCard(
                                  label: 'UPCOMING THIS WEEK',
                                  count: upcomingWeekCount
                                      .toString()
                                      .padLeft(2, '0'),
                                  icon: Icons.calendar_today_outlined,
                                  iconBgColor: const Color(0xFFE0E7FF),
                                  iconColor: const Color(0xFF4F46E5),
                                  barColor: const Color(0xFF6366F1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Main Area
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Table
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Tabs & Search
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                _TabButton(
                                                  label: 'Pending Requests',
                                                  isActive: _activeTab ==
                                                      'Pending Requests',
                                                  onTap: () => setState(() =>
                                                      _activeTab =
                                                          'Pending Requests'),
                                                ),
                                                const SizedBox(width: 16),
                                                _TabButton(
                                                  label: 'Confirmed',
                                                  isActive:
                                                      _activeTab == 'Confirmed',
                                                  onTap: () => setState(() =>
                                                      _activeTab = 'Confirmed'),
                                                ),
                                                const SizedBox(width: 16),
                                                _TabButton(
                                                  label: 'Completed',
                                                  isActive:
                                                      _activeTab == 'Completed',
                                                  onTap: () => setState(() =>
                                                      _activeTab = 'Completed'),
                                                ),
                                              ],
                                            ),

                                            // Search Input
                                            Container(
                                              width: 240,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8FAFC),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFFE2E8F0)),
                                              ),
                                              child: TextField(
                                                controller: _searchController,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                decoration:
                                                    const InputDecoration(
                                                  hintText:
                                                      'Search appointments...',
                                                  hintStyle: TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF94A3B8)),
                                                  prefixIcon: Icon(Icons.search,
                                                      size: 16,
                                                      color: Color(0xFF94A3B8)),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),

                                        // Appointments Table
                                        _buildAppointmentsTable(allDocs),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),

                                // Right Widgets (Mini Calendar & Briefing)
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      // Mini Calendar Box
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: const Color(0xFFE2E8F0)),
                                        ),
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text('Calendar View',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF0F172A))),
                                                InkWell(
                                                  onTap: () =>
                                                      _openFullCalendarModal(
                                                          allDocs),
                                                  child: const Text('View All',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          color:
                                                              Color(0xFF4F46E5),
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),

                                            // Mini Calendar Picker
                                            CalendarDatePicker(
                                              initialDate:
                                                  _selectedCalendarDate,
                                              firstDate: DateTime(2024),
                                              lastDate: DateTime(2030),
                                              onDateChanged: (date) {
                                                setState(() =>
                                                    _selectedCalendarDate =
                                                        date);
                                                _openFullCalendarModal(allDocs);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Daily Briefing Widget
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F172A),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('Daily Briefing',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14)),
                                            const SizedBox(height: 12),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: const Text(
                                                  'Ensure all surgical rooms are prepared before the 2:00 PM appointment rush.',
                                                  style: TextStyle(
                                                      color: Color(0xFFCBD5E1),
                                                      fontSize: 11)),
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: const Text(
                                                  'Dr. James Nico Martinez is on duty today until 5:00 PM.',
                                                  style: TextStyle(
                                                      color: Color(0xFFCBD5E1),
                                                      fontSize: 11)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTable(List<QueryDocumentSnapshot> allDocs) {
    String targetStatus = 'Pending';
    if (_activeTab == 'Confirmed') targetStatus = 'Confirmed';
    if (_activeTab == 'Completed') targetStatus = 'Completed';

    final filteredDocs = allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final status = (data['status'] ?? '').toString();
      final petName = (data['petName'] ?? '').toString().toLowerCase();
      final petId = (data['petId'] ?? '').toString().toLowerCase();
      final ownerName = (data['ownerName'] ?? '').toString().toLowerCase();
      final apptId = (data['appointmentId'] ?? '').toString().toLowerCase();

      final matchesTab = status == targetStatus;
      final matchesSearch = petName.contains(_searchQuery) ||
          petId.contains(_searchQuery) ||
          ownerName.contains(_searchQuery) ||
          apptId.contains(_searchQuery);

      return matchesTab && matchesSearch;
    }).toList();

    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(1.2), // PET ID
            1: FlexColumnWidth(2.0), // PET INFO
            2: FlexColumnWidth(2.0), // OWNER
            3: FlexColumnWidth(2.2), // DATE & TIME
            4: FlexColumnWidth(1.8), // ACTIONS
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            const TableRow(
              children: [
                _TableHeader('PET ID'),
                _TableHeader('PET INFO'),
                _TableHeader('OWNER'),
                _TableHeader('DATE & TIME'),
                _TableHeader('ACTIONS'),
              ],
            ),
            for (var doc in filteredDocs) _buildRow(doc),
          ],
        ),
        if (filteredDocs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: Text('No appointments found in this tab.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            ),
          ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Showing 1 to ${filteredDocs.length} of ${allDocs.where((doc) => (doc.data() as Map<String, dynamic>)['status'] == targetStatus).length} ${_activeTab.toLowerCase()} entries',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            Row(
              children: const [
                IconButton(
                    icon: Icon(Icons.chevron_left,
                        size: 20, color: Color(0xFF94A3B8)),
                    onPressed: null),
                IconButton(
                    icon: Icon(Icons.chevron_right,
                        size: 20, color: Color(0xFF94A3B8)),
                    onPressed: null),
              ],
            ),
          ],
        ),
      ],
    );
  }

  TableRow _buildRow(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final docId = doc.id;

    final petId = data['petId'] ?? '#00000';
    final petName = data['petName'] ?? 'N/A';
    final species = data['species'] ?? 'Pet';
    final ownerName = data['ownerName'] ?? 'N/A';
    final date = data['date'] ?? 'TBD';
    final timeSlot = data['timeSlot'] ?? '';
    final service = data['service'] ?? 'Checkup';
    final status = data['status'] ?? 'Pending';

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(petId,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(petName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(species,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        Text(ownerName,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$date $timeSlot",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF0F172A))),
            Text(service,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        Row(
          children: [
            if (status == 'Pending') ...[
              ElevatedButton.icon(
                onPressed: () => _updateAppointmentStatus(docId, 'Confirmed'),
                icon: const Icon(Icons.check_circle_outline,
                    size: 14, color: Colors.white),
                label: const Text('Approve',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.cancel_outlined,
                    size: 18, color: Color(0xFFDC2626)),
                onPressed: () => _updateAppointmentStatus(docId, 'Cancelled'),
                tooltip: 'Cancel Appointment',
              ),
            ] else if (status == 'Confirmed') ...[
              ElevatedButton.icon(
                onPressed: () => _updateAppointmentStatus(docId, 'Completed'),
                icon: const Icon(Icons.task_alt, size: 14, color: Colors.white),
                label: const Text('Complete',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
              ),
            ] else ...[
              _buildStatusBadge(status),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);

    if (status == 'Confirmed') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF15803D);
    } else if (status == 'Completed') {
      bg = const Color(0xFFE0E7FF);
      text = const Color(0xFF4338CA);
    } else if (status == 'Cancelled') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: text)),
    );
  }
}

// ==========================================
// GOOGLE CALENDAR STYLE FULL VIEW MODAL
// ==========================================
class FullCalendarModal extends StatefulWidget {
  final List<QueryDocumentSnapshot> allAppointments;
  const FullCalendarModal({super.key, required this.allAppointments});

  @override
  State<FullCalendarModal> createState() => _FullCalendarModalState();
}

class _FullCalendarModalState extends State<FullCalendarModal> {
  String _currentView = 'Month'; // 'Month', 'Week', 'Day'
  DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month,
                        color: Color(0xFF4F46E5), size: 24),
                    const SizedBox(width: 10),
                    Text(
                      "${_focusedDate.year} - ${_getMonthName(_focusedDate.month)}",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () =>
                          setState(() => _focusedDate = DateTime.now()),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      child: const Text('Today',
                          style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: ['Month', 'Week', 'Day'].map((view) {
                      final isActive = _currentView == view;
                      return InkWell(
                        onTap: () => setState(() => _currentView = view),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF0F172A)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            view,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      size: 22, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 32, color: Color(0xFFE2E8F0)),
            Expanded(
              child: _currentView == 'Month'
                  ? _buildMonthView()
                  : _currentView == 'Week'
                      ? _buildWeekView()
                      : _buildDayView(),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  Widget _buildMonthView() {
    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedDate.year, _focusedDate.month);
    final firstDayOffset =
        DateTime(_focusedDate.year, _focusedDate.month, 1).weekday % 7;

    return Column(
      children: [
        Row(
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF64748B))),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: daysInMonth + firstDayOffset,
            itemBuilder: (context, index) {
              if (index < firstDayOffset) return Container();
              final dayNumber = index - firstDayOffset + 1;
              final dateStr =
                  "${_focusedDate.year}-${_focusedDate.month.toString().padLeft(2, '0')}-${dayNumber.toString().padLeft(2, '0')}";

              final dayAppts = widget.allAppointments.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return (data['date'] ?? '').toString() == dateStr;
              }).toList();

              return Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$dayNumber",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Expanded(
                      child: ListView(
                        children: dayAppts.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final petName = data['petName'] ?? 'Pet';
                          final service = data['service'] ?? 'Checkup';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "$petName • $service",
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4F46E5)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekView() {
    final startOfWeek =
        _focusedDate.subtract(Duration(days: _focusedDate.weekday % 7));

    return Row(
      children: List.generate(7, (index) {
        final day = startOfWeek.add(Duration(days: index));
        final dateStr =
            "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

        final dayAppts = widget.allAppointments.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return (data['date'] ?? '').toString() == dateStr;
        }).toList();

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${day.day} ${_getMonthName(day.month).substring(0, 3)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF0F172A))),
                const Divider(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: dayAppts.length,
                    itemBuilder: (context, i) {
                      final data = dayAppts[i].data() as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['petName'] ?? 'Pet',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF0F172A))),
                            Text(data['service'] ?? 'Service',
                                style: const TextStyle(
                                    fontSize: 10, color: Color(0xFF64748B))),
                            Text(data['timeSlot'] ?? '',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF4F46E5),
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDayView() {
    final dateStr =
        "${_focusedDate.year}-${_focusedDate.month.toString().padLeft(2, '0')}-${_focusedDate.day.toString().padLeft(2, '0')}";

    final dayAppts = widget.allAppointments.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return (data['date'] ?? '').toString() == dateStr;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Appointments for $dateStr",
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A))),
        const SizedBox(height: 16),
        Expanded(
          child: dayAppts.isEmpty
              ? const Center(
                  child: Text('No appointments scheduled for this day.',
                      style: TextStyle(color: Color(0xFF94A3B8))))
              : ListView.builder(
                  itemCount: dayAppts.length,
                  itemBuilder: (context, index) {
                    final data = dayAppts[index].data() as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "${data['petName']} (${data['species'] ?? 'Pet'})",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF0F172A))),
                              const SizedBox(height: 4),
                              Text(
                                  "Owner: ${data['ownerName']} • Doctor: ${data['doctor']}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(data['timeSlot'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF4F46E5))),
                              Text(data['service'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ==========================================
// SCHEDULE APPOINTMENT MODAL (Owner-First Flow)
// ==========================================
class ScheduleAppointmentModal extends StatefulWidget {
  const ScheduleAppointmentModal({super.key});

  @override
  State<ScheduleAppointmentModal> createState() =>
      _ScheduleAppointmentModalState();
}

class _ScheduleAppointmentModalState extends State<ScheduleAppointmentModal> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedOwnerDocId;
  String? _selectedOwnerId;
  String? _selectedOwnerName;

  String? _selectedPetDocId;
  String? _selectedPetId;
  String? _selectedPetName;
  String? _selectedSpecies;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedService = 'General Checkup';
  String _selectedTimeSlot = '09:00 AM - 10:00 AM';
  String _selectedDoctor = 'Dr. James Nico Martinez';
  bool _isSaving = false;

  InputDecoration _inputDeco(String label, {String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF475569),
          letterSpacing: 0.5),
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5)),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF0F172A)),
          dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
        ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(size: const Size(320, 420)),
          child: child!,
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        final formattedDay = picked.day.toString().padLeft(2, '0');
        final formattedMonth = picked.month.toString().padLeft(2, '0');
        _dateController.text = "${picked.year}-$formattedMonth-$formattedDay";
      });
    }
  }

  void _saveAppointment() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedOwnerDocId == null || _selectedPetDocId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select both an Owner and a Pet patient!'),
              backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isSaving = true);

      try {
        final snap =
            await FirebaseFirestore.instance.collection('appointments').get();
        final apptId =
            "APP-${(snap.docs.length + 1).toString().padLeft(5, '0')}";

        await FirebaseFirestore.instance.collection('appointments').add({
          'appointmentId': apptId,
          'petId': _selectedPetId ?? '#PET-00001',
          'petName': _selectedPetName ?? 'Patient',
          'species': _selectedSpecies ?? 'Pet',
          'ownerName': _selectedOwnerName ?? 'Owner',
          'ownerId': _selectedOwnerId ?? '#OWN-00000',
          'service': _selectedService,
          'doctor': _selectedDoctor,
          'date': _dateController.text.trim(),
          'timeSlot': _selectedTimeSlot,
          'notes': _notesController.text.trim(),
          'status': 'Confirmed',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Appointment scheduled successfully!'),
                backgroundColor: Color(0xFF166534)),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Schedule Appointment',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A))),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 20, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Owner Search
              if (_selectedOwnerDocId != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PET OWNER*',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  size: 18, color: Color(0xFF4F46E5)),
                              const SizedBox(width: 8),
                              Text(_selectedOwnerName ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF0F172A))),
                              const SizedBox(width: 8),
                              Text('(${_selectedOwnerId ?? ''})',
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedOwnerDocId = null;
                                _selectedOwnerId = null;
                                _selectedOwnerName = null;
                                _selectedPetDocId = null;
                                _selectedPetId = null;
                                _selectedPetName = null;
                              });
                            },
                            child: const Text('Change',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF4F46E5),
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, userSnap) {
                    final users = userSnap.data?.docs ?? [];

                    return Autocomplete<QueryDocumentSnapshot>(
                      displayStringForOption: (doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return "${data['fullName']} (${data['ownerID'] ?? data['ownerId'] ?? ''})";
                      },
                      optionsBuilder: (textVal) {
                        if (textVal.text.trim().isEmpty)
                          return const Iterable<QueryDocumentSnapshot>.empty();
                        final q = textVal.text.toLowerCase();
                        return users.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name =
                              (data['fullName'] ?? '').toString().toLowerCase();
                          final id = (data['ownerID'] ?? data['ownerId'] ?? '')
                              .toString()
                              .toLowerCase();
                          return name.contains(q) || id.contains(q);
                        });
                      },
                      onSelected: (doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        setState(() {
                          _selectedOwnerDocId = doc.id;
                          _selectedOwnerId = data['ownerID'] ??
                              data['ownerId'] ??
                              '#OWN-00001';
                          _selectedOwnerName = data['fullName'] ?? 'Owner Name';
                        });
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: _inputDeco(
                            'SEARCH OWNER (NAME OR ID)*',
                            hint: 'Type owner name or ID...',
                            suffixIcon: const Icon(Icons.search,
                                size: 18, color: Color(0xFF94A3B8)),
                          ),
                          validator: (v) => _selectedOwnerDocId == null
                              ? 'Please select an owner'
                              : null,
                        );
                      },
                    );
                  },
                ),
              ],
              const SizedBox(height: 18),

              // Pet Dropdown / Pill
              if (_selectedOwnerDocId != null) ...[
                if (_selectedPetDocId != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SELECTED PATIENT*',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569),
                              letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_selectedPetName ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                            const SizedBox(width: 8),
                            Text(_selectedPetId ?? '',
                                style: const TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 12)),
                            const SizedBox(width: 6),
                            Text(_selectedOwnerId ?? '',
                                style: const TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 12)),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedPetDocId = null;
                                  _selectedPetId = null;
                                  _selectedPetName = null;
                                });
                              },
                              child: const Icon(Icons.close,
                                  size: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('pets')
                        .where('ownerDocId', isEqualTo: _selectedOwnerDocId)
                        .snapshots(),
                    builder: (context, petSnap) {
                      final pets = petSnap.data?.docs ?? [];

                      return DropdownButtonFormField<QueryDocumentSnapshot>(
                        decoration: _inputDeco('SELECT PET PATIENT*'),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF64748B)),
                        hint: Text(
                          pets.isEmpty
                              ? 'No pets found for this owner'
                              : 'Select pet...',
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF94A3B8)),
                        ),
                        items: pets.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final pName = data['petName'] ?? 'Unknown Pet';
                          final pId = data['petId'] ?? '#PET-00000';
                          final pSpecies = data['species'] ?? 'Pet';
                          return DropdownMenuItem(
                            value: doc,
                            child: Text("$pName ($pId) - $pSpecies",
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF0F172A))),
                          );
                        }).toList(),
                        onChanged: (doc) {
                          if (doc != null) {
                            final data = doc.data() as Map<String, dynamic>;
                            setState(() {
                              _selectedPetDocId = doc.id;
                              _selectedPetId = data['petId'] ?? '#PET-00001';
                              _selectedPetName = data['petName'] ?? 'Pet';
                              _selectedSpecies = data['species'] ?? 'Pet';
                            });
                          }
                        },
                        validator: (v) => _selectedPetDocId == null
                            ? 'Please select a pet patient'
                            : null,
                      );
                    },
                  ),
                ],
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 18, color: Color(0xFF94A3B8)),
                      SizedBox(width: 10),
                      Text(
                          'Please select an owner above first to view their pets.',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),

              // Service & Doctor Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedService,
                      decoration: _inputDeco('SERVICE*'),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Color(0xFF64748B)),
                      items: [
                        'General Checkup',
                        'Vaccination',
                        'Dental Cleaning',
                        'Surgery',
                        'Grooming',
                        'Emergency Care'
                      ]
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e,
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFF0F172A)))))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedService = val!),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDoctor,
                      decoration: _inputDeco('ASSIGNED DOCTOR*'),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Color(0xFF64748B)),
                      items: [
                        'Dr. James Nico Martinez',
                        'Dr. Tamesis',
                        'Dr. Sarah Jenkins'
                      ]
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e,
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFF0F172A)))))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedDoctor = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Date & Time Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: _inputDeco(
                        'APPOINTMENT DATE*',
                        hint: 'YYYY-MM-DD',
                        suffixIcon: const Icon(Icons.calendar_today_outlined,
                            size: 18, color: Color(0xFF64748B)),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTimeSlot,
                      decoration: _inputDeco('TIME SLOT*'),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Color(0xFF64748B)),
                      items: [
                        '09:00 AM - 10:00 AM',
                        '10:30 AM - 11:30 AM',
                        '01:00 PM - 02:00 PM',
                        '02:30 PM - 03:30 PM',
                        '04:00 PM - 05:00 PM'
                      ]
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e,
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFF0F172A)))))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedTimeSlot = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: _inputDeco(
                  'NOTES / SPECIAL REQUESTS',
                  hint: 'Add medical notes or specific requests...',
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Book Appointment',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color barColor;

  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                  color: barColor, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: iconBgColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8))),
                const SizedBox(height: 2),
                Text(count,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0F172A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
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
                  fontSize: 16,
                  color: Color(0xFF0F172A))),
          Row(
            children: const [
              Icon(Icons.help_outline, color: Color(0xFF64748B), size: 20),
              SizedBox(width: 16),
              Icon(Icons.grid_view, color: Color(0xFF64748B), size: 20),
            ],
          ),
        ],
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
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8))),
    );
  }
}
