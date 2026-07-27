import 'package:flutter/material.dart';
import 'sidebar.dart';

class VeterinarianDirectoryScreen extends StatefulWidget {
  const VeterinarianDirectoryScreen({super.key});

  @override
  State<VeterinarianDirectoryScreen> createState() =>
      _VeterinarianDirectoryScreenState();
}

class _VeterinarianDirectoryScreenState
    extends State<VeterinarianDirectoryScreen> {
  // Doctor Database State
  final List<Map<String, dynamic>> _vetDirectory = [
    {
      'id': '#DOC-0001',
      'name': 'Dr. Jonathan Reyes, DVM',
      'email': 'j.reyes@smartvet.com',
      'specialty': 'Veterinary Surgery',
      'prcLicense': 'PRC #12345678',
      'status': 'ON DUTY',
      'schedule': 'Mon, Wed, Fri (08:00 - 17:00)',
      'phone': '+63 917 111 2222',
      'avatarUrl': 'https://i.pravatar.cc/150?img=11',
    },
    {
      'id': '#DOC-0002',
      'name': 'Dr. Elena Santos, DVM',
      'email': 'e.santos@smartvet.com',
      'specialty': 'Internal Medicine',
      'prcLicense': 'PRC #23456789',
      'status': 'OFF DUTY',
      'schedule': 'Tue, Thu, Sat (09:00 - 18:00)',
      'phone': '+63 918 333 4444',
      'avatarUrl': 'https://i.pravatar.cc/150?img=32',
    },
    {
      'id': '#DOC-0003',
      'name': 'Dr. Robert Chen, DVM',
      'email': 'r.chen@smartvet.com',
      'specialty': 'Diagnostic Imaging',
      'prcLicense': 'PRC #34567890',
      'status': 'ON DUTY',
      'schedule': 'Daily (08:00 - 12:00)',
      'phone': '+63 920 555 6666',
      'avatarUrl': 'https://i.pravatar.cc/150?img=60',
    },
  ];

  // Open "Add New Doctor" Dialog
  Future<void> _openAddDoctorModal() async {
    final int nextNumber = _vetDirectory.length + 1;
    final String nextGeneratedId =
        '#DOC-${nextNumber.toString().padLeft(4, '0')}';

    final newDoctorData = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddNewDoctorDialog(generatedId: nextGeneratedId),
    );

    if (newDoctorData != null && mounted) {
      setState(() {
        _vetDirectory.add(newDoctorData);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully registered ${newDoctorData['name']} (${newDoctorData['id']})!',
          ),
          backgroundColor: const Color(0xFF166534),
        ),
      );
    }
  }

  // View Doctor Details Modal
  void _showDoctorDetailsModal(Map<String, dynamic> doc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFEEF2FF),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: Color(0xFF312E81),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                doc['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Doctor ID:', doc['id']),
              _detailRow('Email Address:', doc['email']),
              _detailRow('Specialization:', doc['specialty']),
              _detailRow('PRC License:', doc['prcLicense']),
              _detailRow('Duty Status:', doc['status']),
              _detailRow('Shift Schedule:', doc['schedule']),
              _detailRow('Contact Phone:', doc['phone'] ?? 'N/A'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
              ),
              child: const Text(
                'Close Details',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Navigation Sidebar
          const SidebarMenu(activeRoute: 'veterinarian_directory'),

          // Main Workspace Area
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
                        // Page Breadcrumb Tab
                        const Text(
                          'Veterinarians',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            decoration: TextDecoration.underline,
                            decorationThickness: 2,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title & Add New Doctor Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Veterinarian Directory',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Manage doctor accounts, specialization profiles, PRC licenses, and duty schedules.',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: _openAddDoctorModal,
                              icon: const Icon(
                                Icons.person_add_alt_1_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Add New Doctor',
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
                        const SizedBox(height: 24),

                        // Top Metric Cards Row (With 4px Colored Borders)
                        const _VetMetricCardsRow(),
                        const SizedBox(height: 24),

                        // Doctor Directory Table Card
                        _buildDoctorDirectoryCard(),
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

  // DOCTOR DIRECTORY TABLE CARD
  Widget _buildDoctorDirectoryCard() {
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
          // Table Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Doctor Directory',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.filter_list,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    label: const Text(
                      'Filter',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.file_download_outlined,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    label: const Text(
                      'Export',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data Table
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2), // ID NUMBER
              1: FlexColumnWidth(2.5), // DOCTOR DETAILS
              2: FlexColumnWidth(2.2), // SPECIALIZATION & LICENSE
              3: FlexColumnWidth(2.5), // STATUS / SHIFT
              4: FlexColumnWidth(0.8), // ACTIONS
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(
                children: [
                  _TableHeader('ID NUMBER'),
                  _TableHeader('DOCTOR DETAILS'),
                  _TableHeader('SPECIALIZATION & LICENSE'),
                  _TableHeader('STATUS / SHIFT'),
                  _TableHeader('ACTIONS'),
                ],
              ),
              for (var doc in _vetDirectory) _buildDoctorRow(doc),
            ],
          ),
          const SizedBox(height: 24),

          // Pagination Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing 1-${_vetDirectory.length} of 14 Veterinarians',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
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
                  _pageButton('1', isActive: true),
                  _pageButton('2'),
                  _pageButton('3'),
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

  Widget _pageButton(String text, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0F172A) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TableRow _buildDoctorRow(Map<String, dynamic> doc) {
    final bool isOnDuty = doc['status'] == 'ON DUTY';

    return TableRow(
      children: [
        // 1. ID NUMBER
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            doc['id']!,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 2. DOCTOR DETAILS (Avatar + Name & Email)
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE2E8F0),
              backgroundImage: NetworkImage(
                doc['avatarUrl'] ?? 'https://i.pravatar.cc/150',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    doc['email']!,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // 3. SPECIALIZATION & LICENSE
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doc['specialty']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              doc['prcLicense']!,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
          ],
        ),

        // 4. STATUS / SHIFT
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isOnDuty
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isOnDuty
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    doc['status']!,
                    style: TextStyle(
                      color: isOnDuty
                          ? const Color(0xFF047857)
                          : const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              doc['schedule']!,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
          ],
        ),

        // 5. ACTIONS
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.visibility_outlined,
                color: Color(0xFF475569),
                size: 18,
              ),
              tooltip: 'View Details',
              onPressed: () => _showDoctorDetailsModal(doc),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF475569),
                size: 18,
              ),
              tooltip: 'Edit Doctor',
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

// ==========================================
// METRIC CARDS ROW (WITH ACCENT BORDERS)
// ==========================================
class _VetMetricCardsRow extends StatelessWidget {
  const _VetMetricCardsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Total Veterinarians (Blue)
        Expanded(
          child: _metricCard(
            label: 'TOTAL VETERINARIANS',
            value: '14',
            icon: Icons.group_outlined,
            accentColor: const Color(0xFF3B82F6),
            iconBg: const Color(0xFFEFF6FF),
            iconFg: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 16),

        // 2. On Duty Today (Emerald Green)
        Expanded(
          child: _metricCard(
            label: 'ON DUTY TODAY',
            value: '08',
            icon: Icons.event_available_outlined,
            accentColor: const Color(0xFF10B981),
            iconBg: const Color(0xFFECFDF5),
            iconFg: const Color(0xFF059669),
          ),
        ),
        const SizedBox(width: 16),

        // 3. Active Consultations (Amber Orange)
        Expanded(
          child: _metricCard(
            label: 'ACTIVE CONSULTATIONS',
            value: '05',
            icon: Icons.medical_services_outlined,
            accentColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFFFBEB),
            iconFg: const Color(0xFFD97706),
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
    required Color iconBg,
    required Color iconFg,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: accentColor), // 4px Accent Line
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            value,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconFg, size: 20),
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
}

// ==========================================
// ADD NEW DOCTOR FORM DIALOG MODAL
// ==========================================
class AddNewDoctorDialog extends StatefulWidget {
  final String generatedId;

  const AddNewDoctorDialog({super.key, required this.generatedId});

  @override
  State<AddNewDoctorDialog> createState() => _AddNewDoctorDialogState();
}

class _AddNewDoctorDialogState extends State<AddNewDoctorDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _idController;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _prcLicenseController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _specialty = 'Veterinary Surgery';
  String _shiftSchedule = 'Mon, Wed, Fri (08:00 - 17:00)';
  String _dutyStatus = 'ON DUTY';

  final List<String> _specialties = [
    'Veterinary Surgery',
    'Internal Medicine',
    'Diagnostic Imaging',
    'Dermatology & Allergy',
    'Avian & Exotic Pet Care',
    'General Veterinary Care',
  ];

  final List<String> _shiftSchedules = [
    'Mon, Wed, Fri (08:00 - 17:00)',
    'Tue, Thu, Sat (09:00 - 18:00)',
    'Daily (08:00 - 12:00)',
    'Night Shift (18:00 - 02:00)',
  ];

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.generatedId);
  }

  void _saveDoctorRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      await Future.delayed(const Duration(milliseconds: 600));

      final newDocMap = {
        'id': widget.generatedId,
        'name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'specialty': _specialty,
        'prcLicense': 'PRC #${_prcLicenseController.text.trim()}',
        'status': _dutyStatus,
        'schedule': _shiftSchedule,
        'phone': _phoneController.text.trim(),
        'avatarUrl': 'https://i.pravatar.cc/150?img=12',
      };

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context, newDocMap);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 560,
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
                        'Add New Doctor',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Register a new veterinarian account, PRC license, and shift schedule.',
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
                      // Doctor ID
                      const Text(
                        'Doctor ID Number',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _idController,
                        readOnly: true,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                        decoration: _inputDecoration().copyWith(
                          filled: true,
                          fillColor: const Color(0xFFE2E8F0),
                          prefixIcon: const Icon(
                            Icons.badge_outlined,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                          suffixIcon: const Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Full Name
                      const Text(
                        'Full Name (e.g. Dr. Jonathan Reyes, DVM)*',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _fullNameController,
                        style: const TextStyle(fontSize: 12),
                        decoration: _inputDecoration(
                          hint: 'e.g., Dr. Juan Dela Cruz, DVM',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Full name is required'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // PRC License Number & Phone
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PRC License Number*',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _prcLicenseController,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: _inputDecoration(
                                    hint: 'e.g., 12345678',
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'PRC License is required'
                                      : null,
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
                                  'Contact Phone*',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: _inputDecoration(
                                    hint: 'e.g., +63 917 123 4567',
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Phone number is required'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Email Address
                      const Text(
                        'Clinic Email Address*',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(fontSize: 12),
                        decoration: _inputDecoration(
                          hint: 'e.g., j.reyes@smartvet.com',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Email is required'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Specialization Dropdown
                      const Text(
                        'Specialization Area*',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _specialty,
                        decoration: _inputDecoration(),
                        items: _specialties
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _specialty = val!),
                      ),
                      const SizedBox(height: 12),

                      // Shift Schedule Dropdown & Initial Duty Status
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Shift Schedule*',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: _shiftSchedule,
                                  decoration: _inputDecoration(),
                                  items: _shiftSchedules
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(
                                            e,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _shiftSchedule = val!),
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
                                  'Initial Duty Status*',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: _dutyStatus,
                                  decoration: _inputDecoration(),
                                  items: ['ON DUTY', 'OFF DUTY']
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(
                                            e,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _dutyStatus = val!),
                                ),
                              ],
                            ),
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
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveDoctorRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Doctor Profile',
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
    );
  }
}

// ==========================================
// TOP HEADER
// ==========================================
class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Global Doctor Search Input
          SizedBox(
            width: 380,
            height: 38,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search doctor by name, PRC license, or specialty...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF0F172A)),
                ),
              ),
            ),
          ),

          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.help_outline,
                  color: Color(0xFF64748B),
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
                        'Admin User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Clinic Manager',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=47',
                    ),
                  ),
                ],
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
