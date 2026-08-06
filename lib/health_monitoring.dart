import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sidebar.dart';

class HealthMonitoringScreen extends StatefulWidget {
  const HealthMonitoringScreen({super.key});

  @override
  State<HealthMonitoringScreen> createState() => _HealthMonitoringScreenState();
}

class _HealthMonitoringScreenState extends State<HealthMonitoringScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Selected filter for top stat cards: 'Active Monitoring', 'Critical Alerts', 'Discharged Today'
  String _selectedStatFilter = 'Active Monitoring';

  // Mocking current logged in user role
  final String _currentUserRole = 'Doctor';
  final String _currentDoctorName = 'Dr. Tamesis';

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

  void _openNewIntakeModal() {
    if (_currentUserRole != 'Doctor') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.lock, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text('Access Restricted',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Only licensed veterinarians/doctors are authorized to perform patient intake and initial medical assessment.',
            style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Understood',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) =>
          NewPatientIntakeModal(doctorName: _currentDoctorName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          const SidebarMenu(activeRoute: 'health_monitoring'),
          Expanded(
            child: Column(
              children: [
                const _TopHeader(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _db.collection('health_monitoring').snapshots(),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? [];

                      // STATS CALCULATIONS CONNECTED TO FIRESTORE
                      int activeCount = 0;
                      int criticalCount = 0;
                      int dischargedTodayCount = 0;

                      for (var doc in docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final status =
                            (data['status'] ?? '').toString().toUpperCase();
                        final dischargedAt = data['dischargedAt'];

                        if (dischargedAt == null && status != 'DISCHARGED') {
                          activeCount++;
                        }
                        if (status == 'URGENT' || status == 'CRITICAL') {
                          criticalCount++;
                        }
                        if (status == 'DISCHARGED' || status == 'RECOVERED') {
                          dischargedTodayCount++;
                        }
                      }

                      // SEARCH & STAT CARD FILTERING
                      final filteredDocs = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final petName =
                            (data['petName'] ?? '').toString().toLowerCase();
                        final petId =
                            (data['petId'] ?? '').toString().toLowerCase();
                        final ownerName =
                            (data['ownerName'] ?? '').toString().toLowerCase();
                        final breed = (data['breed'] ?? data['species'] ?? '')
                            .toString()
                            .toLowerCase();
                        final status =
                            (data['status'] ?? '').toString().toUpperCase();
                        final dischargedAt = data['dischargedAt'];

                        final matchesSearch = petName.contains(_searchQuery) ||
                            petId.contains(_searchQuery) ||
                            ownerName.contains(_searchQuery) ||
                            breed.contains(_searchQuery);

                        bool matchesStatFilter = true;
                        if (_selectedStatFilter == 'Active Monitoring') {
                          matchesStatFilter =
                              (dischargedAt == null && status != 'DISCHARGED');
                        } else if (_selectedStatFilter == 'Critical Alerts') {
                          matchesStatFilter =
                              (status == 'URGENT' || status == 'CRITICAL');
                        } else if (_selectedStatFilter == 'Discharged Today') {
                          matchesStatFilter =
                              (status == 'DISCHARGED' || status == 'RECOVERED');
                        }

                        return matchesSearch && matchesStatFilter;
                      }).toList();

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Monitoring > Pet Search',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B))),
                                    SizedBox(height: 4),
                                    Text(
                                      'Health Monitoring - Patient Registry',
                                      style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A)),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Efficiently manage and monitor patient vital statistics, medical history, and confinement status.',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.filter_list,
                                          size: 16, color: Color(0xFF334155)),
                                      label: const Text('Filter View',
                                          style: TextStyle(
                                              color: Color(0xFF334155),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        side: const BorderSide(
                                            color: Color(0xFFCBD5E1)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: _openNewIntakeModal,
                                      icon: const Icon(Icons.add,
                                          size: 18, color: Colors.white),
                                      label: const Text('+ New Intake',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF0F172A),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        elevation: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // CLICKABLE STAT CARDS
                            Row(
                              children: [
                                _StatCard(
                                  label: 'Active Monitoring',
                                  count: activeCount.toString(),
                                  icon: Icons.show_chart,
                                  iconBgColor: const Color(0xFFEEF2FF),
                                  iconColor: const Color(0xFF4F46E5),
                                  isSelected: _selectedStatFilter ==
                                      'Active Monitoring',
                                  onTap: () => setState(() =>
                                      _selectedStatFilter =
                                          'Active Monitoring'),
                                ),
                                const SizedBox(width: 20),
                                _StatCard(
                                  label: 'Critical Alerts',
                                  count:
                                      criticalCount.toString().padLeft(2, '0'),
                                  icon: Icons.warning_amber_rounded,
                                  iconBgColor: const Color(0xFFFEE2E2),
                                  iconColor: const Color(0xFFDC2626),
                                  isSelected:
                                      _selectedStatFilter == 'Critical Alerts',
                                  onTap: () => setState(() =>
                                      _selectedStatFilter = 'Critical Alerts'),
                                ),
                                const SizedBox(width: 20),
                                _StatCard(
                                  label: 'Discharged Today',
                                  count: dischargedTodayCount
                                      .toString()
                                      .padLeft(2, '0'),
                                  icon: Icons.check_circle_outline,
                                  iconBgColor: const Color(0xFFDCFCE7),
                                  iconColor: const Color(0xFF16A34A),
                                  isSelected:
                                      _selectedStatFilter == 'Discharged Today',
                                  onTap: () => setState(() =>
                                      _selectedStatFilter = 'Discharged Today'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // FULL-WIDTH PATIENT REGISTRY TABLE WITH CONFINEMENT STATUS
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                              'Patient Registry (${_selectedStatFilter})',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0F172A))),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color:
                                                      const Color(0xFFE2E8F0)),
                                            ),
                                            child: Text(
                                              '${filteredDocs.length} TOTAL',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF64748B)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 280,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: TextField(
                                          controller: _searchController,
                                          style: const TextStyle(fontSize: 12),
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Search by name, owner, or ID...',
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

                                  // PATIENT REGISTRY TABLE WITH CONFINEMENT STATUS
                                  Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(1.2), // PET ID
                                      1: FlexColumnWidth(1.5), // PET NAME
                                      2: FlexColumnWidth(1.8), // OWNER'S NAME
                                      3: FlexColumnWidth(1.4), // BREED
                                      4: FlexColumnWidth(
                                          1.8), // CONFINEMENT STATUS
                                      5: FlexColumnWidth(1.2), // MEDICAL STATUS
                                      6: FlexColumnWidth(0.9), // ACTIONS
                                    },
                                    defaultVerticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    children: [
                                      const TableRow(
                                        children: [
                                          _TableHeader('PET ID'),
                                          _TableHeader('PET NAME'),
                                          _TableHeader('OWNER\'S NAME'),
                                          _TableHeader('BREED'),
                                          _TableHeader('CONFINEMENT'),
                                          _TableHeader('STATUS'),
                                          _TableHeader('ACTIONS'),
                                        ],
                                      ),
                                      for (var doc in filteredDocs)
                                        _buildRow(doc),
                                    ],
                                  ),

                                  if (filteredDocs.isEmpty)
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 40.0),
                                      child: Center(
                                        child: Text(
                                            'No patients found matching this filter.',
                                            style: TextStyle(
                                                color: Color(0xFF94A3B8),
                                                fontSize: 13,
                                                fontStyle: FontStyle.italic)),
                                      ),
                                    ),

                                  const SizedBox(height: 24),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Showing 1 to ${filteredDocs.length} of ${docs.length} entries',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B)),
                                      ),
                                      Row(
                                        children: const [
                                          IconButton(
                                              icon: Icon(Icons.chevron_left,
                                                  size: 20,
                                                  color: Color(0xFF94A3B8)),
                                              onPressed: null),
                                          IconButton(
                                              icon: Icon(Icons.chevron_right,
                                                  size: 20,
                                                  color: Color(0xFF94A3B8)),
                                              onPressed: null),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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

  TableRow _buildRow(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final petId = data['petId'] ?? 'PET-00000';
    final petName = data['petName'] ?? data['name'] ?? 'Pet';
    final ownerName = data['ownerName'] ?? 'Owner';
    final breed = data['breed'] ?? data['species'] ?? 'Dog';
    final status = (data['status'] ?? 'STABLE').toString().toUpperCase();
    final dischargedAt = data['dischargedAt'];

    bool isConfined = (dischargedAt == null && status != 'DISCHARGED');

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
        Text(petName,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF0F172A))),
        Text(ownerName,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
        Text(breed,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500)),
        // CONFINEMENT STATUS BADGE (CONFINED VS NAKAUWI NA)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isConfined ? Icons.hotel_outlined : Icons.home_outlined,
                size: 14,
                color: isConfined
                    ? const Color(0xFF0284C7)
                    : const Color(0xFF16A34A),
              ),
              const SizedBox(width: 4),
              Text(
                isConfined ? 'CONFINED' : 'NAKAUWI NA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isConfined
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(status),
        InkWell(
          onTap: () => _openPatientDetailsModal(doc.id, data),
          child: const Text('Details',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A))),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color textColor = const Color(0xFF16A34A);

    if (status == 'URGENT' || status == 'CRITICAL') {
      textColor = const Color(0xFFDC2626);
    } else if (status == 'RECOVERED' || status == 'DISCHARGED') {
      textColor = const Color(0xFF0D9488);
    } else if (status == 'OBSERVATION') {
      textColor = const Color(0xFFD97706);
    }

    return Text(
      status,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: 0.5,
      ),
    );
  }

  // PATIENT DETAILS MODAL DIRECTLY CONNECTED TO FIRESTORE 'medical_records' FIELDS
  void _openPatientDetailsModal(String docId, Map<String, dynamic> data) {
    final petName = data['petName'] ?? data['name'] ?? 'Pet Patient';
    final petId = data['petId'] ?? 'PET-00000';
    final breed = data['breed'] ?? data['species'] ?? 'Dog';
    final ownerName = data['ownerName'] ?? 'Owner';
    final doctorName = data['doctorName'] ?? 'Dr. Tamesis';
    final status = (data['status'] ?? 'STABLE').toString().toUpperCase();
    final dischargedAt = data['dischargedAt'];

    bool isConfined = (dischargedAt == null && status != 'DISCHARGED');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 680,
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
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
                            Text('$petId ($breed) • Owner: $ownerName',
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ATTENDING VET: $doctorName',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569))),
                          const SizedBox(height: 2),
                          Text(
                            isConfined
                                ? 'STATUS: CONFINED AT CLINIC BAY'
                                : 'STATUS: DISCHARGED / NAKAUWI NA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isConfined
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'MEDICAL RECORDS & CLINICAL DIAGNOSIS HISTORY',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 10),

                // STREAM FROM FIRESTORE 'medical_records' COLLECTION
                StreamBuilder<QuerySnapshot>(
                  stream: _db
                      .collection('medical_records')
                      .where('petId', isEqualTo: petId)
                      .snapshots(),
                  builder: (context, recordSnap) {
                    if (recordSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final records = recordSnap.data?.docs ?? [];

                    if (records.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: const Text(
                          'No prior consultation or clinical diagnosis found for this pet.',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                              fontStyle: FontStyle.italic),
                        ),
                      );
                    }

                    return Column(
                      children: records.map((doc) {
                        final rec = doc.data() as Map<String, dynamic>;

                        // FIRESTORE FIELD MAPPINGS FROM YOUR SCREENSHOT
                        final diagnosis =
                            rec['diagnosis'] ?? 'No recorded diagnosis';
                        final prescription =
                            rec['prescription'] ?? 'None prescribed';
                        final veterinarianNotes = rec['veterinarianNotes'] ??
                            rec['notes'] ??
                            'No notes provided';
                        final service = rec['service'] ?? 'General Checkup';
                        final docName = rec['doctorName'] ?? doctorName;
                        final isUrgent = rec['isUrgent'] ?? false;

                        String formattedDate = 'Recent';
                        if (rec['createdAt'] != null &&
                            rec['createdAt'] is Timestamp) {
                          formattedDate = _formatDateToWords(
                              (rec['createdAt'] as Timestamp)
                                  .toDate()
                                  .toString());
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: isUrgent
                                      ? const Color(0xFFFCA5A5)
                                      : const Color(0xFFE2E8F0))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          service.toString().toUpperCase(),
                                          style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF4F46E5)),
                                        ),
                                      ),
                                      if (isUrgent == true) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF2F2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                                color: const Color(0xFFFCA5A5)),
                                          ),
                                          child: const Text(
                                            'URGENT',
                                            style: TextStyle(
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFDC2626)),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(formattedDate,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF64748B))),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // CLINICAL DIAGNOSIS
                              const Text('CLINICAL DIAGNOSIS:',
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF94A3B8))),
                              const SizedBox(height: 2),
                              Text(diagnosis,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A))),
                              const SizedBox(height: 10),

                              // PRESCRIBED MEDICATIONS
                              const Text('PRESCRIBED MEDICATIONS / TREATMENT:',
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF94A3B8))),
                              const SizedBox(height: 2),
                              Text(prescription,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF334155))),
                              const SizedBox(height: 10),

                              // VETERINARIAN NOTES
                              const Text('VETERINARIAN NOTES:',
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF94A3B8))),
                              const SizedBox(height: 2),
                              Text(veterinarianNotes,
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF64748B))),
                              const SizedBox(height: 10),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Text('Attending Vet: $docName',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A))),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ACTION TO TOGGLE DISCHARGE (NAKAUWI NA)
                    if (isConfined)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.home_outlined, size: 18),
                        label: const Text('Discharge Patient (Uuwi Na)',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: () async {
                          await _db
                              .collection('health_monitoring')
                              .doc(docId)
                              .update({
                            'status': 'DISCHARGED',
                            'dischargedAt': FieldValue.serverTimestamp(),
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '$petName has been discharged and marked as Nakauwi Na!'),
                            ),
                          );
                        },
                      )
                    else
                      const Text(
                        '✓ Patient is already Discharged',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A)),
                      ),
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
        ),
      ),
    );
  }
}

class NewPatientIntakeModal extends StatefulWidget {
  final String doctorName;
  const NewPatientIntakeModal({super.key, required this.doctorName});

  @override
  State<NewPatientIntakeModal> createState() => _NewPatientIntakeModalState();
}

class _NewPatientIntakeModalState extends State<NewPatientIntakeModal> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedOwnerDocId;
  String? _selectedOwnerId;
  String? _selectedOwnerName;

  String? _selectedPetDocId;
  String? _selectedPetId;
  String? _selectedPetName;
  String? _selectedBreed;

  final TextEditingController _chiefComplaintController =
      TextEditingController();
  final TextEditingController _locationBayController =
      TextEditingController(text: 'Recovery Bay A1');
  final TextEditingController _tempController =
      TextEditingController(text: '38.5');
  final TextEditingController _heartRateController =
      TextEditingController(text: '110');
  final TextEditingController _respRateController =
      TextEditingController(text: '24');
  final TextEditingController _weightController =
      TextEditingController(text: '12.5');

  String _selectedStatus = 'STABLE';
  bool _isSaving = false;

  InputDecoration _inputDeco(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5)),
    );
  }

  void _saveIntake() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedOwnerDocId == null || _selectedPetDocId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please select owner and pet!'),
            backgroundColor: Colors.red));
        return;
      }

      setState(() => _isSaving = true);

      try {
        final snap = await FirebaseFirestore.instance
            .collection('health_monitoring')
            .get();
        final intakeId =
            "INT-${(snap.docs.length + 1).toString().padLeft(5, '0')}";

        await FirebaseFirestore.instance.collection('health_monitoring').add({
          'intakeId': intakeId,
          'petDocId': _selectedPetDocId,
          'petId': _selectedPetId ?? 'PET-00001',
          'petName': _selectedPetName ?? 'Pet',
          'breed': _selectedBreed ?? 'General',
          'ownerDocId': _selectedOwnerDocId,
          'ownerId': _selectedOwnerId ?? 'OWN-00001',
          'ownerName': _selectedOwnerName ?? 'Owner',
          'doctorName': widget.doctorName,
          'chiefComplaint': _chiefComplaintController.text.trim(),
          'locationBay': _locationBayController.text.trim(),
          'status': _selectedStatus,
          'dischargedAt': null,
          'admittedAt': FieldValue.serverTimestamp(),
          'vitals': {
            'temperature': double.tryParse(_tempController.text.trim()) ?? 38.5,
            'heartRate': int.tryParse(_heartRateController.text.trim()) ?? 110,
            'respRate': int.tryParse(_respRateController.text.trim()) ?? 24,
            'weight': double.tryParse(_weightController.text.trim()) ?? 12.5,
          },
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Patient intake recorded successfully!'),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 520,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('New Patient Intake',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A))),
                        Text("Attending Vet: ${widget.doctorName}",
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                    IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
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
                        if (textVal.text.trim().isEmpty) {
                          return const Iterable<QueryDocumentSnapshot>.empty();
                        }
                        final q = textVal.text.toLowerCase();
                        return users.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return (data['fullName'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains(q) ||
                              (data['ownerID'] ?? data['ownerId'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains(q);
                        });
                      },
                      onSelected: (doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        setState(() {
                          _selectedOwnerDocId = doc.id;
                          _selectedOwnerId =
                              data['ownerID'] ?? data['ownerId'] ?? 'OWN-00001';
                          _selectedOwnerName = data['fullName'] ?? 'Owner';
                          _selectedPetDocId = null;
                        });
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: _inputDeco('SEARCH OWNER*',
                              hint: 'Type owner name...'),
                          validator: (v) => _selectedOwnerDocId == null
                              ? 'Please select owner'
                              : null,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                if (_selectedOwnerDocId != null)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('pets')
                        .where('ownerDocId', isEqualTo: _selectedOwnerDocId)
                        .snapshots(),
                    builder: (context, petSnap) {
                      final pets = petSnap.data?.docs ?? [];

                      return DropdownButtonFormField<String>(
                        value: _selectedPetDocId,
                        decoration: _inputDeco('SELECT PATIENT PET*'),
                        items: pets.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DropdownMenuItem<String>(
                            value: doc.id,
                            child: Text("${data['petName']} (${data['petId']})",
                                style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (docId) {
                          if (docId != null) {
                            final selectedDoc = pets
                                .firstWhere((element) => element.id == docId);
                            final data =
                                selectedDoc.data() as Map<String, dynamic>;
                            setState(() {
                              _selectedPetDocId = docId;
                              _selectedPetId = data['petId'];
                              _selectedPetName = data['petName'];
                              _selectedBreed = data['breed'] ?? data['species'];
                            });
                          }
                        },
                        validator: (v) => _selectedPetDocId == null
                            ? 'Please select pet'
                            : null,
                      );
                    },
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _chiefComplaintController,
                  decoration: _inputDeco('CHIEF COMPLAINT / REASON*',
                      hint: 'e.g. Routine post-surgery monitoring'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: _inputDeco('INITIAL STATUS*'),
                        items: ['STABLE', 'OBSERVATION', 'URGENT', 'CRITICAL']
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e,
                                    style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedStatus = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _locationBayController,
                        decoration: _inputDeco('BAY / WARD LOCATION*'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('INITIAL VITALS',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                            controller: _tempController,
                            decoration: _inputDeco('Temp (°C)'))),
                    const SizedBox(width: 6),
                    Expanded(
                        child: TextFormField(
                            controller: _heartRateController,
                            decoration: _inputDeco('Heart Rate'))),
                    const SizedBox(width: 6),
                    Expanded(
                        child: TextFormField(
                            controller: _weightController,
                            decoration: _inputDeco('Weight (kg)'))),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                            style: TextStyle(color: Color(0xFF64748B)))),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveIntake,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Record Intake',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
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
  final bool isSelected;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? iconColor : const Color(0xFFE2E8F0),
              width: isSelected ? 2.2 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: iconColor.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? iconColor
                              : const Color(0xFF94A3B8))),
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
