import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kshetraiq/screens/farm_analysis_result_screen.dart';
import 'package:kshetraiq/screens/image_analysis_result_screen.dart';
import '../theme/app_colors.dart';


class AiHistoryScreen extends StatelessWidget {
  const AiHistoryScreen({super.key});

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.forestGreen),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Analysis History', style: TextStyle(color: AppColors.forestGreen, fontWeight: FontWeight.bold)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ALL ANALYSES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.forestGreen, letterSpacing: 1.1)),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('ai_history')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.forestGreen));
                    }

                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('No previous analyses found.', style: TextStyle(color: AppColors.burntUmber)),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data();
                        final type = data['type'] ?? 'FARM_ANALYSIS';
                        final title = data['title'] ?? 'Analysis';
                        final scoreText = data['scoreText'] ?? '';
                        final Timestamp? ts = data['timestamp'] as Timestamp?;
                        final dateStr = ts != null ? DateFormat('dd MMM yyyy').format(ts.toDate()) : 'Recently';
                        final resultData = Map<String, dynamic>.from(data['resultData'] ?? {});

                        final isFarm = type == 'FARM_ANALYSIS';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBackground.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.sageBorder.withOpacity(0.6)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Icon(
                              isFarm ? Icons.analytics_rounded : Icons.image_search_rounded,
                              color: AppColors.forestGreen,
                              size: 28,
                            ),
                            title: Row(
                              children: [
                                Text(
                                  isFarm ? '📊 FARM ANALYSIS' : '🖼 IMAGE ANALYSIS',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.forestGreen),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.burntUmber)),
                                  const SizedBox(height: 2),
                                  Text('$dateStr  •  $scoreText', style: TextStyle(fontSize: 12, color: AppColors.burntUmber.withOpacity(0.8))),
                                ],
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_rounded, color: AppColors.softTerracotta),
                            onTap: () {
                              if (isFarm) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FarmAnalysisResultScreen(
                                      farmName: title,
                                      data: resultData,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageAnalysisResultScreen(
                                      data: resultData,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}