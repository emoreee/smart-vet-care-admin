import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'pet_profile.dart';

class AppointmentManagementScreen extends StatefulWidget {
  const AppointmentManagementScreen({super.key});

  @override
  State<AppointmentManagementScreen> createState() =>
      _AppointmentManagementScreenState();
}

class _AppointmentManagementScreenState
    extends State<AppointmentManagementScreen> {
  // Active Selected Tab State
  String _selectedTab = 'Pending Requests';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Shared Navigation Sidebar
          const SidebarMenu(activeRoute: 'appointment_management'),

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
                        const Text(
                          'Appointment Management',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Metric Cards Row
                        const _AppointmentMetricCards(),
                        const SizedBox(height: 24),

                        // Main Grid Layout
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: Table Card
                            Expanded(
                              flex: 3,
                              child: _buildAppointmentsTableCard(),
                            ),
                            const SizedBox(width: 24),

                            // Right Column: Mini Calendar & Daily Briefing
                            const SizedBox(
                              width: 320,
                              child: Column(
                                children: [
                                  _MiniCalendarCard(),
                                  SizedBox(height: 20),
                                  _DailyBriefingCard(),
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

  // TABLE CARD WITH REFINED LAYOUT & ALIGNMENTS
  Widget _buildAppointmentsTableCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header: Tabs & Quick Search Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildTabButton('Pending Requests'),
                  const SizedBox(width: 24),
                  _buildTabButton('Confirmed'),
                  const SizedBox(width: 24),
                  _buildTabButton('Completed'),
                ],
              ),
              SizedBox(
                width: 220,
                height: 38,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search appointments...',
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
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF0F172A)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFFE2E8F0), height: 24),

          // Distributed Table Grid Columns
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.0),
              1: FlexColumnWidth(2.2),
              2: FlexColumnWidth(2.0),
              3: FlexColumnWidth(2.2),
              4: FlexColumnWidth(1.8),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(
                children: [
                  _TableHeader('ID'),
                  _TableHeader('PET INFO'),
                  _TableHeader('OWNER'),
                  _TableHeader('DATE & TIME'),
                  _TableHeader('ACTIONS'),
                ],
              ),
              ..._getFilteredAppointmentRows(),
            ],
          ),
          const SizedBox(height: 24),

          // Footer Pagination Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${_getFilteredAppointmentRows().length} of 8 ${_selectedTab.toLowerCase()}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF94A3B8),
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF0F172A),
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

  // DYNAMIC TAB BUTTON
  Widget _buildTabButton(String label) {
    final bool isActive = _selectedTab == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
      },
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 2.5,
              color: isActive ? const Color(0xFF0F172A) : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  // DYNAMIC DATA TABLE ROWS DEPENDING ON SELECTED TAB
  List<TableRow> _getFilteredAppointmentRows() {
    if (_selectedTab == 'Pending Requests') {
      return [
        _buildAppointmentRow(
          '#00001',
          'Ming Ming',
          'Aspin',
          'Junexenne Agravante',
          'Today, 02:30 PM',
          'General Checkup',
          'Approve',
        ),
        _buildAppointmentRow(
          '#00002',
          'Ginger',
          'Tabby',
          'Ma. Theresa Santos',
          'Today, 04:15 PM',
          'Vaccination',
          'Approve',
        ),
        _buildAppointmentRow(
          '#00003',
          'Snowy',
          'Pomeranian',
          'Robert King',
          'Tomorrow, 09:00 AM',
          'Dental Cleaning',
          'Approve',
        ),
      ];
    } else if (_selectedTab == 'Confirmed') {
      return [
        _buildAppointmentRow(
          '#00004',
          'Cooper',
          'Beagle',
          'Sarah Jenkins',
          'Today, 10:00 AM',
          'Rabies Booster',
          'Start Session',
        ),
        _buildAppointmentRow(
          '#00005',
          'Luna',
          'Maine Coon',
          'Michael Chen',
          'Today, 01:30 PM',
          'Deworming',
          'Start Session',
        ),
        _buildAppointmentRow(
          '#00006',
          'Max',
          'French Bulldog',
          'Emily Rodriguez',
          'Tomorrow, 11:00 AM',
          'Wellness Exam',
          'Start Session',
        ),
      ];
    } else {
      return [
        _buildAppointmentRow(
          '#00007',
          'Bella',
          'Siamese Cat',
          'Marcus Thorne',
          'Yesterday, 03:00 PM',
          'Grooming',
          'View Summary',
        ),
        _buildAppointmentRow(
          '#00008',
          'Simba',
          'Golden Retriever',
          'Elena Gilbert',
          'Jul 25, 10:30 AM',
          'Ear Infection Surgery',
          'View Summary',
        ),
      ];
    }
  }

  TableRow _buildAppointmentRow(
    String id,
    String petName,
    String breed,
    String owner,
    String dateTime,
    String service,
    String actionBtnLabel,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            id,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ),
        Row(
          children: [
            const CircleAvatar(
              radius: 12,
              backgroundColor: Color(0xFFF1F5F9),
              child: Icon(Icons.pets, size: 12, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(width: 8),
            Expanded(
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
                    overflow: TextOverflow.ellipsis,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      breed,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(
          owner,
          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
          overflow: TextOverflow.ellipsis,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateTime,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              service,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Action executed: $actionBtnLabel for $petName',
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.check_circle_outline,
                size: 13,
                color: Colors.white,
              ),
              label: Text(
                actionBtnLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF312E81),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _AppointmentActionsMenu(
              petName: petName,
              petId: id,
              ownerName: owner,
              dateTime: dateTime,
              service: service,
            ),
          ],
        ),
      ],
    );
  }
}

// ==========================================
// PENDING APPOINTMENT ACTIONS MENU (TRIPLE DOTS)
// ==========================================
class _AppointmentActionsMenu extends StatelessWidget {
  final String petName;
  final String petId;
  final String ownerName;
  final String dateTime;
  final String service;

  const _AppointmentActionsMenu({
    required this.petName,
    required this.petId,
    required this.ownerName,
    required this.dateTime,
    required this.service,
  });

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'decline_request':
        _showDeclineModal(context);
        break;
      case 'reschedule_slot':
        _showRescheduleModal(context);
        break;
      case 'view_request_details':
        _showRequestDetailsModal(context);
        break;
      case 'view_patient_profile':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PetProfileScreen(petName: petName, petId: petId),
          ),
        );
        break;
      case 'contact_owner':
        _showContactOwnerModal(context);
        break;
    }
  }

  void _showDeclineModal(BuildContext context) {
    String selectedReason = 'Slot Fully Booked';
    final TextEditingController customNoteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                'Decline Appointment ($petName)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Reason for Declining*',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                    items:
                        [
                              'Slot Fully Booked',
                              'Doctor Unavailable',
                              'Clinic Closed on Requested Date',
                              'Invalid Patient Information',
                              'Other Reason',
                            ]
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
                    onChanged: (val) => setState(() => selectedReason = val!),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Additional Notes for Owner (SMS/Email)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: customNoteController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Type message to send to owner...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Request declined. Notification sent to $ownerName.',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text(
                    'Confirm Decline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRescheduleModal(BuildContext context) {
    DateTime newDate = DateTime.now();
    String newTimeSlot = '1:00pm - 2:30pm';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                'Reschedule Request ($petName)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'New Preferred Date*',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: newDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => newDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFF8FAFC),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${newDate.toLocal()}".split(' ')[0],
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
                  const SizedBox(height: 12),
                  const Text(
                    'New Time Slot*',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: newTimeSlot,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                    items:
                        [
                              '9:00am - 10:30am',
                              '11:00am - 12:30pm',
                              '1:00pm - 2:30pm',
                              '3:00pm - 4:30pm',
                              '5:00pm - 6:30pm',
                            ]
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
                    onChanged: (val) => setState(() => newTimeSlot = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Rescheduled $petName to $newTimeSlot. Confirmation offer sent to $ownerName.',
                        ),
                        backgroundColor: const Color(0xFF166534),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                  ),
                  child: const Text(
                    'Offer Reschedule',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRequestDetailsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: const [
              Icon(
                Icons.assignment_outlined,
                size: 20,
                color: Color(0xFF312E81),
              ),
              SizedBox(width: 8),
              Text(
                'Appointment Request Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Patient Name:', petName),
              _detailRow('Patient ID:', petId),
              _detailRow('Pet Owner:', ownerName),
              _detailRow('Requested Service:', service),
              _detailRow('Requested Date & Time:', dateTime),
              _detailRow('Contact Number:', '+63 917 123 4567'),
              const SizedBox(height: 10),
              const Text(
                'Client Request Notes:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '"Pet has mild lethargy and needs annual vaccination booster. Preferred morning schedule."',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF334155),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
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

  void _showContactOwnerModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Contact $ownerName',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.phone_outlined,
                  color: Color(0xFF166534),
                ),
                title: const Text(
                  'Call Mobile (+63 917 123 4567)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(
                  Icons.sms_outlined,
                  color: Color(0xFF3B82F6),
                ),
                title: const Text(
                  'Send SMS Reminder',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('SMS prompt triggered!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.mail_outline,
                  color: Color(0xFFD97706),
                ),
                title: const Text(
                  'Send Email Notification',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 4,
      onSelected: (String value) => _handleMenuAction(context, value),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'decline_request',
          child: Row(
            children: const [
              Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                'Decline / Reject Request',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'reschedule_slot',
          child: Row(
            children: const [
              Icon(
                Icons.edit_calendar_outlined,
                size: 16,
                color: Color(0xFFD97706),
              ),
              SizedBox(width: 10),
              Text(
                'Reschedule / Change Time Slot',
                style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'view_request_details',
          child: Row(
            children: const [
              Icon(
                Icons.visibility_outlined,
                size: 16,
                color: Color(0xFF0F172A),
              ),
              SizedBox(width: 10),
              Text(
                'View Request Details',
                style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'view_patient_profile',
          child: Row(
            children: const [
              Icon(
                Icons.account_box_outlined,
                size: 16,
                color: Color(0xFF3B82F6),
              ),
              SizedBox(width: 10),
              Text(
                'View Patient / Owner Profile',
                style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'contact_owner',
          child: Row(
            children: const [
              Icon(
                Icons.phone_in_talk_outlined,
                size: 16,
                color: Color(0xFF166534),
              ),
              SizedBox(width: 10),
              Text(
                'Contact Owner',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF166534),
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
// METRIC CARDS ROW (FLUTTER WEB STABLE)
// ==========================================
class _AppointmentMetricCards extends StatelessWidget {
  const _AppointmentMetricCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Pending Requests Card
        Expanded(
          child: _buildCard(
            icon: Icons.assignment_outlined,
            label: 'PENDING REQUESTS',
            value: '08',
            accentColor: const Color(0xFFF59E0B), // Amber
            iconBgColor: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
          ),
        ),
        const SizedBox(width: 16),

        // 2. Confirmed Today Card
        Expanded(
          child: _buildCard(
            icon: Icons.check_circle_outline,
            label: 'CONFIRMED TODAY',
            value: '14',
            accentColor: const Color(0xFF10B981), // Emerald Green
            iconBgColor: const Color(0xFFD1FAE5),
            iconColor: const Color(0xFF059669),
          ),
        ),
        const SizedBox(width: 16),

        // 3. Upcoming This Week Card
        Expanded(
          child: _buildCard(
            icon: Icons.calendar_month_outlined,
            label: 'UPCOMING THIS WEEK',
            value: '42',
            accentColor: const Color(0xFF3B82F6), // Blue
            iconBgColor: const Color(0xFFDBEAFE),
            iconColor: const Color(0xFF2563EB),
          ),
        ),
      ],
    );
  }

  // STABLE CARD BUILDER (NO RENDERING CRASH ON WEB)
  Widget _buildCard({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
    required Color iconBgColor,
    required Color iconColor,
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
              // 4px Left Color Accent Bar
              Container(width: 4, color: accentColor),

              // Card Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: iconColor, size: 22),
                      ),
                      const SizedBox(width: 16),

                      // Text Stack
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
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
                            const SizedBox(height: 2),
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
                    'Admin User',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Administrator',
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

// ==========================================
// RIGHT SIDEBAR WIDGETS
// ==========================================
class _MiniCalendarCard extends StatelessWidget {
  const _MiniCalendarCard();

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
            children: const [
              Text(
                'July 2024',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'View All',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _CalDay('M', '22'),
              _CalDay('T', '23'),
              _CalDay('W', '24', isSelected: true),
              _CalDay('T', '25'),
              _CalDay('F', '26'),
              _CalDay('S', '27'),
              _CalDay('S', '28'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: Color(0xFF312E81), width: 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Surgery Room A',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '02:00 PM - 03:30 PM',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalDay extends StatelessWidget {
  final String day;
  final String date;
  final bool isSelected;

  const _CalDay(this.day, this.date, {this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 4),
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF312E81) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              date,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyBriefingCard extends StatelessWidget {
  const _DailyBriefingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Briefing',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          _briefNote(
            'Ensure all vaccines are restocked before the 4:00 PM rush.',
          ),
          const SizedBox(height: 10),
          _briefNote('Dr. Smith is currently on break until 2:30 PM.'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF312E81),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'URGENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                'Updated 15 mins ago',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _briefNote(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
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
