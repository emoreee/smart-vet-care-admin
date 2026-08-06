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

  String _selectedStatFilter = 'Appointments Today';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          const SidebarMenu(activeRoute: '/dashboard'),
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
                        _buildStatCardsRow(),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: DashboardAppointmentsTableWidget(
                                selectedFilter: _selectedStatFilter,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 3,
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

  Widget _buildStatCardsRow() {
    final todayStr = DateTime.now().toString().split(' ')[0];

    return Row(
      children: [
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
                  final date = (data['date'] ?? '').toString();
                  return status != 'completed' &&
                      status != 'cancelled' &&
                      date == todayStr;
                }).length;
              }

              return _buildSingleStatCard(
                title: 'APPOINTMENTS TODAY',
                count: '$count',
                subtext: count > 0 ? '↑ Active schedule' : 'No appointments',
                subtextColor: const Color(0xFF16A34A),
                borderColor: const Color(0xFF22C55E),
                isSelected: _selectedStatFilter == 'Appointments Today',
                onTap: () =>
                    setState(() => _selectedStatFilter = 'Appointments Today'),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
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
                isSelected: _selectedStatFilter == 'In-Patient',
                onTap: () => setState(() => _selectedStatFilter = 'In-Patient'),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('appointments').snapshots(),
            builder: (context, snapshot) {
              int urgentCount = 0;
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                urgentCount = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final isUrgent = data['isUrgent'] ?? false;
                  final status =
                      (data['status'] ?? '').toString().toLowerCase();
                  final isActive =
                      status != 'completed' && status != 'cancelled';
                  return isUrgent == true && isActive;
                }).length;
              }

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
                isSelected: _selectedStatFilter == 'Urgent Cases',
                onTap: () =>
                    setState(() => _selectedStatFilter = 'Urgent Cases'),
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
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? borderColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2.2 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
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
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? borderColor
                                  : const Color(0xFF94A3B8))),
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
      ),
    );
  }

  Widget _buildDemographicsCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
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
              Text(
                'Patient\'s Demographics',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A)),
              ),
              Icon(Icons.info_outline, size: 16, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _db.collection('pets').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 140,
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
                          width: 120,
                          height: 120,
                          child: CustomPaint(
                            painter: _DonutChartPainter(
                              dogsPct: dogsPct,
                              catsPct: catsPct,
                              othersPct: othersPct,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('TOTAL',
                                style: TextStyle(
                                    fontSize: 8,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.bold)),
                            Text('$totalPets',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDemographicRow(
                    color: const Color(0xFF0284C7),
                    label: 'Dogs',
                    percentage: '${dogsPct.toStringAsFixed(1)}%',
                  ),
                  const SizedBox(height: 6),
                  _buildDemographicRow(
                    color: const Color(0xFFF97316),
                    label: 'Cats',
                    percentage: '${catsPct.toStringAsFixed(1)}%',
                  ),
                  const SizedBox(height: 6),
                  _buildDemographicRow(
                    color: const Color(0xFF8B5CF6),
                    label: 'Others',
                    percentage: '${othersPct.toStringAsFixed(1)}%',
                  ),
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
                style: const TextStyle(fontSize: 11, color: Color(0xFF334155))),
          ],
        ),
        Text(percentage,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A))),
      ],
    );
  }
}

class DashboardAppointmentsTableWidget extends StatefulWidget {
  final String selectedFilter;
  const DashboardAppointmentsTableWidget(
      {super.key, required this.selectedFilter});

  @override
  State<DashboardAppointmentsTableWidget> createState() =>
      _DashboardAppointmentsTableWidgetState();
}

class _DashboardAppointmentsTableWidgetState
    extends State<DashboardAppointmentsTableWidget> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  // DYNAMIC PET NAME RESOLVER FROM 'pets' COLLECTION IF MISSING IN APPOINTMENT DOC
  Future<String> _resolvePetName(Map<String, dynamic> data) async {
    // 1. Direct check in appointment doc
    if (data['petName'] != null &&
        data['petName'].toString().trim().isNotEmpty) {
      return data['petName'].toString().trim();
    }
    if (data['name'] != null && data['name'].toString().trim().isNotEmpty) {
      return data['name'].toString().trim();
    }

    // 2. Fetch from 'pets' collection using petId
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
    final todayStr = DateTime.now().toString().split(' ')[0];

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
              Text(
                'Schedule Overview (${widget.selectedFilter})',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(
                  _formatDateToWords(todayStr),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.selectedFilter == 'In-Patient') ...[
            StreamBuilder<QuerySnapshot>(
              stream: _db.collection('pets').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.hasData ? snapshot.data!.docs : [];
                final inPatientPets = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status =
                      (data['status'] ?? data['admissionStatus'] ?? '')
                          .toString()
                          .toLowerCase();
                  return status == 'admitted' || status == 'in-patient';
                }).toList();

                if (inPatientPets.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36.0),
                    child: Center(
                      child: Text(
                        'No in-patient admissions registered today.',
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
                    1: FlexColumnWidth(1.8),
                    2: FlexColumnWidth(1.8),
                    3: FlexColumnWidth(1.8),
                    4: FlexColumnWidth(1.5),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    const TableRow(
                      children: [
                        _TableHeader('PET NAME'),
                        _TableHeader('OWNER'),
                        _TableHeader('ADMISSION DATE'),
                        _TableHeader('SERVICES / REASON'),
                        _TableHeader('STATUS'),
                      ],
                    ),
                    ...inPatientPets.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final petName = data['name'] ?? data['petName'] ?? 'Pet';
                      final breed = data['breed'] ?? data['species'] ?? 'Dog';
                      final owner = data['ownerName'] ??
                          data['fullName'] ??
                          data['owner'] ??
                          'Owner';
                      final date = data['admissionDate'] ?? todayStr;
                      final reason =
                          data['reason'] ?? data['service'] ?? 'Confinement';

                      return TableRow(
                        children: [
                          _buildClickableCell(
                            context: context,
                            data: data,
                            resolvedPetName: petName,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(petName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xFF0F172A))),
                                Text(breed,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                          _buildClickableCell(
                            context: context,
                            data: data,
                            resolvedPetName: petName,
                            child: Text(owner,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF334155))),
                          ),
                          _buildClickableCell(
                            context: context,
                            data: data,
                            resolvedPetName: petName,
                            child: Text(_formatDateToWords(date),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A))),
                          ),
                          _buildClickableCell(
                            context: context,
                            data: data,
                            resolvedPetName: petName,
                            child: Text(reason,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF334155))),
                          ),
                          _buildClickableCell(
                            context: context,
                            data: data,
                            resolvedPetName: petName,
                            child: const Text('In-Patient',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0284C7))),
                          ),
                        ],
                      );
                    }),
                  ],
                );
              },
            ),
          ] else ...[
            StreamBuilder<QuerySnapshot>(
              stream: _db.collection('appointments').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.hasData ? snapshot.data!.docs : [];
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status =
                      (data['status'] ?? '').toString().toLowerCase();
                  final date = (data['date'] ?? '').toString();
                  final isUrgent = data['isUrgent'] ?? false;

                  if (widget.selectedFilter == 'Urgent Cases') {
                    return isUrgent == true &&
                        status != 'completed' &&
                        status != 'cancelled';
                  } else {
                    return status != 'completed' &&
                        status != 'cancelled' &&
                        date == todayStr;
                  }
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36.0),
                    child: Center(
                      child: Text(
                        'No active ${widget.selectedFilter.toLowerCase()} scheduled for today.',
                        style: const TextStyle(
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
                    1: FlexColumnWidth(1.8),
                    2: FlexColumnWidth(2.0),
                    3: FlexColumnWidth(1.6),
                    4: FlexColumnWidth(1.8),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    const TableRow(
                      children: [
                        _TableHeader('PET NAME'),
                        _TableHeader('OWNER'),
                        _TableHeader('DATE AND TIME'),
                        _TableHeader('SERVICES'),
                        _TableHeader('DOCTOR'),
                      ],
                    ),
                    ...filteredDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      final breed = data['breed'] ?? data['species'] ?? 'Dog';
                      final owner = data['ownerName'] ?? 'Owner';
                      final rawDate = data['date'] ?? todayStr;
                      final formattedDate =
                          _formatDateToWords(rawDate.toString());
                      final time = data['time'] ?? '09:00 AM - 10:30 AM';
                      final service = data['service'] ??
                          data['reason'] ??
                          'General Checkup';
                      final doctor =
                          data['doctor'] ?? 'Dr. James Nico Martinez';
                      final isUrgent = data['isUrgent'] ?? false;

                      return TableRow(
                        children: [
                          // 1. PET NAME (RESOLVED FROM PETS DB IF BLANK)
                          FutureBuilder<String>(
                            future: _resolvePetName(data),
                            builder: (context, petSnapshot) {
                              final resolvedPetName =
                                  petSnapshot.data ?? 'Loading...';

                              return _buildClickableCell(
                                context: context,
                                data: data,
                                resolvedPetName: resolvedPetName,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              resolvedPetName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: Color(0xFF0F172A)),
                                            ),
                                          ),
                                          if (isUrgent == true) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFEF2F2),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFFFCA5A5)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      size: 10,
                                                      color: Color(0xFFDC2626)),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    'URGENT',
                                                    style: TextStyle(
                                                        fontSize: 8.5,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFFDC2626)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(breed,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF94A3B8))),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // 2. OWNER
                          FutureBuilder<String>(
                            future: _resolvePetName(data),
                            builder: (context, petSnapshot) =>
                                _buildClickableCell(
                              context: context,
                              data: data,
                              resolvedPetName: petSnapshot.data ?? '',
                              child: Text(owner,
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF334155))),
                            ),
                          ),
                          // 3. DATE AND TIME
                          FutureBuilder<String>(
                            future: _resolvePetName(data),
                            builder: (context, petSnapshot) =>
                                _buildClickableCell(
                              context: context,
                              data: data,
                              resolvedPetName: petSnapshot.data ?? '',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(formattedDate,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF0F172A))),
                                  Text(time,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                          ),
                          // 4. SERVICES
                          FutureBuilder<String>(
                            future: _resolvePetName(data),
                            builder: (context, petSnapshot) =>
                                _buildClickableCell(
                              context: context,
                              data: data,
                              resolvedPetName: petSnapshot.data ?? '',
                              child: Text(service,
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF334155))),
                            ),
                          ),
                          // 5. DOCTOR
                          FutureBuilder<String>(
                            future: _resolvePetName(data),
                            builder: (context, petSnapshot) =>
                                _buildClickableCell(
                              context: context,
                              data: data,
                              resolvedPetName: petSnapshot.data ?? '',
                              child: Text(doctor,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0F172A))),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClickableCell(
      {required BuildContext context,
      required Map<String, dynamic> data,
      required String resolvedPetName,
      required Widget child}) {
    return InkWell(
      onTap: () => _showFullPetDetailsDialog(context, data, resolvedPetName),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: child,
      ),
    );
  }

  void _showFullPetDetailsDialog(
      BuildContext context, Map<String, dynamic> data, String resolvedPetName) {
    final petName =
        resolvedPetName.isNotEmpty ? resolvedPetName : 'Pet Patient';
    final petId = data['petId'] ?? 'PET-00000';
    final species = data['species'] ?? data['breed'] ?? 'Dog';
    final owner = data['ownerName'] ?? 'Owner';
    final service = data['service'] ?? 'General Checkup';
    final doctor = data['doctor'] ?? 'Dr. James Nico Martinez';
    final date = _formatDateToWords(data['date']?.toString());
    final time = data['time'] ?? '09:00 AM - 10:30 AM';
    final notes = data['notes'] ?? 'No additional medical notes provided.';
    final isUrgent = data['isUrgent'] ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFEEF2FF),
                          child: Icon(Icons.pets, color: Color(0xFF4F46E5)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(petName,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A))),
                            Text('$petId ($species)',
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                        icon: const Icon(Icons.close,
                            size: 20, color: Color(0xFF94A3B8)),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 20),
                if (isUrgent == true) ...[
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5))),
                    child: Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded,
                            size: 16, color: Color(0xFFDC2626)),
                        SizedBox(width: 8),
                        Text('MARK AS URGENT / EMERGENCY CASE',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDC2626))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildInfoTile('Pet Owner', owner, Icons.person_outline),
                _buildInfoTile('Service Scheduled', service,
                    Icons.medical_services_outlined),
                _buildInfoTile(
                    'Assigned Veterinarian', doctor, Icons.badge_outlined),
                _buildInfoTile('Date & Time Slot', '$date ($time)',
                    Icons.calendar_today_outlined),
                _buildInfoTile(
                    'Special Medical Notes', notes, Icons.note_alt_outlined),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close Record',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A))),
              ],
            ),
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
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8))),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double dogsPct;
  final double catsPct;
  final double othersPct;

  _DonutChartPainter({
    required this.dogsPct,
    required this.catsPct,
    required this.othersPct,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 14.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -1.5708;

    if (dogsPct > 0) {
      final sweepAngle = (dogsPct / 100) * 2 * 3.141592653589793;
      paint.color = const Color(0xFF0284C7);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    if (catsPct > 0) {
      final sweepAngle = (catsPct / 100) * 2 * 3.141592653589793;
      paint.color = const Color(0xFFF97316);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    if (othersPct > 0) {
      final sweepAngle = (othersPct / 100) * 2 * 3.141592653589793;
      paint.color = const Color(0xFF8B5CF6);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          startAngle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
