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
  String _selectedTab =
      'Confirmed'; // 'Pending Requests', 'Confirmed', 'Completed'
  String _calendarViewMode = 'Monthly'; // 'Monthly', 'Weekly', 'Daily'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar Component
          const SidebarMenu(activeRoute: '/appointments'),

          // Main View
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

                        // DYNAMIC REAL-TIME COUNTS FROM FIRESTORE
                        final pendingCount = docs.where((d) {
                          final status =
                              (d.data() as Map<String, dynamic>)['status'] ??
                                  '';
                          return status.toString().toLowerCase() == 'pending';
                        }).length;

                        final confirmedTodayCount = docs.where((d) {
                          final status =
                              (d.data() as Map<String, dynamic>)['status'] ??
                                  '';
                          return status.toString().toLowerCase() == 'confirmed';
                        }).length;

                        final upcomingWeekCount = docs.where((d) {
                          final status =
                              (d.data() as Map<String, dynamic>)['status'] ??
                                  '';
                          return status.toString().toLowerCase() ==
                                  'confirmed' ||
                              status.toString().toLowerCase() == 'pending';
                        }).length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Title Bar
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
                            const SizedBox(height: 24),

                            // 1. TOP 3 METRIC CARDS ROW
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMetricCard(
                                    title: 'PENDING REQUESTS',
                                    count:
                                        pendingCount.toString().padLeft(2, '0'),
                                    icon: Icons.assignment_outlined,
                                    color: const Color(0xFFD97706),
                                    bgColor: const Color(0xFFFEF3C7),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildMetricCard(
                                    title: 'CONFIRMED TODAY',
                                    count: confirmedTodayCount
                                        .toString()
                                        .padLeft(2, '0'),
                                    icon: Icons.check_circle_outline,
                                    color: const Color(0xFF16A34A),
                                    bgColor: const Color(0xFFDCFCE7),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildMetricCard(
                                    title: 'UPCOMING THIS WEEK',
                                    count: upcomingWeekCount
                                        .toString()
                                        .padLeft(2, '0'),
                                    icon: Icons.calendar_today_outlined,
                                    color: const Color(0xFF4F46E5),
                                    bgColor: const Color(0xFFEEF2FF),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // 2. MAIN CONTENT ROW (TABLE + CALENDAR VIEW)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Side: Main Appointments Table
                                Expanded(
                                  flex: 7,
                                  child: Container(
                                    padding: const EdgeInsets.all(24.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Status Filter Tabs & Search Bar Row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                _buildTabButton(
                                                    'Pending Requests'),
                                                const SizedBox(width: 8),
                                                _buildTabButton('Confirmed'),
                                                const SizedBox(width: 8),
                                                _buildTabButton('Completed'),
                                              ],
                                            ),
                                            Container(
                                              width: 220,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8FAFC),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFFE2E8F0)),
                                              ),
                                              child: TextField(
                                                onChanged: (val) {
                                                  setState(() {
                                                    _searchQuery = val
                                                        .toLowerCase()
                                                        .trim();
                                                  });
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                  hintText:
                                                      'Search appointments...',
                                                  hintStyle: TextStyle(
                                                      fontSize: 12,
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

                                        // Filter Documents
                                        Builder(
                                          builder: (context) {
                                            var filteredDocs =
                                                docs.where((doc) {
                                              final data = doc.data()
                                                  as Map<String, dynamic>;
                                              final owner =
                                                  (data['ownerName'] ?? '')
                                                      .toString()
                                                      .toLowerCase();
                                              final petId =
                                                  (data['petId'] ?? '')
                                                      .toString()
                                                      .toLowerCase();
                                              final petName =
                                                  (data['petName'] ??
                                                          data['name'] ??
                                                          '')
                                                      .toString()
                                                      .toLowerCase();
                                              final service =
                                                  (data['service'] ?? '')
                                                      .toString()
                                                      .toLowerCase();
                                              final status =
                                                  (data['status'] ?? 'Pending')
                                                      .toString()
                                                      .trim()
                                                      .toLowerCase();

                                              final matchesSearch = owner
                                                      .contains(_searchQuery) ||
                                                  petId
                                                      .contains(_searchQuery) ||
                                                  petName
                                                      .contains(_searchQuery) ||
                                                  service
                                                      .contains(_searchQuery);

                                              bool matchesTab = true;
                                              if (_selectedTab ==
                                                  'Pending Requests') {
                                                matchesTab =
                                                    (status == 'pending');
                                              } else if (_selectedTab ==
                                                  'Confirmed') {
                                                matchesTab =
                                                    (status == 'confirmed');
                                              } else if (_selectedTab ==
                                                  'Completed') {
                                                matchesTab =
                                                    (status == 'completed');
                                              }

                                              return matchesSearch &&
                                                  matchesTab;
                                            }).toList();

                                            if (filteredDocs.isEmpty) {
                                              return const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 40.0),
                                                child: Center(
                                                  child: Text(
                                                    'No appointments found for this view.',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xFF94A3B8),
                                                        fontStyle:
                                                            FontStyle.italic),
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
                                                    4: FlexColumnWidth(1.2),
                                                  },
                                                  defaultVerticalAlignment:
                                                      TableCellVerticalAlignment
                                                          .middle,
                                                  children: [
                                                    const TableRow(
                                                      children: [
                                                        _TableHeader('PET ID'),
                                                        _TableHeader(
                                                            'PET INFO'),
                                                        _TableHeader('OWNER'),
                                                        _TableHeader(
                                                            'DATE & TIME'),
                                                        _TableHeader('ACTIONS'),
                                                      ],
                                                    ),
                                                    ...filteredDocs.map((doc) {
                                                      final data = doc.data()
                                                          as Map<String,
                                                              dynamic>;

                                                      final petId =
                                                          data['petId'] ??
                                                              'PET-00000';
                                                      final petName =
                                                          data['petName'] ??
                                                              data['name'] ??
                                                              'Pet';
                                                      final species =
                                                          data['species'] ??
                                                              data['breed'] ??
                                                              'Dog';
                                                      final owner =
                                                          data['ownerName'] ??
                                                              'Owner';
                                                      final date =
                                                          data['date'] ??
                                                              'August 04, 2026';
                                                      final time = data[
                                                              'time'] ??
                                                          '09:00 AM - 10:00 AM';
                                                      final service =
                                                          data['service'] ??
                                                              'General Checkup';

                                                      return TableRow(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        14.0),
                                                            child: Text(petId,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Color(
                                                                        0xFF64748B))),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(petName,
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          13,
                                                                      color: Color(
                                                                          0xFF0F172A))),
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        6,
                                                                    vertical:
                                                                        2),
                                                                decoration: BoxDecoration(
                                                                    color: const Color(
                                                                        0xFFF1F5F9),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            4)),
                                                                child: Text(
                                                                    species,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Color(
                                                                            0xFF64748B))),
                                                              ),
                                                            ],
                                                          ),
                                                          Text(owner,
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                      0xFF334155))),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(date,
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          12,
                                                                      color: Color(
                                                                          0xFF0F172A))),
                                                              Text(time,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Color(
                                                                          0xFF64748B))),
                                                              Text(service,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      color: Color(
                                                                          0xFF94A3B8))),
                                                            ],
                                                          ),
                                                          if (_selectedTab ==
                                                              'Confirmed') ...[
                                                            ElevatedButton.icon(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    const Color(
                                                                        0xFF16A34A),
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        8),
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8)),
                                                                elevation: 0,
                                                              ),
                                                              onPressed: () {
                                                                _db
                                                                    .collection(
                                                                        'appointments')
                                                                    .doc(doc.id)
                                                                    .update({
                                                                  'status':
                                                                      'Completed'
                                                                });
                                                              },
                                                              icon: const Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  size: 14),
                                                              label: const Text(
                                                                  'Complete',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            ),
                                                          ] else if (_selectedTab ==
                                                              'Pending Requests') ...[
                                                            Row(
                                                              children: [
                                                                IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .check_circle,
                                                                      color: Colors
                                                                          .green,
                                                                      size: 20),
                                                                  onPressed: () => _db
                                                                      .collection(
                                                                          'appointments')
                                                                      .doc(doc
                                                                          .id)
                                                                      .update({
                                                                    'status':
                                                                        'Confirmed'
                                                                  }),
                                                                ),
                                                                IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .cancel,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 20),
                                                                  onPressed: () => _db
                                                                      .collection(
                                                                          'appointments')
                                                                      .doc(doc
                                                                          .id)
                                                                      .update({
                                                                    'status':
                                                                        'Cancelled'
                                                                  }),
                                                                ),
                                                              ],
                                                            ),
                                                          ] else ...[
                                                            const Text(
                                                                'Completed',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF16A34A))),
                                                          ],
                                                        ],
                                                      );
                                                    }),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Showing 1 to ${filteredDocs.length} of ${filteredDocs.length} entries',
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            Color(0xFF94A3B8)),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),

                                // Right Side: Calendar View Panel
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    padding: const EdgeInsets.all(20.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Calendar View',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Color(0xFF0F172A))),
                                            PopupMenuButton<String>(
                                              onSelected: (mode) => setState(
                                                  () =>
                                                      _calendarViewMode = mode),
                                              child: Row(
                                                children: [
                                                  Text(
                                                      'View All ($_calendarViewMode)',
                                                      style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                              0xFF4F46E5))),
                                                  const Icon(
                                                      Icons.arrow_drop_down,
                                                      size: 16,
                                                      color: Color(0xFF4F46E5)),
                                                ],
                                              ),
                                              itemBuilder: (context) => const [
                                                PopupMenuItem(
                                                    value: 'Monthly',
                                                    child: Text('Monthly View',
                                                        style: TextStyle(
                                                            fontSize: 12))),
                                                PopupMenuItem(
                                                    value: 'Weekly',
                                                    child: Text('Weekly View',
                                                        style: TextStyle(
                                                            fontSize: 12))),
                                                PopupMenuItem(
                                                    value: 'Daily',
                                                    child: Text('Daily View',
                                                        style: TextStyle(
                                                            fontSize: 12))),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('August 2026',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF334155))),
                                            Row(
                                              children: const [
                                                Icon(Icons.chevron_left,
                                                    size: 18,
                                                    color: Color(0xFF64748B)),
                                                Icon(Icons.chevron_right,
                                                    size: 18,
                                                    color: Color(0xFF64748B)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),

                                        // Dynamic Calendar View
                                        _buildMiniCalendarGrid(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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

  // TOP METRIC CARD WIDGET
  Widget _buildMetricCard(
      {required String title,
      required String count,
      required IconData icon,
      required Color color,
      required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(count,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A))),
            ],
          ),
        ],
      ),
    );
  }

  // TAB BUTTON WIDGET
  Widget _buildTabButton(String label) {
    final isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  // DYNAMIC CALENDAR GRID BASED ON VIEW MODE (MONTHLY, WEEKLY, DAILY)
  Widget _buildMiniCalendarGrid() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    // 1. DAILY VIEW DISPLAY
    if (_calendarViewMode == 'Daily') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Column(
              children: const [
                Text("TODAY'S SCHEDULE",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F46E5))),
                SizedBox(height: 4),
                Text('August 04, 2026',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeSlotItem('09:00 AM', 'Garfield (General Checkup)', true),
          _buildTimeSlotItem('10:30 AM', 'No Appointment', false),
          _buildTimeSlotItem('02:00 PM', 'No Appointment', false),
          _buildTimeSlotItem('03:30 PM', 'No Appointment', false),
        ],
      );
    }

    // 2. WEEKLY VIEW DISPLAY (AUG 02 - AUG 08)
    if (_calendarViewMode == 'Weekly') {
      final weekDays = [
        {'day': 'S', 'num': '2'},
        {'day': 'M', 'num': '3'},
        {'day': 'T', 'num': '4', 'isToday': true},
        {'day': 'W', 'num': '5'},
        {'day': 'T', 'num': '6'},
        {'day': 'F', 'num': '7'},
        {'day': 'S', 'num': '8'},
      ];

      return Column(
        children: [
          const Text('CURRENT WEEK (AUG 02 - AUG 08)',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B))),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((w) {
              final isToday = w['isToday'] == true;
              return Column(
                children: [
                  Text(w['day'].toString(),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isToday
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: isToday
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      w['num'].toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isToday ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      );
    }

    // 3. MONTHLY VIEW DISPLAY (DEFAULT GRID 1-31)
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days
              .map((d) => Text(d,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B))))
              .toList(),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 6),
          itemCount: 31,
          itemBuilder: (context, index) {
            final dayNum = index + 1;
            final isToday = dayNum == 4;
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFF4F46E5) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$dayNum',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday ? Colors.white : const Color(0xFF334155)),
              ),
            );
          },
        ),
      ],
    );
  }

  // HELPER FOR DAILY TIME SLOTS
  Widget _buildTimeSlotItem(String time, String details, bool hasBooking) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
              width: 60,
              child: Text(time,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B)))),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: hasBooking
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: hasBooking
                        ? const Color(0xFF86EFAC)
                        : const Color(0xFFE2E8F0)),
              ),
              child: Text(
                details,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: hasBooking ? FontWeight.bold : FontWeight.normal,
                  color: hasBooking
                      ? const Color(0xFF166534)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
        ],
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

  // SCHEDULE APPOINTMENT DIALOG FORM
  void _showScheduleAppointmentDialog(BuildContext context) {
    String? selectedOwnerName;
    String? selectedOwnerId;

    String selectedService = 'General Checkup';
    String selectedDoctor = 'Dr. James Nico Martinez';
    final dateController = TextEditingController(text: '2026-08-05');
    String selectedTimeSlot = '09:00 AM - 10:00 AM';
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
                      if (selectedOwnerName != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFC7D2FE))),
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
                                onTap: () => setDialogState(
                                    () => selectedOwnerName = null),
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
                                  labelText: 'SEARCH OWNER (NAME OR ID)*',
                                  hintText: 'Type owner name or ID...'),
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
                                });
                              },
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: isUrgentCase
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isUrgentCase
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFFE2E8F0)),
                        ),
                        child: CheckboxListTile(
                          value: isUrgentCase,
                          activeColor: const Color(0xFFDC2626),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          title: const Text('MARK AS URGENT / EMERGENCY CASE',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFDC2626))),
                          onChanged: (val) =>
                              setDialogState(() => isUrgentCase = val ?? false),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                            onPressed: () async {
                              if (selectedOwnerName != null) {
                                await _db.collection('appointments').add({
                                  'ownerName': selectedOwnerName,
                                  'ownerId': selectedOwnerId,
                                  'service': selectedService,
                                  'doctor': selectedDoctor,
                                  'date': dateController.text,
                                  'time': selectedTimeSlot,
                                  'notes': notesController.text,
                                  'isUrgent': isUrgentCase,
                                  'status': 'Confirmed',
                                  'createdAt': FieldValue.serverTimestamp(),
                                });
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Book Appointment'),
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

  InputDecoration _buildInputDecoration({String? labelText, String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(
          fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
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
