import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'pet_management.dart';
import 'sidebar.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Row(
        children: [
          // 1. Sidebar
          const SidebarMenu(activeRoute: 'dashboard'),

          // 2. Main Content Area
          Expanded(
            child: Column(
              children: [
                const DashboardHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Section
                        const Text(
                          'Clinic Overview',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Real-time status',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 20),

                        // Metric Cards Row
                        const MetricCardsRow(),
                        const SizedBox(height: 24),

                        // Main Workspace Row (Table + Demographics)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            // Left Side: Appointments Table
                            Expanded(flex: 2, child: AppointmentsCard()),
                            SizedBox(width: 20),
                            // Right Side: Demographics Chart
                            Expanded(flex: 1, child: DemographicsCard()),
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
}

// ==========================================
// SIDEBAR MENU WIDGET
// ==========================================

@override
Widget build(BuildContext context) {
  return Container(
    width: 240,
    color: const Color(0xFF0F172A),
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Logo & Branding
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.pets, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Furry Friends',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Animal Clinic',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Main Navigation Links
        _buildNavItem(Icons.grid_view_rounded, 'Dashboard', isActive: true),
        _buildNavItem(
          Icons.pets_outlined,
          'Pet Management',
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PetManagementScreen(),
              ),
            );
          },
        ),
        _buildNavItem(
          Icons.calendar_today_outlined,
          'Appointment Management',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Appointment Management is under development'),
              ),
            );
          },
        ),
        _buildNavItem(Icons.notifications_none_outlined, 'Notifications'),
        _buildNavItem(Icons.favorite_border_outlined, 'Health Monitoring'),
        _buildNavItem(Icons.person_outline, 'User Account'),

        const Spacer(),

        // Bottom Links
        _buildNavItem(Icons.settings_outlined, 'Settings'),
        _buildNavItem(Icons.logout_outlined, 'Log Out', isDanger: true),
      ],
    ),
  );
}

Widget _buildNavItem(
  IconData icon,
  String title, {
  bool isActive = false,
  bool isDanger = false,
  VoidCallback? onTap,
}) {
  final color = isDanger
      ? Colors.redAccent
      : (isActive ? Colors.white : Colors.grey[400]);

  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: isActive ? const Color(0xFF1E293B) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
    ),
    child: ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    ),
  );
}

// ==========================================
// TOP HEADER WIDGET
// ==========================================
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          // Search Input
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search patients, owners, or records',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),

          // Icons
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.apps, color: Colors.grey),
            onPressed: () {},
          ),
          const SizedBox(width: 12),

          // User Profile Block
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'Admin Profile',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    'Clinic Manager',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TOP METRIC CARDS ROW
// ==========================================
class MetricCardsRow extends StatelessWidget {
  const MetricCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            title: 'APPOINTMENTS TODAY',
            value: '24',
            subtext: '↑ +12% from yesterday',
            accentColor: Colors.green,
            textColor: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCard(
            title: 'IN-PATIENT',
            value: '08',
            subtext: '— Stable capacity',
            accentColor: Colors.blue,
            textColor: Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCard(
            title: 'URGENT CASES',
            value: '03',
            subtext: '✱ Requires immediate attention',
            accentColor: Colors.red,
            textColor: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required String subtext,
    required Color accentColor,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: accentColor, width: 4)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtext,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.w500,
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
// UPCOMING APPOINTMENTS CARD WITH TRIPLE DOTS
// ==========================================
class AppointmentsCard extends StatelessWidget {
  const AppointmentsCard({super.key});

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
              const Text(
                'Upcoming Appointments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.8),
              1: FlexColumnWidth(2.0),
              2: FlexColumnWidth(1.2),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(0.6),
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
              _buildAppointmentRow(
                context,
                'Cooper',
                'Beagle',
                'Vaccination Booster',
                '09:30 AM',
                'Confirmed',
                const Color(0xFFE0F2FE),
                const Color(0xFF0284C7),
              ),
              _buildAppointmentRow(
                context,
                'Luna',
                'Maine Coon',
                'Dental Cleaning',
                '10:15 AM',
                'In Progress',
                const Color(0xFFFEF3C7),
                const Color(0xFFD97706),
              ),
              _buildAppointmentRow(
                context,
                'Max',
                'French Bulldog',
                'Wellness Check',
                '11:00 AM',
                'Pending',
                const Color(0xFFF1F5F9),
                const Color(0xFF64748B),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showScheduleModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Schedule New Appointment',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildAppointmentRow(
    BuildContext context,
    String petName,
    String breed,
    String service,
    String time,
    String status,
    Color bg,
    Color fg,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                petName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                breed,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
            ],
          ),
        ),
        Text(
          service,
          style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
        ),
        Text(
          time,
          style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        _AppointmentActionsMenu(patientName: petName),
      ],
    );
  }
}

// ==========================================
// TRIPLE DOTS ACTION MENU WIDGET
// ==========================================
class _AppointmentActionsMenu extends StatelessWidget {
  final String patientName;

  const _AppointmentActionsMenu({required this.patientName});

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'update_status':
        _showUpdateStatusDialog(context);
        break;
      case 'view_details':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $patientName Medical Record...')),
        );
        break;
      case 'edit_appointment':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Editing appointment for $patientName...')),
        );
        break;
      case 'reschedule_cancel':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rescheduling/Cancelling appointment for $patientName...',
            ),
          ),
        );
        break;
      case 'send_reminder':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMS/Email Reminder sent to $patientName\'s owner!'),
            backgroundColor: const Color(0xFF166534),
          ),
        );
        break;
      case 'delete_record':
        _showDeleteConfirmationDialog(context);
        break;
    }
  }

  void _showUpdateStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Update Status: $patientName',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.hourglass_empty,
                  color: Colors.amber,
                  size: 18,
                ),
                title: const Text('Pending', style: TextStyle(fontSize: 12)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.blue,
                  size: 18,
                ),
                title: const Text('Confirmed', style: TextStyle(fontSize: 12)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.play_circle_outline,
                  color: Colors.orange,
                  size: 18,
                ),
                title: const Text(
                  'In Progress',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.task_alt,
                  color: Colors.green,
                  size: 18,
                ),
                title: const Text('Completed', style: TextStyle(fontSize: 12)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.red,
                  size: 18,
                ),
                title: const Text('Cancelled', style: TextStyle(fontSize: 12)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Delete Record',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete $patientName\'s appointment record? This action cannot be undone.',
            style: const TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Appointment record for $patientName deleted.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Color(0xFF64748B), size: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 4,
      onSelected: (String value) => _handleAction(context, value),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'update_status',
          child: Row(
            children: const [
              Icon(Icons.sync_alt, size: 16, color: Color(0xFF3B82F6)),
              SizedBox(width: 10),
              Text(
                'Update / Change Status',
                style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'view_details',
          child: Row(
            children: const [
              Icon(
                Icons.visibility_outlined,
                size: 16,
                color: Color(0xFF0F172A),
              ),
              SizedBox(width: 10),
              Text(
                'View Full Details / Medical Record',
                style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'edit_appointment',
          child: Row(
            children: const [
              Icon(Icons.edit_outlined, size: 16, color: Color(0xFF475569)),
              SizedBox(width: 10),
              Text(
                'Edit Appointment',
                style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'reschedule_cancel',
          child: Row(
            children: const [
              Icon(
                Icons.calendar_month_outlined,
                size: 16,
                color: Color(0xFFD97706),
              ),
              SizedBox(width: 10),
              Text(
                'Reschedule / Cancel',
                style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'send_reminder',
          child: Row(
            children: const [
              Icon(
                Icons.notifications_none_outlined,
                size: 16,
                color: Color(0xFF166534),
              ),
              SizedBox(width: 10),
              Text(
                'Send Reminder / Notification',
                style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'delete_record',
          child: Row(
            children: const [
              Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                'Delete Record',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// TABLE HEADER HELPER
// ==========================================
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

// ==========================================
// DEMOGRAPHICS DONUT CHART CARD
// ==========================================
class DemographicsCard extends StatelessWidget {
  const DemographicsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Patient's Demographics",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              Icon(Icons.info_outline, size: 18, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 24),

          // Donut Chart Container
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    startDegreeOffset: 270,
                    sections: [
                      PieChartSectionData(
                        color: Colors.black,
                        value: 65.2,
                        showTitle: false,
                        radius: 20,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFF7C8BA1),
                        value: 28.7,
                        showTitle: false,
                        radius: 20,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFFD9534F),
                        value: 6.1,
                        showTitle: false,
                        radius: 20,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '1,240',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Legend Section
          _buildLegendItem(Colors.black, 'Dogs', '65.2%'),
          const SizedBox(height: 8),
          _buildLegendItem(const Color(0xFF7C8BA1), 'Cats', '28.7%'),
          const SizedBox(height: 8),
          _buildLegendItem(const Color(0xFFD9534F), 'Others', '6.1%'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String percentage) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
        const Spacer(),
        Text(
          percentage,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ==========================================
// HELPER FUNCTION PARA SA DASHBOARD
// ==========================================
void _showScheduleModal(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return const _ScheduleAppointmentDialog();
    },
  );
}

// ==========================================
// COMPREHENSIVE SCHEDULE APPOINTMENT DIALOG
// ==========================================
class _ScheduleAppointmentDialog extends StatefulWidget {
  const _ScheduleAppointmentDialog();

  @override
  State<_ScheduleAppointmentDialog> createState() =>
      _ScheduleAppointmentDialogState();
}

class _ScheduleAppointmentDialogState
    extends State<_ScheduleAppointmentDialog> {
  // Section 1: Pet Owner
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Section 2: Pet Details
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _speciesBreedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _gender = 'Male';
  String _neuteredStatus = 'Not Neutered / Spayed';

  // Section 3: Visit Details
  String _selectedReason = 'Routine Check-up';
  final TextEditingController _symptomsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedTimeSlot = '9:00am - 10:30am';
  String _selectedVet = 'Any Available Veterinarian';

  // Section 4: Clinic Status
  String _patientStatus = 'New Patient';
  final TextEditingController _patientIdController = TextEditingController();

  final List<String> _timeSlots = [
    '9:00am - 10:30am',
    '11:00am - 12:30pm',
    '1:00pm - 2:30pm',
    '3:00pm - 4:30pm',
    '5:00pm - 6:30pm',
  ];

  final List<String> _visitReasons = [
    'Routine Check-up',
    'Routine Vaccination',
    'Deworming',
    'Grooming',
    'Consultation (Sick Pet)',
    'Surgery / Dental Procedure',
  ];

  final List<String> _veterinarians = [
    'Any Available Veterinarian',
    'Dr. Aris Kensington',
    'Dr. Sarah Smith',
    'Dr. James Wilson',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 580,
        // INAYOS: Ginamitan ng BoxConstraints para sa maxHeight
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Schedule Appointment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Fill in the complete details below for clinic intake.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
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

            // Form Fields in Scroll View
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ----------------------------------------------------
                    // 1. IMPORMASYON TUNGKOL SA PET OWNER
                    // ----------------------------------------------------
                    _buildSectionHeader(
                      Icons.person_outline,
                      '1. Impormasyon ng Pet Owner',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _ownerNameController,
                      'Buong Pangalan (Full Name)*',
                      'Juan Dela Cruz',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      _contactController,
                      'Contact Number*',
                      '09171234567',
                      isNumber: true,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      _addressController,
                      'Tirahan o Address (Opsyonal)',
                      'Quezon City, Metro Manila',
                    ),
                    const SizedBox(height: 20),

                    // ----------------------------------------------------
                    // 2. IMPORMASYON TUNGKOL SA ALAGANG HAYOP
                    // ----------------------------------------------------
                    _buildSectionHeader(Icons.pets, '2. Impormasyon ng Pet'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _petNameController,
                            'Pangalan ng Pet*',
                            'Mingming',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            _speciesBreedController,
                            'Uri & Lahi (Species/Breed)*',
                            'Dog / Golden Retriever',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _ageController,
                            'Edad / Date of Birth*',
                            '2 years old',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kasarian (Gender)*',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _gender,
                                decoration: _inputDecoration(),
                                items: ['Male', 'Female']
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
                                onChanged: (v) => setState(() => _gender = v!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Kapon Status (Neutered/Spayed)*',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _neuteredStatus,
                      decoration: _inputDecoration(),
                      items: ['Neutered / Spayed', 'Not Neutered / Spayed']
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
                      onChanged: (v) => setState(() => _neuteredStatus = v!),
                    ),
                    const SizedBox(height: 20),

                    // ----------------------------------------------------
                    // 3. DETALYE NG APPOINTMENT
                    // ----------------------------------------------------
                    _buildSectionHeader(
                      Icons.calendar_today_outlined,
                      '3. Detalye ng Appointment',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Dahilan ng Pagbisita (Reason for Visit)*',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedReason,
                      decoration: _inputDecoration(),
                      items: _visitReasons
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
                      onChanged: (v) => setState(() => _selectedReason = v!),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      _symptomsController,
                      'Maikling Paglalarawan ng Sintomas (kung may sakit)',
                      'Hal: Ayaw kumain, nagsusuka...',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Date Picker
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gusto mong Petsa*',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null)
                                    setState(() => _selectedDate = picked);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFCBD5E1),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color(0xFFF8FAFC),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${_selectedDate.toLocal()}".split(
                                          ' ',
                                        )[0],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const Icon(
                                        Icons.calendar_month,
                                        size: 16,
                                        color: Color(0xFF64748B),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Fixed Time Slot Dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Oras (Time Slot)*',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _selectedTimeSlot,
                                decoration: _inputDecoration(),
                                items: _timeSlots
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
                                onChanged: (v) =>
                                    setState(() => _selectedTimeSlot = v!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Preferred Veterinarian',
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
                      items: _veterinarians
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
                      onChanged: (v) => setState(() => _selectedVet = v!),
                    ),
                    const SizedBox(height: 20),

                    // ----------------------------------------------------
                    // 4. STATUS SA CLINIC (HISTORY)
                    // ----------------------------------------------------
                    _buildSectionHeader(Icons.history, '4. Status sa Clinic'),
                    const SizedBox(height: 12),
                    // INAYOS: Modern Radio Option Selectors (Inalis ang deprecated RadioListTile properties)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                setState(() => _patientStatus = 'New Patient'),
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: 'New Patient',
                                  groupValue: _patientStatus,
                                  onChanged: (v) =>
                                      setState(() => _patientStatus = v!),
                                ),
                                const Text(
                                  'New Patient',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(
                              () => _patientStatus = 'Existing Patient',
                            ),
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: 'Existing Patient',
                                  groupValue: _patientStatus,
                                  onChanged: (v) =>
                                      setState(() => _patientStatus = v!),
                                ),
                                const Text(
                                  'Existing Patient',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_patientStatus == 'Existing Patient') ...[
                      const SizedBox(height: 8),
                      _buildTextField(
                        _patientIdController,
                        'Patient ID Number / Old Chart #*',
                        'Hal: #FF-8842',
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 8),

            // Action Buttons
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
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Appointment booked for ${_petNameController.text.isEmpty ? "Pet" : _petNameController.text} on $_selectedTimeSlot!',
                        ),
                        backgroundColor: const Color(0xFF166534),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Confirm & Book Appointment',
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
    );
  }

  // Section Header Builder
  Widget _buildSectionHeader(IconData icon, String title) {
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

  // Text Field Builder
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
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
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
          style: const TextStyle(fontSize: 12),
          decoration: _inputDecoration(hint: hint),
        ),
      ],
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
