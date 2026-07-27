import 'package:flutter/material.dart';
import 'sidebar.dart';

class PetProfileScreen extends StatelessWidget {
  final String petName;
  final String petId;

  const PetProfileScreen({
    super.key,
    this.petName = 'Luna',
    this.petId = '#FF-8842',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Shared Sidebar Navigation
          const SidebarMenu(activeRoute: 'health_monitoring'),

          // Main Content
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
                        // Back Button & Navigation Path
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: Color(0xFF64748B),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text(
                              'Monitoring / Pet Search / ',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '$petName ($petId)',
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Main Grid Layout
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Section: Pet Card, Timeline, Vitals, Medical History
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  _buildPetHeaderCard(),
                                  const SizedBox(height: 20),
                                  const _MedicalTimelineCard(),
                                  const SizedBox(height: 20),
                                  const _VitalsTrendCard(),
                                  const SizedBox(height: 20),
                                  const _MedicalHistoryCard(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),

                            // Right Section: Quick Actions & Owner Contact (Matched Widths)
                            const SizedBox(
                              width: 300,
                              child: Column(
                                children: [
                                  _QuickActionsWidget(),
                                  SizedBox(height: 20),
                                  _OwnerDetailsWidget(),
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

  // PET HEADER CARD
  Widget _buildPetHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFFE2E8F0),
            child: Icon(Icons.pets, size: 36, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      petName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'STABLE',
                        style: TextStyle(
                          color: Color(0xFF0284C7),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Golden Retriever • Female • 3 yrs 2 mos',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoChip(label: 'ID: $petId'),
                    const SizedBox(width: 8),
                    const _InfoChip(label: 'Weight: 28.5 kg'),
                    const SizedBox(width: 8),
                    const _InfoChip(label: 'Blood: DEA 1.1'),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit, size: 14, color: Colors.white),
            label: const Text(
              'Edit Profile',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF475569),
          fontWeight: FontWeight.w500,
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
                    'Clinic Admin',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'ADMINISTRATOR',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
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
// MEDICAL TIMELINE CARD
// ==========================================
class _MedicalTimelineCard extends StatelessWidget {
  const _MedicalTimelineCard();

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
                'Recent Care Timeline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Add Entry',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            'Today, 09:30 AM',
            'Routine Checkup & Rabies Vaccination',
            'Dr. Aris • Vitals normal, weight stable.',
          ),
          _buildTimelineItem(
            'Oct 12, 2024',
            'Dental Cleaning & Calculus Removal',
            'Dr. Sarah • Mild gingivitis noted.',
          ),
          _buildTimelineItem(
            'Jun 04, 2024',
            'Ear Infection Treatment',
            'Dr. Aris • Prescribed Otomax drops for 7 days.',
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String date, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4, right: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF312E81),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
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
// VITALS TREND CARD (FIXED OVERFLOW ISSUE)
// ==========================================
class _VitalsTrendCard extends StatelessWidget {
  const _VitalsTrendCard();

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
            'Vitals History (Weight kg)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 150, // Height increased from 120 to 150 to fix overflow
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _BarChartColumn(label: 'Jan', height: 50, val: '26.2'),
                _BarChartColumn(label: 'Mar', height: 60, val: '27.0'),
                _BarChartColumn(label: 'Jun', height: 75, val: '28.1'),
                _BarChartColumn(label: 'Sep', height: 85, val: '28.5'),
                _BarChartColumn(
                  label: 'Today',
                  height: 85,
                  val: '28.5',
                  isHighlighted: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartColumn extends StatelessWidget {
  final String label;
  final double height;
  final String val;
  final bool isHighlighted;

  const _BarChartColumn({
    required this.label,
    required this.height,
    required this.val,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          val,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 28,
          height: height,
          decoration: BoxDecoration(
            color: isHighlighted
                ? const Color(0xFF312E81)
                : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

// ==========================================
// MEDICAL HISTORY TABLE CARD
// ==========================================
class _MedicalHistoryCard extends StatelessWidget {
  const _MedicalHistoryCard();

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
            'Medical History & Prescriptions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2.0),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.2),
            },
            children: [
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'DATE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'DIAGNOSIS / CONDITION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'PRESCRIPTION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'VET',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
              _buildHistoryRow(
                '2024-10-12',
                'Canine Ear Infection',
                'Otomax Drops',
                'Dr. Aris',
              ),
              _buildHistoryRow(
                '2024-05-18',
                'Annual Health Exam',
                'Heartworm Prev.',
                'Dr. Sarah',
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildHistoryRow(
    String date,
    String condition,
    String med,
    String vet,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            date,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ),
        Text(
          condition,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          med,
          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
        ),
        Text(
          vet,
          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
        ),
      ],
    );
  }
}

// ==========================================
// RIGHT SIDEBAR WIDGETS (UNIFIED FULL WIDTH)
// ==========================================
class _QuickActionsWidget extends StatelessWidget {
  const _QuickActionsWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensures full width inside parent
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
            'Quick Actions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          _btn(Icons.calendar_today, 'Schedule Appointment'),
          const SizedBox(height: 10),
          _btn(Icons.add_alert_outlined, 'Log Medical Alert'),
          const SizedBox(height: 10),
          _btn(Icons.print_outlined, 'Print Medical Record'),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, String label) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16, color: const Color(0xFF334155)),
        label: Text(
          label,
          style: const TextStyle(color: Color(0xFF334155), fontSize: 12),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _OwnerDetailsWidget extends StatelessWidget {
  const _OwnerDetailsWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensures exact match width with Quick Actions
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Owner Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Sarah Jenkins',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 4),
          Text(
            '+63 917 123 4567',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          SizedBox(height: 2),
          Text(
            'sarah.jenkins@email.com',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          SizedBox(height: 8),
          Text(
            'Quezon City, Metro Manila',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
