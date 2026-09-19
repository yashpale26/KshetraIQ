import 'package:flutter/material.dart';
import 'package:kshetraiq/screens/ai_image_analysis_screen.dart';
import 'package:kshetraiq/screens/ai_history_screen.dart';
import 'package:kshetraiq/screens/select_farm_analysis_screen.dart';
import 'package:kshetraiq/screens/ai_chatbot_screen.dart';
import 'package:kshetraiq/screens/ai_chat_history_screen.dart';
import 'package:kshetraiq/theme/app_colors.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  static const LinearGradient _bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFA2E1BA),
      Color(0xFFFCF3CF),
      Color(0xFFEADBC8),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: _bgGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   title: const Text(
        //     '',
        //     style: TextStyle(
        //       color: AppColors.forestGreen,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        //   actions: [
        //     IconButton(
        //       icon: const Icon(
        //         Icons.history_rounded,
        //         color: AppColors.forestGreen,
        //         size: 28,
        //       ),
        //       onPressed: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => const AiHistoryScreen(),
        //           ),
        //         );
        //       },
        //     ),
        //   ],
        // ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.psychology_rounded,
                size: 72,
                color: AppColors.forestGreen,
              ),
              const SizedBox(height: 12),
              const Text(
                'AI Agricultural Assistant',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Get real-time insights, multi-crop suitability recommendations, visual disease detection, and interactive AI assistance.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.burntUmber.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 32),
              _buildOptionCard(
                context,
                title: 'Run Farm Analysis',
                subtitle:
                'Select a farm to analyze field, soil, and environment for scores & crop suitability.',
                icon: Icons.analytics_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectFarmAnalysisScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                title: 'AI Image Analysis',
                subtitle:
                'Capture plant leaves, soil, or field photos for instant visual diagnostic.',
                icon: Icons.camera_alt_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiImageAnalysisScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                title: 'AI Assistant Chatbot',
                subtitle:
                'Chat directly with KshetraIQ AI, ask farm questions, or discuss image analysis history.',
                icon: Icons.chat_bubble_outline_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiChatbotScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                title: 'Analysis History',
                subtitle:
                'Review previously generated visual and farm analysis reports.',
                icon: Icons.receipt_long_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiHistoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sageBorder.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.forestGreen, size: 28),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.forestGreen,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.burntUmber.withOpacity(0.8),
              ),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.softTerracotta,
            size: 18,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}