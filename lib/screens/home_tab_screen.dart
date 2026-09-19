import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kshetraiq/theme/app_colors.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  static const LinearGradient _bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFA2E1BA),
      Color(0xFFFCF3CF),
      Color(0xFFEADBC8),
    ],
  );

  String? _selectedFarmId;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Container(
        decoration: const BoxDecoration(gradient: _bgGradient),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Text(
              'Please log in to view dashboard',
              style: TextStyle(color: AppColors.burntUmber, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(gradient: _bgGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
            builder: (context, userSnapshot) {
              String userName = currentUser.displayName ?? '';
              if (userSnapshot.hasData && userSnapshot.data!.data() != null) {
                final uData = userSnapshot.data!.data()!;
                final storedName = uData['name']?.toString().trim() ?? '';
                if (storedName.isNotEmpty) {
                  userName = storedName;
                }
              }
              if (userName.isEmpty && currentUser.email != null) {
                userName = currentUser.email!.split('@').first;
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('farms')
                    .where('userId', isEqualTo: currentUser.uid)
                    .snapshots(),
                builder: (context, farmsSnapshot) {
                  if (farmsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.forestGreen));
                  }

                  if (farmsSnapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading farms: ${farmsSnapshot.error}',
                        style: const TextStyle(color: AppColors.burntUmber),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final farms = farmsSnapshot.data?.docs ?? [];

                  if (_selectedFarmId == null && farms.isNotEmpty) {
                    _selectedFarmId = farms.first.id;
                  }

                  QueryDocumentSnapshot<Map<String, dynamic>>? selectedFarmDoc;
                  if (farms.isNotEmpty) {
                    final matches = farms.where((doc) => doc.id == _selectedFarmId).toList();
                    selectedFarmDoc = matches.isNotEmpty ? matches.first : farms.first;
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // GREETING HEADER (Notification Bell Permanently Removed)
                        Text(
                          'Good Morning, $userName',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.burntUmber,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Welcome to KshetraIQ',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.burntUmber.withOpacity(0.75),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 1. FARMS OVERVIEW
                        _buildSectionTitle('FARM OVERVIEW'),
                        const SizedBox(height: 10),
                        if (farms.isEmpty)
                          _buildEmptyCard('No farms added yet. Add a farm to view overview metrics.')
                        else
                          _buildFarmOverviewSection(farms, selectedFarmDoc!),

                        const SizedBox(height: 24),

                        // 2. AI ANALYSIS HISTORY
                        _buildSectionTitle('AI ANALYSIS HISTORY'),
                        const SizedBox(height: 10),
                        _buildAiAnalysisHistorySection(currentUser.uid),

                        const SizedBox(height: 24),

                        // 3. AI CHATBOT ANALYSIS HISTORY
                        _buildSectionTitle('AI CHATBOT HISTORY'),
                        const SizedBox(height: 10),
                        _buildChatbotHistorySection(currentUser.uid),

                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // --- 1. DYNAMIC FARM OVERVIEW ---
  Widget _buildFarmOverviewSection(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> farms,
      QueryDocumentSnapshot<Map<String, dynamic>> selectedFarmDoc,
      ) {
    final farmData = selectedFarmDoc.data();

    // Read the actual field names stored by FarmModel.toMap().
    final String farmName = farmData['farmName']?.toString().trim().isNotEmpty == true
        ? farmData['farmName'].toString()
        : 'Unnamed Farm';
    final String acres = farmData['farmArea']?.toString() ?? 'N/A';

    // The current farm model stores one field and one crop per farm document.
    final String fields = farmData['fieldName']?.toString().trim().isNotEmpty == true
        ? '1'
        : '0';
    final String crops = farmData['cropName']?.toString().trim().isNotEmpty == true
        ? '1'
        : '0';

    final String cropName = farmData['cropName']?.toString() ?? 'Not specified';
    final String cropStatus = farmData['cropHealth']?.toString() ?? 'N/A';
    final String soilPh = farmData['ph']?.toString() ?? 'N/A';
    final String soilMoisture = farmData['moisture']?.toString() ?? 'N/A';
    final String temp = farmData['temperature']?.toString() ?? 'N/A';
    final String humidity = farmData['humidity']?.toString() ?? 'N/A';
    final String envStatus = farmData['weatherCondition']?.toString() ?? 'N/A';
    final String waterReq = farmData['waterSource']?.toString() ?? 'N/A';

    return Column(
      children: [
        // SELECTOR & BASIC STATS CARD
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground.withOpacity(0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.sageBorder.withOpacity(0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '🌾 $farmName',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.burntUmber,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (farms.length > 1)
                    DropdownButton<String>(
                      value: selectedFarmDoc.id,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.forestGreen),
                      items: farms.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(
                            doc.data()['farmName']?.toString() ?? 'Farm',
                            style: const TextStyle(fontSize: 13, color: AppColors.burntUmber),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedFarmId = val);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$acres Acres • $fields Fields • $crops Crops',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.burntUmber.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // METRICS GRID
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildMetricTile('🌱', 'Crop', cropName, cropStatus),
            _buildMetricTile('🧪', 'Soil', 'pH: $soilPh', 'Moisture: $soilMoisture'),
            _buildMetricTile('🌦', 'Environment', '$temp • $humidity', envStatus),
            _buildMetricTile('💧', 'Water', 'Requirement', waterReq),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile(String icon, String title, String val1, String val2) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sageBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.burntUmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            val1,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.burntUmber,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            val2,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.burntUmber.withOpacity(0.75),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- 2. DYNAMIC AI ANALYSIS HISTORY (CLIENT-SIDE SORTED) ---
  Widget _buildAiAnalysisHistorySection(String userId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('ai_history')
          // .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.forestGreen));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyCard('No AI analysis history found.');
        }

        // Create a modifiable list copy for client-side sorting
        final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(snapshot.data!.docs);
        docs.sort((a, b) {
          final aTime = a.data()['timestamp'];
          final bTime = b.data()['timestamp'];
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }
          return 0; // Descending order (newest first)
        });

        final limitedDocs = docs.take(3).toList();

        return Column(
          children: limitedDocs.map((doc) {
            final data = doc.data();
            final title = data['title'] ?? data['cropName'] ?? 'Farm Analysis';
            final score = data['score']?.toString() ?? 'N/A';
            final status = data['status'] ?? data['summary'] ?? 'Completed';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground.withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.sageBorder.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: AppColors.forestGreen, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.burntUmber,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Score: $score | Status: $status',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.burntUmber.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // --- 3. DYNAMIC AI CHATBOT HISTORY (CLIENT-SIDE SORTED) ---
  Widget _buildChatbotHistorySection(String userId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('ai_chat_history')
          // .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.forestGreen));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyCard('No chatbot history found.');
        }

        // Create a modifiable list copy for client-side sorting
        final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(snapshot.data!.docs);
        docs.sort((a, b) {
          final aTime = a.data()['lastUpdated'];
          final bTime = b.data()['lastUpdated'];
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }
          return 0; // Descending order (newest first)
        });

        final limitedDocs = docs.take(3).toList();

        return Column(
          children: limitedDocs.map((doc) {
            final data = doc.data();
            final lastQuery = data['lastQuery'] ?? data['title'] ?? 'Agricultural Inquiry';
            final response = data['lastResponse'] ?? 'Tap to view discussion history';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground.withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.sageBorder.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.forestGreen, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lastQuery,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.burntUmber,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          response,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.burntUmber.withOpacity(0.75),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // --- UTILITY WIDGETS ---
  Widget _buildSectionTitle(String title) {
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

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sageBorder.withOpacity(0.4)),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.burntUmber.withOpacity(0.7),
        ),
      ),
    );
  }
}
