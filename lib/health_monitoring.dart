import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sidebar.dart';

class HealthMonitoringScreen extends StatefulWidget {
  const HealthMonitoringScreen({super.key});

  @override
  State<HealthMonitoringScreen> createState() => _HealthMonitoringScreenState();
}

class _HealthMonitoringScreenState extends State<HealthMonitoringScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mocking current logged in user role
  final String _currentUserRole = 'Doctor'; // 'Doctor' or 'Staff'
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

  // Doctor-Restricted New Intake Modal Launcher
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

  // View All History Modal
  void _openHistoryModal(List<QueryDocumentSnapshot> docs) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Health Intake Activity Log',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A))),
                  IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final petName = data['petName'] ?? 'Pet';
                      final breed =
                          data['breed'] ?? data['species'] ?? 'Patient';
                      final docName = data['doctorName'] ?? 'Attending Vet';
                      final status = data['status'] ?? 'STABLE';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.medical_services_outlined,
                                  color: Color(0xFF16A34A), size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("New Intake: $petName ($breed)",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF0F172A))),
                                  const SizedBox(height: 2),
                                  Text(
                                      "Attending Vet: $docName • Status: $status",
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                    stream: FirebaseFirestore.instance
                        .collection('health_monitoring')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? [];

                      // STATS CALCULATIONS
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

                      // Search Filter
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

                        return petName.contains(_searchQuery) ||
                            petId.contains(_searchQuery) ||
                            ownerName.contains(_searchQuery) ||
                            breed.contains(_searchQuery);
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
                                      'Health Monitoring - Pet Search',
                                      style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A)),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Efficiently manage and monitor patient vital statistics, medical history, and upcoming checkups.',
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

                            // STAT CARDS ROW
                            Row(
                              children: [
                                _StatCard(
                                  label: 'Active Monitoring',
                                  count: activeCount.toString(),
                                  icon: Icons.show_chart,
                                  iconBgColor: const Color(0xFFEEF2FF),
                                  iconColor: const Color(0xFF4F46E5),
                                ),
                                const SizedBox(width: 20),
                                _StatCard(
                                  label: 'Critical Alerts',
                                  count:
                                      criticalCount.toString().padLeft(2, '0'),
                                  icon: Icons.warning_amber_rounded,
                                  iconBgColor: const Color(0xFFFEE2E2),
                                  iconColor: const Color(0xFFDC2626),
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // MAIN CONTENT AREA
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Table Area (Patient Registry)
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
                                        // Header Bar with TOTAL BADGE & Search
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Text('Patient Registry',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF0F172A))),
                                                const SizedBox(width: 12),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF1F5F9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: const Color(
                                                            0xFFE2E8F0)),
                                                  ),
                                                  child: Text(
                                                    '${docs.length} TOTAL',
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF64748B)),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Search Input
                                            Container(
                                              width: 260,
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

                                        // PATIENT REGISTRY TABLE
                                        Table(
                                          columnWidths: const {
                                            0: FlexColumnWidth(1.2), // PET ID
                                            1: FlexColumnWidth(1.6), // PET NAME
                                            2: FlexColumnWidth(
                                                2.0), // OWNER'S NAME
                                            3: FlexColumnWidth(1.8), // BREED
                                            4: FlexColumnWidth(1.4), // STATUS
                                            5: FlexColumnWidth(1.0), // ACTIONS
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
                                            padding: EdgeInsets.symmetric(
                                                vertical: 40.0),
                                            child: Center(
                                              child: Text(
                                                  'No patients found in monitoring registry.',
                                                  style: TextStyle(
                                                      color: Color(0xFF94A3B8),
                                                      fontSize: 13)),
                                            ),
                                          ),

                                        const SizedBox(height: 24),

                                        // Dynamic Pagination Display
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Showing 1 to ${filteredDocs.length} of ${docs.length} pets',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B)),
                                            ),
                                            Row(
                                              children: const [
                                                IconButton(
                                                    icon: Icon(
                                                        Icons.chevron_left,
                                                        size: 20,
                                                        color:
                                                            Color(0xFF94A3B8)),
                                                    onPressed: null),
                                                IconButton(
                                                    icon: Icon(
                                                        Icons.chevron_right,
                                                        size: 20,
                                                        color:
                                                            Color(0xFF94A3B8)),
                                                    onPressed: null),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),

                                // Right Area (Recent Activity Only)
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Recent Activity',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF0F172A)),
                                        ),
                                        const SizedBox(height: 16),

                                        // Dynamic List from DB
                                        if (docs.isEmpty)
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 24),
                                            child: Center(
                                              child: Text(
                                                  'No recent monitoring activity.',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Color(0xFF94A3B8))),
                                            ),
                                          )
                                        else
                                          Column(
                                            children: docs.take(4).map((doc) {
                                              final data = doc.data()
                                                  as Map<String, dynamic>;
                                              final petName =
                                                  data['petName'] ?? 'Patient';
                                              final breed = data['breed'] ??
                                                  data['species'] ??
                                                  'Patient';
                                              final docName =
                                                  data['doctorName'] ??
                                                      'Dr. Tamesis';
                                              final status =
                                                  (data['status'] ?? 'STABLE')
                                                      .toString()
                                                      .toUpperCase();

                                              return Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 12),
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFF8FAFC),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: const Color(
                                                          0xFFF1F5F9)),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6),
                                                      decoration: BoxDecoration(
                                                        color: status ==
                                                                    'URGENT' ||
                                                                status ==
                                                                    'CRITICAL'
                                                            ? const Color(
                                                                0xFFFEE2E2)
                                                            : const Color(
                                                                0xFFDCFCE7),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        status == 'URGENT' ||
                                                                status ==
                                                                    'CRITICAL'
                                                            ? Icons
                                                                .warning_amber_rounded
                                                            : Icons
                                                                .medical_services_outlined,
                                                        color: status ==
                                                                    'URGENT' ||
                                                                status ==
                                                                    'CRITICAL'
                                                            ? const Color(
                                                                0xFFDC2626)
                                                            : const Color(
                                                                0xFF16A34A),
                                                        size: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'New Intake: "$petName"',
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0xFF0F172A)),
                                                          ),
                                                          const SizedBox(
                                                              height: 2),
                                                          Text(
                                                            '$breed • $docName',
                                                            style: const TextStyle(
                                                                fontSize: 11,
                                                                color: Color(
                                                                    0xFF64748B)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),

                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton(
                                            onPressed: () =>
                                                _openHistoryModal(docs),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              side: const BorderSide(
                                                  color: Color(0xFFCBD5E1)),
                                            ),
                                            child: const Text(
                                                'View All History',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF334155))),
                                          ),
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

    final petId = data['petId'] ?? '#FF-0000';
    final petName = data['petName'] ?? 'N/A';
    final ownerName = data['ownerName'] ?? 'N/A';
    final breed = data['breed'] ?? data['species'] ?? 'N/A';
    final status = (data['status'] ?? 'STABLE').toString().toUpperCase();

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
        _buildStatusBadge(status),
        InkWell(
          onTap: () {},
          child: const Text('Details',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A))),
        ),
      ],
    );
  }

  // Plain Colored Text Status
  Widget _buildStatusBadge(String status) {
    Color textColor = const Color(0xFF16A34A); // Green for STABLE

    if (status == 'URGENT' || status == 'CRITICAL') {
      textColor = const Color(0xFFDC2626); // Red
    } else if (status == 'RECOVERED') {
      textColor = const Color(0xFF0D9488); // Teal
    } else if (status == 'OBSERVATION') {
      textColor = const Color(0xFFD97706); // Amber
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
}

// ==========================================
// NEW PATIENT INTAKE MODAL (Fixed & Overflow-Free)
// ==========================================
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
          'petId': _selectedPetId ?? '#PET-00001',
          'petName': _selectedPetName ?? 'Pet',
          'breed': _selectedBreed ?? 'General',
          'ownerDocId': _selectedOwnerDocId,
          'ownerId': _selectedOwnerId ?? '#OWN-00001',
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

                // Owner Search
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
                          _selectedOwnerId = data['ownerID'] ??
                              data['ownerId'] ??
                              '#OWN-00001';
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

                // Pet Dropdown (Safely mapping using Document ID String)
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

  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
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
              padding: const EdgeInsets.all(12),
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
                        fontSize: 12,
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
