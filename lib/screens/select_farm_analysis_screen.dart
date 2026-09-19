import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kshetraiq/screens/farm_analysis_result_screen.dart';
import 'package:kshetraiq/services/ai_service_open_router.dart';
import 'package:kshetraiq/theme/app_colors.dart';

class SelectFarmAnalysisScreen extends StatefulWidget {
  const SelectFarmAnalysisScreen({super.key});

  @override
  State<SelectFarmAnalysisScreen> createState() =>
      _SelectFarmAnalysisScreenState();
}

class _SelectFarmAnalysisScreenState extends State<SelectFarmAnalysisScreen> {
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
  Map<String, dynamic>? _selectedFarmData;
  bool _isAnalyzing = false;

  Future<void> _runAnalysis() async {
    if (_selectedFarmData == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final analysisResult =
      await AIService.analyzeFarmData(_selectedFarmData!);

      final farmName = _selectedFarmData!['farmName'] ?? 'Kshetra Farm';

      // Save analysis record to Firestore History
      await FirebaseFirestore.instance.collection('ai_history').add({
        'type': 'FARM_ANALYSIS',
        'title': farmName,
        'timestamp': FieldValue.serverTimestamp(),
        'scoreText':
        'Farm Score: ${analysisResult['farmIntelligenceScore']}/100',
        'resultData': analysisResult,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FarmAnalysisResultScreen(
              farmName: farmName,
              data: analysisResult,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

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
            'Select Farm for Analysis',
            style: TextStyle(
              color: AppColors.forestGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _isAnalyzing
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.forestGreen),
              SizedBox(height: 16),
              Text(
                'Analyzing Selected Farm Data with AI...',
                style: TextStyle(
                  color: AppColors.forestGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose a Farm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select which farm you would like KshetraIQ AI to analyze.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.burntUmber.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('farms')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.forestGreen,
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.agriculture_rounded,
                              size: 64,
                              color: AppColors.forestGreen,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No farms found.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.burntUmber,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please add a farm first in Farms Overview.',
                              style: TextStyle(
                                color: AppColors.burntUmber
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final farmData = doc.data();
                        farmData['id'] = doc.id;

                        final farmName =
                            farmData['farmName'] ?? 'Unnamed Farm';
                        final location =
                            farmData['location'] ?? 'Location not set';
                        final cropType =
                            farmData['cropType'] ?? 'Crop not specified';
                        final isSelected = _selectedFarmId == doc.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.forestGreen.withOpacity(0.12)
                                : AppColors.secondaryBackground
                                .withOpacity(0.85),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.forestGreen
                                  : AppColors.sageBorder.withOpacity(0.6),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.forestGreen
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.agriculture_rounded,
                                  color: AppColors.forestGreen,
                                  size: 26,
                                ),
                              ),
                              title: Text(
                                farmName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '📍 $location  •  🌱 $cropType',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.burntUmber
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ),
                              trailing: Radio<String>(
                                value: doc.id,
                                groupValue: _selectedFarmId,
                                activeColor: AppColors.forestGreen,
                                onChanged: (val) {
                                  setState(() {
                                    _selectedFarmId = val;
                                    _selectedFarmData = farmData;
                                  });
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedFarmId = doc.id;
                                  _selectedFarmData = farmData;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // ANALYZE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedFarmId != null
                        ? AppColors.softTerracotta
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                  _selectedFarmId != null ? _runAnalysis : null,
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  label: const Text(
                    '✨ Analyze This Farm',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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