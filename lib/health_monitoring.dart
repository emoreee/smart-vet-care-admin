import 'package:flutter/material.dart';
import 'sidebar.dart';

class HealthMonitoringScreen extends StatefulWidget {
  const HealthMonitoringScreen({super.key});

  @override
  State<HealthMonitoringScreen> createState() => _HealthMonitoringScreenState();
}

class _HealthMonitoringScreenState extends State<HealthMonitoringScreen> {
  // Trigger New Intake Modal
  Future<void> _openNewIntakeModal(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const NewPatientIntakeDialog();
      },
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully admitted ${result['patient_name']} to active monitoring!',
          ),
          backgroundColor: const Color(0xFF166534),
        ),
      );
    }
  }

  // Trigger Clinical Monitoring Details Sheet
  void _openClinicalDetailsModal(
    BuildContext context,
    Map<String, String> petData,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PatientClinicalDetailsDialog(petData: petData);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar Navigation
          const SidebarMenu(activeRoute: 'health_monitoring'),

          // Main Workspace
          Expanded(
            child: Column(
              children: [
                const _TopHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Monitoring > Pet Search',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Health Monitoring - Pet Search',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Efficiently manage and monitor patient vital statistics, medical history, and upcoming checkups.',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.tune,
                                    size: 16,
                                    color: Color(0xFF64748B),
                                  ),
                                  label: const Text(
                                    'Filter View',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: () => _openNewIntakeModal(context),
                                  icon: const Icon(
                                    Icons.add,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    '+ New Intake',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Metric Cards
                        Row(
                          children: [
                            Expanded(
                              child: _metricCard(
                                Icons.show_chart,
                                'Active Monitoring',
                                '1,248',
                                const Color(0xFF312E81),
                                const Color(0xFFEEF2FF),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _metricCard(
                                Icons.warning_amber_rounded,
                                'Critical Alerts',
                                '12',
                                const Color(0xFFDC2626),
                                const Color(0xFFFEF2F2),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _metricCard(
                                Icons.check_circle_outline,
                                'Discharged Today',
                                '42',
                                const Color(0xFF0284C7),
                                const Color(0xFFF0F9FF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Main Content Grid
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: Patient Registry Table
                            Expanded(
                              flex: 3,
                              child: _PatientRegistryCard(
                                onOpenDetails: (petData) =>
                                    _openClinicalDetailsModal(context, petData),
                              ),
                            ),
                            const SizedBox(width: 24),

                            // Right Column: Clinic Status & Recent Activity Panels
                            const SizedBox(
                              width: 300,
                              child: Column(
                                children: [
                                  _ClinicStatusCard(),
                                  SizedBox(height: 20),
                                  _RecentActivityCard(),
                                ],
                              ),
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

  Widget _metricCard(
    IconData icon,
    String label,
    String value,
    Color iconFg,
    Color iconBg,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconFg, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// PATIENT CLINICAL DETAILS MODAL SHEET
// ==========================================
class PatientClinicalDetailsDialog extends StatefulWidget {
  final Map<String, String> petData;

  const PatientClinicalDetailsDialog({super.key, required this.petData});

  @override
  State<PatientClinicalDetailsDialog> createState() =>
      _PatientClinicalDetailsDialogState();
}

class _PatientClinicalDetailsDialogState
    extends State<PatientClinicalDetailsDialog> {
  late String _status;

  // Dummy Vitals Data
  double _temp = 38.6;
  double _weight = 28.5;
  int _heartRate = 95;
  int _respRate = 22;
  String _lastUpdated = '10 minutes ago';

  final List<Map<String, String>> _vitalsHistory = [
    {
      'time': 'Today, 08:00 AM',
      'temp': '38.6 °C',
      'weight': '28.5 kg',
      'hr': '95 BPM',
      'rr': '22 RPM',
      'staff': 'Vet Tech Mark',
    },
    {
      'time': 'Today, 04:00 AM',
      'temp': '38.9 °C',
      'weight': '28.5 kg',
      'hr': '102 BPM',
      'rr': '26 RPM',
      'staff': 'Dr. Aris K.',
    },
    {
      'time': 'Yesterday, 08:00 PM',
      'temp': '39.1 °C',
      'weight': '28.4 kg',
      'hr': '110 BPM',
      'rr': '28 RPM',
      'staff': 'Vet Tech Sarah',
    },
  ];

  final List<Map<String, String>> _vetNotes = [
    {
      'time': '08:15 AM Today',
      'vet': 'Dr. Aris Kensington',
      'note':
          'Patient is responsive and showing good appetite. Temperature has stabilized back to normal range.',
    },
    {
      'time': '04:30 AM Today',
      'vet': 'Dr. Sarah Smith',
      'note':
          'Administered IV Fluids (0.9% NaCl) and Antibiotics. Monitored for fever reduction.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.petData['status'] ?? 'STABLE';
  }

  // Open Sub-Modal to Log New Vitals
  void _openLogVitalsModal() {
    final tempController = TextEditingController(text: _temp.toString());
    final weightController = TextEditingController(text: _weight.toString());
    final hrController = TextEditingController(text: _heartRate.toString());
    final rrController = TextEditingController(text: _respRate.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Log New Vitals (${widget.petData['name']})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: _vInput(tempController, 'Temperature (°C)')),
                  const SizedBox(width: 10),
                  Expanded(child: _vInput(weightController, 'Weight (kg)')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _vInput(hrController, 'Heart Rate (BPM)')),
                  const SizedBox(width: 10),
                  Expanded(child: _vInput(rrController, 'Resp Rate (RPM)')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _temp = double.tryParse(tempController.text) ?? _temp;
                  _weight = double.tryParse(weightController.text) ?? _weight;
                  _heartRate = int.tryParse(hrController.text) ?? _heartRate;
                  _respRate = int.tryParse(rrController.text) ?? _respRate;
                  _lastUpdated = 'Just now';
                  _vitalsHistory.insert(0, {
                    'time': 'Just now',
                    'temp': '$_temp °C',
                    'weight': '$_weight kg',
                    'hr': '$_heartRate BPM',
                    'rr': '$_respRate RPM',
                    'staff': 'Clinic Admin',
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vitals updated successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
              ),
              child: const Text(
                'Save Vitals',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Discharge Confirmation Modal
  void _showDischargeConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Discharge ${widget.petData['name']}?',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to discharge ${widget.petData['name']} (#${widget.petData['id']})? This will finalize active monitoring.',
            style: const TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _status = 'DISCHARGED';
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.petData['name']} has been DISCHARGED!',
                    ),
                    backgroundColor: const Color(0xFF166534),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              child: const Text(
                'Confirm Discharge',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _vInput(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 880,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. PATIENT HEADER BANNER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFEEF2FF),
                      child: Text(
                        widget.petData['name']![0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF312E81),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.petData['name']!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(_status),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.petData['breed']} • ID: ${widget.petData['id']} • Owner: ${widget.petData['owner']}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _openLogVitalsModal,
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                        color: Color(0xFF0F172A),
                      ),
                      label: const Text(
                        '+ Log New Vitals',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _status == 'DISCHARGED'
                          ? null
                          : _showDischargeConfirmation,
                      icon: const Icon(
                        Icons.output_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        _status == 'DISCHARGED'
                            ? 'Discharged'
                            : 'Discharge Patient',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Color(0xFFE2E8F0), height: 24),

            // 2. MAIN GRID CONTENT (LEFT vs RIGHT COLUMNS)
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN (VITALS & CLINICAL TRACKING)
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Current Baseline Vitals',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Last reading: $_lastUpdated',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // 4-Grid Vitals Stats
                          Row(
                            children: [
                              Expanded(
                                child: _vitalStatCard(
                                  'Temperature',
                                  '$_temp °C',
                                  Icons.thermostat_outlined,
                                  const Color(0xFFD97706),
                                  const Color(0xFFFEF3C7),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _vitalStatCard(
                                  'Body Weight',
                                  '$_weight kg',
                                  Icons.monitor_weight_outlined,
                                  const Color(0xFF2563EB),
                                  const Color(0xFFDBEAFE),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _vitalStatCard(
                                  'Heart Rate',
                                  '$_heartRate BPM',
                                  Icons.favorite_border,
                                  const Color(0xFFDC2626),
                                  const Color(0xFFFEE2E2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _vitalStatCard(
                                  'Resp Rate',
                                  '$_respRate RPM',
                                  Icons.air_outlined,
                                  const Color(0xFF059669),
                                  const Color(0xFFD1FAE5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Vitals History Log Table
                          const Text(
                            'Vital Signs History',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1.8),
                                1: FlexColumnWidth(1.0),
                                2: FlexColumnWidth(1.0),
                                3: FlexColumnWidth(1.0),
                                4: FlexColumnWidth(1.0),
                                5: FlexColumnWidth(1.2),
                              },
                              children: [
                                const TableRow(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF8FAFC),
                                  ),
                                  children: [
                                    _TH('TIMESTAMP'),
                                    _TH('TEMP'),
                                    _TH('WEIGHT'),
                                    _TH('HR'),
                                    _TH('RR'),
                                    _TH('LOGGED BY'),
                                  ],
                                ),
                                for (var item in _vitalsHistory)
                                  TableRow(
                                    children: [
                                      _TD(item['time']!),
                                      _TD(item['temp']!),
                                      _TD(item['weight']!),
                                      _TD(item['hr']!),
                                      _TD(item['rr']!),
                                      _TD(item['staff']!),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Attending Vet Notes & Diagnosis Feed
                          const Text(
                            'Attending Vet Observations & Diagnosis',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (var note in _vetNotes)
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        note['vet']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        note['time']!,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    note['note']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // RIGHT COLUMN (MEDICATIONS & LOCATION)
                    SizedBox(
                      width: 280,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cage / Location Badge
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFC7D2FE),
                              ),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.bedroom_child_outlined,
                                  color: Color(0xFF312E81),
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Assigned Location',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF6366F1),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Recovery Bay A2',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF312E81),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Allergy Warning Box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFCA5A5),
                              ),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xFFDC2626),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'ALLERGY ALERT: Sensitive to Penicillin-based antibiotics.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF991B1B),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Active Medications Log
                          const Text(
                            'Active Medications & Care Plan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _medCard(
                            'Amoxicillin Oral Suspension',
                            '250mg • Every 8 hours',
                            'Given 08:00 AM',
                            true,
                          ),
                          _medCard(
                            'Meloxicam Analgesic',
                            '0.5ml • Once Daily',
                            'Scheduled 06:00 PM',
                            false,
                          ),
                          _medCard(
                            '0.9% NaCl IV Drip',
                            '50ml/hr • Continuous',
                            'Active Flow',
                            true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFD1FAE5);
    Color fg = const Color(0xFF10B981);

    if (status == 'URGENT') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFEF4444);
    } else if (status == 'OBSERVATION') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFF59E0B);
    } else if (status == 'DISCHARGED' || status == 'RECOVERED') {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _vitalStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, size: 12, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _medCard(String name, String dosage, String status, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.schedule,
            size: 16,
            color: isDone ? const Color(0xFF166534) : const Color(0xFFD97706),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '$dosage • $status',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String label;
  const _TH(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

class _TD extends StatelessWidget {
  final String text;
  const _TD(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Color(0xFF334155)),
      ),
    );
  }
}

// ==========================================
// PATIENT REGISTRY TABLE CARD
// ==========================================
class _PatientRegistryCard extends StatelessWidget {
  final Function(Map<String, String>) onOpenDetails;

  const _PatientRegistryCard({required this.onOpenDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text(
                    'Patient Registry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(width: 8),
                  Chip(
                    label: Text(
                      '8,421 TOTAL',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                    backgroundColor: Color(0xFFF1F5F9),
                  ),
                ],
              ),
              SizedBox(
                width: 220,
                height: 38,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, owner, or ID...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.8),
              3: FlexColumnWidth(1.8),
              4: FlexColumnWidth(1.2),
              5: FlexColumnWidth(1.0),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(
                children: [
                  _TableHeader('ID NUMBER'),
                  _TableHeader('PET NAME'),
                  _TableHeader('OWNER\'S NAME'),
                  _TableHeader('BREED'),
                  _TableHeader('STATUS'),
                  _TableHeader('ACTIONS'),
                ],
              ),
              _row(
                '#FF-8842',
                'Luna',
                'Sarah Jenkins',
                'Golden Retriever',
                'STABLE',
                const Color(0xFFD1FAE5),
                const Color(0xFF10B981),
              ),
              _row(
                '#FF-9120',
                'Milo',
                'David Chen',
                'Siamese Cat',
                'URGENT',
                const Color(0xFFFEE2E2),
                const Color(0xFFEF4444),
              ),
              _row(
                '#FF-7721',
                'Bella',
                'Marcus Thorne',
                'French Bulldog',
                'RECOVERED',
                const Color(0xFFDCFCE7),
                const Color(0xFF166534),
              ),
              _row(
                '#FF-1045',
                'Cooper',
                'Alice Rodriguez',
                'Beagle',
                'OBSERVATION',
                const Color(0xFFFEF3C7),
                const Color(0xFFF59E0B),
              ),
              _row(
                '#FF-2289',
                'Simba',
                'Elena Gilbert',
                'Maine Coon Cat',
                'STABLE',
                const Color(0xFFD1FAE5),
                const Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Pagination Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Showing 1 to 5 of 8,421 pets',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                    onPressed: () {},
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '2',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '3',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF0F172A),
                      size: 18,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _row(
    String id,
    String petName,
    String owner,
    String breed,
    String status,
    Color bg,
    Color fg,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            id,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),
        ),
        Text(
          petName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          owner,
          style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
        ),
        Text(
          breed,
          style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: fg,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () => onOpenDetails({
            'id': id,
            'name': petName,
            'owner': owner,
            'breed': breed,
            'status': status,
          }),
          child: const Text(
            'Details',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// NEW PATIENT INTAKE DIALOG MODAL
// ==========================================
class NewPatientIntakeDialog extends StatefulWidget {
  const NewPatientIntakeDialog({super.key});

  @override
  State<NewPatientIntakeDialog> createState() => _NewPatientIntakeDialogState();
}

class _NewPatientIntakeDialogState extends State<NewPatientIntakeDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  String? _selectedPatientId;
  String? _selectedPatientName;
  String _selectedVet = 'Dr. Aris Kensington';
  final TextEditingController _bayLocationController = TextEditingController();

  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _respRateController = TextEditingController();
  final TextEditingController _admissionReasonController =
      TextEditingController();

  String _selectedStatus = 'STABLE';

  final List<Map<String, String>> _patientDatabase = [
    {
      'id': '#FF-8842',
      'name': 'Luna',
      'breed': 'Golden Retriever',
      'owner': 'Sarah Jenkins',
    },
    {
      'id': '#FF-9120',
      'name': 'Milo',
      'breed': 'Siamese Cat',
      'owner': 'David Chen',
    },
    {
      'id': '#FF-7721',
      'name': 'Bella',
      'breed': 'French Bulldog',
      'owner': 'Marcus Thorne',
    },
    {
      'id': '#FF-1045',
      'name': 'Cooper',
      'breed': 'Beagle',
      'owner': 'Alice Rodriguez',
    },
    {
      'id': '#FF-2289',
      'name': 'Simba',
      'breed': 'Maine Coon Cat',
      'owner': 'Elena Gilbert',
    },
  ];

  final List<String> _vetList = [
    'Dr. Aris Kensington',
    'Dr. Sarah Smith',
    'Dr. James Wilson',
    'Dr. Elena Rostova',
  ];

  void _submitIntakeForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      await Future.delayed(const Duration(milliseconds: 600));

      final payload = {
        'patient_id': _selectedPatientId,
        'patient_name': _selectedPatientName,
        'attending_vet': _selectedVet,
        'location_bay': _bayLocationController.text.trim().isEmpty
            ? 'General Monitoring'
            : _bayLocationController.text.trim(),
        'vitals': {
          'temperature_c': double.tryParse(_tempController.text) ?? 38.5,
          'weight_kg': double.tryParse(_weightController.text) ?? 0.0,
          'heart_rate_bpm': int.tryParse(_heartRateController.text) ?? 80,
          'respiratory_rate_rpm': int.tryParse(_respRateController.text) ?? 20,
        },
        'chief_complaint': _admissionReasonController.text.trim(),
        'health_status': _selectedStatus,
        'admitted_at': DateTime.now().toIso8601String(),
      };

      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.pop(context, payload);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'New Patient Intake',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Admit a patient to active health monitoring and log baseline vitals.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: Color(0xFF94A3B8),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFE2E8F0), height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(
                        Icons.assignment_ind_outlined,
                        '1. Patient & Location Assignment',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Select Patient*',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Autocomplete<Map<String, String>>(
                        displayStringForOption: (option) =>
                            "${option['name']} - ${option['id']} (${option['breed']})",
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _patientDatabase;
                          }
                          return _patientDatabase.where((patient) {
                            final q = textEditingValue.text.toLowerCase();
                            return patient['name']!.toLowerCase().contains(q) ||
                                patient['id']!.toLowerCase().contains(q);
                          });
                        },
                        onSelected: (Map<String, String> selection) {
                          setState(() {
                            _selectedPatientId = selection['id'];
                            _selectedPatientName = selection['name'];
                          });
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                style: const TextStyle(fontSize: 12),
                                decoration: _inputDecoration(
                                  hint:
                                      'Search patient by Name or ID (e.g. Luna - #FF-8842)',
                                ),
                                validator: (value) {
                                  if (_selectedPatientId == null ||
                                      value == null ||
                                      value.isEmpty) {
                                    return 'Please select a valid patient from the database';
                                  }
                                  return null;
                                },
                              );
                            },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Attending Veterinarian*',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: _selectedVet,
                                  decoration: _inputDecoration(),
                                  items: _vetList
                                      .map(
                                        (vet) => DropdownMenuItem(
                                          value: vet,
                                          child: Text(
                                            vet,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedVet = val!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cage / Kennel / Bay (Optional)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _bayLocationController,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: _inputDecoration(
                                    hint: 'e.g., Recovery Bay A2',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionHeader(
                        Icons.monitor_heart_outlined,
                        '2. Baseline Vitals & Chief Complaint',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildNumberField(
                              _tempController,
                              'Temperature (°C)',
                              'e.g., 38.5',
                              isDecimal: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildNumberField(
                              _weightController,
                              'Body Weight (kg)*',
                              'e.g., 14.2',
                              isDecimal: true,
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildNumberField(
                              _heartRateController,
                              'Heart Rate (BPM)',
                              'e.g., 110',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildNumberField(
                              _respRateController,
                              'Respiratory Rate (RPM)',
                              'e.g., 24',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Primary Reason for Admission / Chief Complaint*',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _admissionReasonController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 12),
                        decoration: _inputDecoration(
                          hint:
                              'Describe clinical observations, symptoms, or surgery details...',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty)
                            return 'Primary reason for admission is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _sectionHeader(
                        Icons.healing_outlined,
                        '3. Initial Urgency Status',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _statusChip(
                            'STABLE',
                            const Color(0xFF10B981),
                            const Color(0xFFD1FAE5),
                          ),
                          const SizedBox(width: 8),
                          _statusChip(
                            'OBSERVATION',
                            const Color(0xFFF59E0B),
                            const Color(0xFFFEF3C7),
                          ),
                          const SizedBox(width: 8),
                          _statusChip(
                            'URGENT',
                            const Color(0xFFEF4444),
                            const Color(0xFFFEE2E2),
                          ),
                          const SizedBox(width: 8),
                          _statusChip(
                            'CRITICAL',
                            const Color(0xFFB91C1C),
                            const Color(0xFFFEE2E2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitIntakeForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E2235),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Confirm Intake & Start Monitoring',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF312E81)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF312E81),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isDecimal = false,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
          style: const TextStyle(fontSize: 12),
          decoration: _inputDecoration(hint: hint),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) return 'Required';
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _statusChip(String label, Color textColor, Color bgColor) {
    final bool isSelected = _selectedStatus == label;
    return InkWell(
      onTap: () => setState(() => _selectedStatus = label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? textColor : bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? textColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String hint = ''}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0F172A)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}

// ==========================================
// CLINIC STATUS CARD (RIGHT SIDEBAR)
// ==========================================
class _ClinicStatusCard extends StatelessWidget {
  const _ClinicStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clinic Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You are currently viewing the comprehensive monitoring registry. Use the global search to find specific patients or owners.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Occupancy',
                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              Text(
                '88%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.88,
              minHeight: 6,
              backgroundColor: Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Staff on Duty',
                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              Text(
                '14',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// RECENT ACTIVITY CARD (RIGHT SIDEBAR)
// ==========================================
class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'CLEAR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _activityItem(
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFF166534),
            iconBg: const Color(0xFFDCFCE7),
            title: 'New intake: "Luna" (Golden Retriever)',
            time: '2 minutes ago',
          ),
          const SizedBox(height: 12),
          _activityItem(
            icon: Icons.sync,
            iconColor: const Color(0xFF0284C7),
            iconBg: const Color(0xFFE0F2FE),
            title: 'Vitals updated for "Cooper"',
            time: '15 minutes ago',
          ),
          const SizedBox(height: 12),
          _activityItem(
            icon: Icons.error_outline,
            iconColor: const Color(0xFFDC2626),
            iconBg: const Color(0xFFFEF2F2),
            title: 'Emergency alert: "Milo" (Critical)',
            time: '1 hour ago',
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'View All History',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.grid_view,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'Clinic Admin',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'ADMINISTRATOR',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(width: 12),
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
}

class _TableHeader extends StatelessWidget {
  final String label;
  const _TableHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
