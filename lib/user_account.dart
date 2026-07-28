import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sidebar.dart';
import 'services/firestore_service.dart';

class UserAccountScreen extends StatefulWidget {
  const UserAccountScreen({super.key});

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // State Variable para sa Sorting Filter
  String _sortOption =
      'newest'; // Options: 'newest', 'oldest', 'id_asc', 'id_desc'

  // 1. Open "Add New Pet Owner" Dialog
  Future<void> _openAddOwnerModal(int currentCount) async {
    final String nextGeneratedId =
        'OWN-${(currentCount + 1).toString().padLeft(5, '0')}';

    final newOwnerData = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddNewOwnerDialog(generatedId: nextGeneratedId),
    );

    if (newOwnerData != null && mounted) {
      try {
        await _firestoreService.addPetOwner(
          ownerId: newOwnerData['id'],
          fullName: newOwnerData['ownerName'],
          phone: newOwnerData['phone'],
          address: newOwnerData['address'],
          password: newOwnerData['password'],
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Successfully registered ${newOwnerData['ownerName']}!'),
              backgroundColor: const Color(0xFF166534),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error saving owner: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // 2. Open "View Linked Pets" Dialog (Eye Icon)
  void _openViewPetsModal(String ownerDocId, String ownerId, String ownerName) {
    showDialog(
      context: context,
      builder: (context) => ViewPetsDialog(
        ownerDocId: ownerDocId,
        ownerId: ownerId,
        ownerName: ownerName,
      ),
    );
  }

  // 3. Open "Edit Owner" Dialog (Pencil Icon)
  Future<void> _openEditOwnerModal(
      String docId, Map<String, dynamic> currentData) async {
    final updatedData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditOwnerDialog(
        docId: docId,
        currentData: currentData,
      ),
    );

    if (updatedData != null && mounted) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(docId).update({
          'fullName': updatedData['fullName'],
          'phone': updatedData['phone'],
          'address': updatedData['address'],
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User details updated successfully!'),
              backgroundColor: Color(0xFF166534),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error updating user: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          const SidebarMenu(activeRoute: 'user_account'),
          Expanded(
            child: Column(
              children: [
                const _TopHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestoreService.getPetOwners(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        List<QueryDocumentSnapshot> docs =
                            List.from(snapshot.data?.docs ?? []);

                        // Sorting Logic
                        docs.sort((a, b) {
                          final dataA = a.data() as Map<String, dynamic>;
                          final dataB = b.data() as Map<String, dynamic>;

                          final String idA = dataA['ownerID'] ??
                              dataA['ownerId'] ??
                              'OWN-00000';
                          final String idB = dataB['ownerID'] ??
                              dataB['ownerId'] ??
                              'OWN-00000';

                          final Timestamp? timeA =
                              dataA['createdAt'] as Timestamp?;
                          final Timestamp? timeB =
                              dataB['createdAt'] as Timestamp?;

                          if (_sortOption == 'oldest') {
                            if (timeA != null && timeB != null)
                              return timeA.compareTo(timeB);
                            return idA.compareTo(idB);
                          } else if (_sortOption == 'id_asc') {
                            return idA.compareTo(idB);
                          } else if (_sortOption == 'id_desc') {
                            return idB.compareTo(idA);
                          } else {
                            if (timeA != null && timeB != null)
                              return timeB.compareTo(timeA);
                            return idB.compareTo(idA);
                          }
                        });

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Title & ADD Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Hello, Admin!',
                                      style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A)),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Manage user accounts and pet owner records.',
                                      style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _openAddOwnerModal(docs.length),
                                  icon: const Icon(Icons.add,
                                      size: 18, color: Colors.white),
                                  label: const Text('ADD',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 18),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Top Stat Cards
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('pets')
                                  .snapshots(),
                              builder: (context, petSnapshot) {
                                final totalPets =
                                    petSnapshot.data?.docs.length ?? 0;

                                return Row(
                                  children: [
                                    _buildStatCard('Total Users',
                                        '${docs.length}', Icons.people_outline),
                                    const SizedBox(width: 20),
                                    _buildStatCard('Active Pets', '$totalPets',
                                        Icons.pets_outlined),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 32),

                            // User Directory Card
                            _buildDirectoryCard(docs),
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

  // Stat Card Widget
  Widget _buildStatCard(String title, String count, IconData icon) {
    return Container(
      width: 320,
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
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF4F46E5), size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500)),
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

  // Directory Table Container
  Widget _buildDirectoryCard(List<QueryDocumentSnapshot> docs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('User Directory',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A))),
              Row(
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list,
                        size: 20, color: Color(0xFF64748B)),
                    tooltip: 'Filter & Sort Order',
                    onSelected: (value) {
                      setState(() {
                        _sortOption = value;
                      });
                    },
                    itemBuilder: (context) => [
                      CheckedPopupMenuItem(
                        value: 'newest',
                        checked: _sortOption == 'newest',
                        child: const Text('Newest First (Pinakabago)',
                            style: TextStyle(fontSize: 13)),
                      ),
                      CheckedPopupMenuItem(
                        value: 'oldest',
                        checked: _sortOption == 'oldest',
                        child: const Text('Oldest First (Pinakauna)',
                            style: TextStyle(fontSize: 13)),
                      ),
                      const PopupMenuDivider(),
                      CheckedPopupMenuItem(
                        value: 'id_asc',
                        checked: _sortOption == 'id_asc',
                        child: const Text('ID: Ascending (OWN-00001 → 00004)',
                            style: TextStyle(fontSize: 13)),
                      ),
                      CheckedPopupMenuItem(
                        value: 'id_desc',
                        checked: _sortOption == 'id_desc',
                        child: const Text('ID: Descending (OWN-00004 → 00001)',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.file_download_outlined,
                          size: 20, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2.5),
              2: FlexColumnWidth(1.8),
              3: FlexColumnWidth(2.2),
              4: FlexColumnWidth(1.0),
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
              for (var doc in docs) _buildUserRow(doc),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${docs.length} of ${docs.length} entries',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12)),
                    child: const Text('Previous',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12)),
                    child: const Text('Next',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildUserRow(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ownerDocId = doc.id;
    final displayId = data['ownerID'] ?? data['ownerId'] ?? 'OWN-00000';
    final name = data['fullName'] ?? 'N/A';
    final email = data['email'] ?? 'N/A';
    final phone = data['phone'] ?? 'N/A';
    final address = data['address'] ?? 'N/A';

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: Text(displayId,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 2),
            Text('$email • $phone',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          ],
        ),
        StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getPetsByOwnerDocId(ownerDocId),
          builder: (context, petSnap) {
            final petCount = petSnap.data?.docs.length ?? 0;
            return Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => _openViewPetsModal(ownerDocId, displayId, name),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$petCount Pets Linked',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B)),
                  ),
                ),
              ),
            );
          },
        ),
        Text(address,
            style: const TextStyle(color: Color(0xFF475569), fontSize: 12)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye_outlined,
                  size: 18, color: Color(0xFF4F46E5)),
              onPressed: () => _openViewPetsModal(ownerDocId, displayId, name),
              tooltip: 'View Registered Pets',
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: Color(0xFF64748B)),
              onPressed: () => _openEditOwnerModal(ownerDocId, data),
              tooltip: 'Edit Owner Account',
            ),
          ],
        ),
      ],
    );
  }
}

// ==========================================
// VIEW PETS DIALOG MODAL (READ-ONLY)
// ==========================================
class ViewPetsDialog extends StatelessWidget {
  final String ownerDocId;
  final String ownerId;
  final String ownerName;

  const ViewPetsDialog({
    super.key,
    required this.ownerDocId,
    required this.ownerId,
    required this.ownerName,
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(28),
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
                    Text("Pets of $ownerName",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text("ID: $ownerId",
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      size: 20, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getPetsByOwnerDocId(ownerDocId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator()));
                }

                final petDocs = snapshot.data?.docs ?? [];

                if (petDocs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: const [
                        Icon(Icons.pets, size: 36, color: Color(0xFF94A3B8)),
                        SizedBox(height: 8),
                        Text("No pets registered yet for this owner.",
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    for (var doc in petDocs) ...[
                      Builder(builder: (context) {
                        final pet = doc.data() as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.pets,
                                        size: 18, color: Color(0xFF4F46E5)),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(pet['petName'] ?? 'N/A',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF0F172A))),
                                      Text(
                                          '${pet['species']} • ${pet['breed']} (${pet['gender']})',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B))),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: const Color(0xFFCBD5E1))),
                                child: Text(pet['petId'] ?? 'PET-000',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF475569))),
                              ),
                            ],
                          ),
                        );
                      }),
                    ]
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close',
                      style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// EDIT OWNER DIALOG MODAL (PENCIL BUTTON)
// ==========================================
class EditOwnerDialog extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> currentData;

  const EditOwnerDialog({
    super.key,
    required this.docId,
    required this.currentData,
  });

  @override
  State<EditOwnerDialog> createState() => _EditOwnerDialogState();
}

class _EditOwnerDialogState extends State<EditOwnerDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _fullNameController =
        TextEditingController(text: widget.currentData['fullName'] ?? '');
    _phoneController =
        TextEditingController(text: widget.currentData['phone'] ?? '');
    _addressController =
        TextEditingController(text: widget.currentData['address'] ?? '');
  }

  InputDecoration _customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "Edit Account: ${widget.currentData['ownerID'] ?? widget.currentData['ownerId'] ?? ''}",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A))),
                  IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _fullNameController,
                decoration: _customInputDecoration('Full Name*'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                decoration: _customInputDecoration('Contact Number*'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressController,
                decoration: _customInputDecoration('Complete Address*'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',
                          style: TextStyle(color: Color(0xFF64748B)))),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, {
                          'fullName': _fullNameController.text.trim(),
                          'phone': _phoneController.text.trim(),
                          'address': _addressController.text.trim(),
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Update Account',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// ADD NEW OWNER DIALOG MODAL
// ==========================================
class AddNewOwnerDialog extends StatefulWidget {
  final String generatedId;
  const AddNewOwnerDialog({super.key, required this.generatedId});

  @override
  State<AddNewOwnerDialog> createState() => _AddNewOwnerDialogState();
}

class _AddNewOwnerDialogState extends State<AddNewOwnerDialog> {
  final _formKey = GlobalKey<FormState>();
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

  InputDecoration _customInputDecoration({
    required String label,
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool readOnly = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: readOnly ? const Color(0xFFE2E8F0) : const Color(0xFFF8FAFC),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Add New Pet Owner',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 4),
                      Text(
                          'Enter client details to create a new pet owner record.',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close,
                        color: Color(0xFF64748B), size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _idController,
                readOnly: true,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155)),
                decoration: _customInputDecoration(
                  label: 'Owner ID Number',
                  hintText: 'OWN-00001',
                  readOnly: true,
                  prefixIcon: const Icon(Icons.badge_outlined,
                      size: 18, color: Color(0xFF64748B)),
                  suffixIcon: const Icon(Icons.lock_outline,
                      size: 18, color: Color(0xFF64748B)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                style: const TextStyle(fontSize: 13),
                decoration: _customInputDecoration(
                    label: 'Full Name*', hintText: 'e.g., Juan Dela Cruz'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter full name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNumController,
                style: const TextStyle(fontSize: 13),
                decoration: _customInputDecoration(
                    label: 'Contact Number*', hintText: 'e.g., 09171234567'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter contact number'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                style: const TextStyle(fontSize: 13),
                decoration: _customInputDecoration(
                    label: 'Complete Address*',
                    hintText: 'House No., Street, City, Province'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter address'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontSize: 13),
                decoration: _customInputDecoration(
                  label: 'Account Password*',
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: const Color(0xFF64748B)),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter password'
                    : null,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, {
                          'id': widget.generatedId,
                          'ownerName': _fullNameController.text.trim(),
                          'phone': _contactNumController.text.trim(),
                          'address': _addressController.text.trim(),
                          'password': _passwordController.text.trim(),
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Save Owner Record',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
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
          Expanded(
            child: Container(
              height: 40,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search clinic database...',
                  hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon:
                      Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
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
