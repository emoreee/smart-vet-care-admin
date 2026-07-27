import 'package:flutter/material.dart';
import 'sidebar.dart';

class UserAccountScreen extends StatefulWidget {
  const UserAccountScreen({super.key});

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  // Directory Data List with 1-to-Many Pet Relationships
  final List<Map<String, dynamic>> _userDirectory = [
    {
      'id': 'OWN-00001',
      'ownerName': 'Junexenne Agravante',
      'email': 'admin@furryfriends.com',
      'phone': '+63 917 123 4567',
      'address': 'Quezon City, Metro Manila',
      'pets': ['Ming Ming (Aspin)', 'Choco (Poodle)'],
    },
    {
      'id': 'OWN-00002',
      'ownerName': 'Elena Rodriguez',
      'email': 'elena.rod@web.com',
      'phone': '+63 918 987 6543',
      'address': 'Pasig City, Metro Manila',
      'pets': ['Luna (Siberian Husky)'],
    },
    {
      'id': 'OWN-00003',
      'ownerName': 'Marcus Chen',
      'email': 'm.chen@petmail.org',
      'phone': '+63 920 333 4444',
      'address': 'Mandaluyong City, Metro Manila',
      'pets': ['Bubbles (Pug)', 'Milo (Persian Cat)', 'Leo (Golden Retriever)'],
    },
    {
      'id': 'OWN-00004',
      'ownerName': 'Sarah Jenkins',
      'email': 's.jenkins@fastmail.com',
      'phone': '+63 915 555 7788',
      'address': 'Makati City, Metro Manila',
      'pets': ['Oliver (Tabby Cat)'],
    },
  ];

  // Open "Add New Pet Owner" Modal Directly
  Future<void> _openAddOwnerModal(BuildContext context) async {
    final int nextIdNumber = _userDirectory.length + 1;
    final String nextGeneratedId =
        'OWN-${nextIdNumber.toString().padLeft(5, '0')}'; // e.g., "OWN-00005"

    final newOwnerData = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AddNewOwnerDialog(generatedId: nextGeneratedId);
      },
    );

    if (newOwnerData != null && mounted) {
      setState(() {
        _userDirectory.add(newOwnerData);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully added owner ${newOwnerData['ownerName']} (#${newOwnerData['id']})!',
          ),
          backgroundColor: const Color(0xFF166534),
        ),
      );
    }
  }

  // View Owner Details Modal
  void _showOwnerDetailsModal(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        final List<String> pets = List<String>.from(user['pets'] ?? []);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.account_circle_outlined,
                color: Color(0xFF312E81),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                user['ownerName'],
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
              _detailRow('Owner ID:', user['id']),
              _detailRow('Email Address:', user['email']),
              _detailRow('Contact Phone:', user['phone']),
              _detailRow('Residential Address:', user['address']),
              const SizedBox(height: 12),
              const Text(
                'Registered Pets:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 6),
              if (pets.isEmpty)
                const Text(
                  'No pets linked yet.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: pets
                      .map(
                        (p) => Chip(
                          label: Text(
                            p,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF312E81),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: const Color(0xFFEEF2FF),
                          side: const BorderSide(color: Color(0xFFC7D2FE)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                      .toList(),
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
                'Close',
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
              overflow: TextOverflow.ellipsis,
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
          // Sidebar Navigation Menu
          const SidebarMenu(activeRoute: 'user_account'),

          // Main Content Area
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
                        // Page Title Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Hello, Admin!',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Manage user accounts and pet owner records.',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _openAddOwnerModal(context),
                              icon: const Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'ADD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
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

                        // Metric Stat Cards Row
                        const _SummaryCardsRow(),
                        const SizedBox(height: 24),

                        // User Directory Table
                        _buildUserDirectoryCard(),
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

  // USER DIRECTORY TABLE CARD WITH UPDATED COLUMNS
  Widget _buildUserDirectoryCard() {
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
                'User Directory',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.filter_list,
                      color: Color(0xFF64748B),
                      size: 18,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.file_download_outlined,
                      color: Color(0xFF64748B),
                      size: 18,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // UPDATED TABLE COLUMNS & PROPORTIONS
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2), // ID NUMBER
              1: FlexColumnWidth(2.2), // OWNER DETAILS
              2: FlexColumnWidth(2.2), // REGISTERED PETS
              3: FlexColumnWidth(2.0), // ADDRESS
              4: FlexColumnWidth(1.0), // ACTIONS (Edit & Details)
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(
                children: [
                  _TableHeader('ID NUMBER'),
                  _TableHeader('OWNER DETAILS'),
                  _TableHeader('REGISTERED PETS'),
                  _TableHeader('ADDRESS'),
                  _TableHeader('ACTIONS'),
                ],
              ),
              for (var user in _userDirectory) _buildDirectoryRow(user),
            ],
          ),
          const SizedBox(height: 24),

          // Pagination Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${_userDirectory.length} of 1,284 entries',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(color: Color(0xFF0F172A), fontSize: 12),
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

  TableRow _buildDirectoryRow(Map<String, dynamic> user) {
    final List<String> pets = List<String>.from(user['pets'] ?? []);

    return TableRow(
      children: [
        // 1. ID NUMBER
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            user['id']!,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 2. OWNER DETAILS (Full Name + Email & Phone)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user['ownerName']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${user['email']} • ${user['phone']}',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        // 3. REGISTERED PETS (Badge Chips for 1-to-Many Relationship)
        Align(
          alignment: Alignment.centerLeft,
          child: pets.isEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '0 Pets Linked',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                  ),
                )
              : Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    // Main Badge Counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Text(
                        '${pets.length} ${pets.length == 1 ? "Pet" : "Pets"}',
                        style: const TextStyle(
                          color: Color(0xFF312E81),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Mini Pet Name Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        pets.first,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),

        // 4. ADDRESS
        Text(
          user['address']!,
          style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),

        // 5. ACTIONS (Edit ✏️ and View Details 👁️)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.visibility_outlined,
                color: Color(0xFF312E81),
                size: 18,
              ),
              tooltip: 'View Details',
              onPressed: () => _showOwnerDetailsModal(user),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF64748B),
                size: 18,
              ),
              tooltip: 'Edit Owner',
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

// ==========================================
// ADD NEW PET OWNER FORM DIALOG MODAL (REORDERED FIELDS)
// ==========================================
class AddNewOwnerDialog extends StatefulWidget {
  final String generatedId;

  const AddNewOwnerDialog({super.key, required this.generatedId});

  @override
  State<AddNewOwnerDialog> createState() => _AddNewOwnerDialogState();
}

class _AddNewOwnerDialogState extends State<AddNewOwnerDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _obscurePassword = true;

  late TextEditingController _idController;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _contactNumController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.generatedId);
  }

  void _saveOwnerRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      await Future.delayed(const Duration(milliseconds: 600));

      final name = _fullNameController.text.trim();
      final phone = _contactNumController.text.trim();
      final address = _addressController.text.trim();
      final password = _passwordController.text.trim();
      final emailHandle = name.toLowerCase().replaceAll(' ', '.');

      final newOwnerMap = {
        'id': widget.generatedId,
        'ownerName': name,
        'email': '$emailHandle@furryfriends.com',
        'phone': phone,
        'address': address,
        'password': password,
        'pets': <String>[],
      };

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context, newOwnerMap);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 520,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Add New Pet Owner',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Enter client details to create a new pet owner record.',
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

              // Form Body in Order: ID -> FULL NAME -> CONTACT NUMBER -> ADDRESS -> PASSWORD
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. PET OWNER ID
                      const Text(
                        'Pet Owner ID Number',
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
                        decoration: InputDecoration(
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. FULL NAME
                      const Text(
                        'Full Name*',
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
                          hint: 'e.g., Juan Dela Cruz',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // 3. CONTACT NUMBER
                      const Text(
                        'Contact Number*',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _contactNumController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 12),
                        decoration: _inputDecoration(hint: 'e.g., 09171234567'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Contact number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // 4. COMPLETE ADDRESS
                      const Text(
                        'Complete Address*',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 12),
                        decoration: _inputDecoration(
                          hint: 'House No., Street, City, Province',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Complete address is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // 5. ACCOUNT PASSWORD
                      const Text(
                        'Account Password*',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(fontSize: 12),
                        decoration: _inputDecoration(
                          hint: 'Enter account password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: const Color(0xFF94A3B8),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Password is required';
                          }
                          if (value.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
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
                    onPressed: _isSaving ? null : _saveOwnerRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E2235),
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
                            'Save Owner Record',
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

  InputDecoration _inputDecoration({String hint = '', Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
      suffixIcon: suffixIcon,
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
// SUMMARY METRIC CARDS
// ==========================================
class _SummaryCardsRow extends StatelessWidget {
  const _SummaryCardsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            icon: Icons.people_outline,
            label: 'Total Users',
            value: '1,284',
            iconBg: const Color(0xFFEEF2FF),
            iconColor: const Color(0xFF312E81),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _metricCard(
            icon: Icons.pets_outlined,
            label: 'Active Pets',
            value: '3,502',
            iconBg: const Color(0xFFEEF2FF),
            iconColor: const Color(0xFF312E81),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
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
                  children: const [
                    Text(
                      'Database Integrity',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '98.2% Optimized',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF0F172A),
                  child: const Text(
                    '+2k',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
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
          SizedBox(
            width: 320,
            height: 38,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search clinic database...',
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
              ),
            ),
          ),
          Row(
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
