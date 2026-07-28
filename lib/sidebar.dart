import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'pet_management.dart';
import 'appointment_management.dart';
import 'notifications.dart';
import 'health_monitoring.dart';
import 'user_account.dart';
import 'veterinarian_directory.dart';
import 'doctor_dashboard.dart'; // Added Doctor Dashboard import

class SidebarMenu extends StatelessWidget {
  final String
      activeRoute; // 'dashboard', 'pet_management', 'appointment_management', 'notifications', 'health_monitoring', 'doctor_dashboard', etc.

  const SidebarMenu({super.key, required this.activeRoute});

  // 🔴 STATIC ROLE SWITCHER MODAL FUNCTION (Pwede ring tawagin mula sa Header)
  static void showRoleSwitcherModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swap_horiz, size: 36, color: Color(0xFF0F172A)),
              const SizedBox(height: 12),
              const Text('Switch Role / Portal',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A))),
              const SizedBox(height: 4),
              const Text('Select portal view to switch session:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 20),
              ListTile(
                tileColor: const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                leading: const Icon(Icons.admin_panel_settings_outlined,
                    color: Color(0xFF0F172A)),
                title: const Text('Admin & Staff Portal',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Clinic management & directory',
                    style: TextStyle(fontSize: 10)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminDashboardScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                tileColor: const Color(0xFFFEF3C7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                leading: const Icon(Icons.medical_services_outlined,
                    color: Color(0xFFB45309)),
                title: const Text('Doctor\'s Portal (Dr. Vance)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF78350F))),
                subtitle: const Text('Clinical dashboard & consultation',
                    style: TextStyle(fontSize: 10, color: Color(0xFF92400E))),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Color(0xFF78350F)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DoctorDashboardScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // Standardized exact width across all pages
      color: const Color(0xFF0F172A), // Dark Navy Blue
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pets, color: Colors.white, size: 22),
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
                    'ANIMAL CLINIC',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 1. Dashboard Link
          _buildNavItem(
            context,
            icon: Icons.grid_view_rounded,
            title: 'Dashboard',
            isActive: activeRoute == 'dashboard',
            onTap: () {
              if (activeRoute != 'dashboard') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, anim1, anim2) =>
                        const AdminDashboardScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              }
            },
          ),

          // 2. Pet Management Link
          _buildNavItem(
            context,
            icon: Icons.pets_outlined,
            title: 'Pet Management',
            isActive: activeRoute == 'pet_management',
            onTap: () {
              if (activeRoute != 'pet_management') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, anim1, anim2) =>
                        const PetManagementScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              }
            },
          ),

          // 3. Appointment Management Link
          _buildNavItem(
            context,
            icon: Icons.calendar_today_outlined,
            title: 'Appointment\nManagement',
            isActive: activeRoute == 'appointment_management',
            onTap: () {
              if (activeRoute != 'appointment_management') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, anim1, anim2) =>
                        const AppointmentManagementScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              }
            },
          ),

          // 4. Notifications Link
          _buildNavItem(
            context,
            icon: Icons.notifications_none_outlined,
            title: 'Notifications',
            isActive: activeRoute == 'notifications',
            onTap: () {
              if (activeRoute != 'notifications') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, anim1, anim2) =>
                        const NotificationsScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              }
            },
          ),

          // 5. Health Monitoring Link
          _buildNavItem(
            context,
            icon: Icons.favorite_border_outlined,
            title: 'Health Monitoring',
            isActive: activeRoute == 'health_monitoring',
            onTap: () {
              if (activeRoute != 'health_monitoring') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, anim1, anim2) =>
                        const HealthMonitoringScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              }
            },
          ),

          // User Account Placeholder
          _buildNavItem(
            context,
            icon: Icons.person_outline,
            title: 'User Account',
            isActive: activeRoute == 'user_account',
            onTap: () {
              if (activeRoute != 'user_account') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, anim1, anim2) =>
                        const UserAccountScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              }
            },
          ),

          // Veterinarians Directory
          _buildNavItem(
            context,
            icon: Icons.badge_outlined,
            title: 'Veterinarian Directory',
            isActive: activeRoute == 'veterinarian_directory',
            onTap: () {
              if (activeRoute != 'veterinarian_directory') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, anim1, anim2) =>
                        const VeterinarianDirectoryScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              }
            },
          ),

          // 🔴 NEW: Quick Switch / Doctor's Portal Access Link
          _buildNavItem(
            context,
            icon: Icons.medical_services_outlined,
            title: 'Doctor\'s Portal',
            isActive: activeRoute == 'doctor_dashboard',
            onTap: () => showRoleSwitcherModal(context),
          ),

          const Spacer(),

          // Bottom Items
          _buildNavItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Settings',
          ),
          _buildNavItem(
            context,
            icon: Icons.logout_outlined,
            title: 'Log Out',
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isActive = false,
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    final color = isDanger
        ? Colors.redAccent
        : (isActive ? Colors.white : const Color(0xFF94A3B8));

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
            fontSize: 13,
            height: 1.2,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
