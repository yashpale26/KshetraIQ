import 'package:flutter/material.dart';
import 'package:kshetraiq/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const LinearGradient _bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFA2E1BA),
      Color(0xFFFCF3CF),
      Color(0xFFEADBC8),
    ],
  );

  bool _notificationsEnabled = true;
  String _appearance = 'System Default';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: _bgGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.forestGreen),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(
              color: AppColors.forestGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('GENERAL'),
              const SizedBox(height: 10),

              // NOTIFICATIONS SWITCH
              Container(
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.sageBorder.withOpacity(0.6)),
                ),
                child: SwitchListTile(
                  activeColor: AppColors.forestGreen,
                  secondary: const Icon(Icons.notifications_rounded, color: AppColors.forestGreen),
                  title: const Text(
                    'Notifications',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.burntUmber,
                      fontSize: 14,
                    ),
                  ),
                  value: _notificationsEnabled,
                  onChanged: (val) {
                    setState(() {
                      _notificationsEnabled = val;
                    });
                  },
                ),
              ),

              const SizedBox(height: 10),

              // APPEARANCE
              _buildSettingTile(
                icon: Icons.dark_mode_rounded,
                title: 'Appearance',
                subtitle: _appearance,
                onTap: () {
                  _showSelectionDialog(
                    title: 'Select Appearance',
                    options: ['System Default', 'Light Mode', 'Dark Mode'],
                    currentValue: _appearance,
                    onSelected: (val) => setState(() => _appearance = val),
                  );
                },
              ),

              const SizedBox(height: 10),

              // LANGUAGE
              _buildSettingTile(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: _language,
                onTap: () {
                  _showSelectionDialog(
                    title: 'Select Language',
                    options: ['English', 'Hindi', 'Marathi', 'Gujarati'],
                    currentValue: _language,
                    onSelected: (val) => setState(() => _language = val),
                  );
                },
              ),

              const SizedBox(height: 24),

              _buildSectionHeader('DATA'),
              const SizedBox(height: 10),

              // CLOUD DATA
              _buildSettingTile(
                icon: Icons.cloud_done_rounded,
                title: 'Cloud Data',
                subtitle: 'Firebase / Firestore Connected',
                onTap: null,
              ),

              const SizedBox(height: 24),

              _buildSectionHeader('ABOUT'),
              const SizedBox(height: 10),

              // ABOUT INFO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.sageBorder.withOpacity(0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KshetraIQ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.burntUmber.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Intelligent Agricultural Decision Support System',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.burntUmber.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.forestGreen,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sageBorder.withOpacity(0.6)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.forestGreen),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.burntUmber,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppColors.burntUmber.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.burntUmber)
            : null,
      ),
    );
  }

  void _showSelectionDialog({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryBackground,
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.forestGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return RadioListTile<String>(
                title: Text(option, style: const TextStyle(color: AppColors.burntUmber)),
                value: option,
                groupValue: currentValue,
                activeColor: AppColors.forestGreen,
                onChanged: (val) {
                  if (val != null) {
                    onSelected(val);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}