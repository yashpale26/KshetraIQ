import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kshetraiq/theme/app_colors.dart';
import 'package:kshetraiq/screens/settings_screen.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const LinearGradient _bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFA2E1BA),
      Color(0xFFFCF3CF),
      Color(0xFFEADBC8),
    ],
  );

  Future<void> _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (route) => false,
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: AppColors.burntUmber),
              SizedBox(width: 8),
              Text(
                'Logout?',
                style: TextStyle(
                  color: AppColors.forestGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from KshetraIQ?\n\nYour saved farm data and analysis history remain stored in your account.',
            style: TextStyle(
              color: AppColors.burntUmber,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.burntUmber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _handleLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: const BoxDecoration(gradient: _bgGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   title: const Text(
        //     'Profile',
        //     style: TextStyle(
        //       color: AppColors.forestGreen,
        //       fontWeight: FontWeight.bold,
        //       fontSize: 22,
        //     ),
        //   ),
        // ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: currentUser != null
              ? FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots()
              : null,
          builder: (context, snapshot) {
            String name = currentUser?.displayName ?? '';
            String email = currentUser?.email ?? 'No email provided';

            if (snapshot.hasData && snapshot.data!.data() != null) {
              final userData = snapshot.data!.data()!;
              if (userData['name'] != null && (userData['name'] as String).isNotEmpty) {
                name = userData['name'];
              }
            }

            if (name.isEmpty) {
              name = email.contains('@') ? email.split('@').first : 'User';
            }

            final avatarInitial = name.isNotEmpty ? name[0].toUpperCase() : '👤';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // AVATAR
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: AppColors.forestGreen,
                    child: Text(
                      avatarInitial,
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // NAME
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.burntUmber,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // EMAIL
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.burntUmber.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // MENU OPTIONS
                  // _buildOptionCard(
                  //   icon: Icons.settings_rounded,
                  //   title: 'Settings',
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  //     );
                  //   },
                  // ),
                  //
                  // const SizedBox(height: 14),

                  _buildOptionCard(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sageBorder.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.forestGreen),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.burntUmber,
            fontSize: 15,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppColors.burntUmber,
        ),
      ),
    );
  }
}