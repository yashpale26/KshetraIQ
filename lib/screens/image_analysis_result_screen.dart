import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:kshetraiq/theme/app_colors.dart';

class ImageAnalysisResultScreen extends StatelessWidget {
  final Uint8List? imageBytes;
  final Map<String, dynamic> data;

  const ImageAnalysisResultScreen({
    super.key,
    this.imageBytes,
    required this.data,
  });

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
    final detectedSubject = data['detectedSubject'] ?? 'Agricultural Subject';
    final visualHealth = data['visualHealthAssessment'] ?? {};
    final symptoms = List<String>.from(data['observedSymptoms'] ?? []);
    final problem = data['possibleProblem'] ?? {};
    final factors = List<String>.from(data['contributingFactors'] ?? []);
    final risks = data['riskIndicators'] ?? {};
    final actions = List<String>.from(data['recommendedActions'] ?? []);
    final insight = data['kshetraIqInsight'] ?? '';

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
          title: const Text('Image Analysis', style: TextStyle(color: AppColors.forestGreen, fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DISPLAY CAPTURED IMAGE
              if (imageBytes != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.sageBorder),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(imageBytes!, fit: BoxFit.cover),
                  ),
                ),

              // DETECTED SUBJECT
              _buildSectionHeader('DETECTED SUBJECT'),
              Text('🍅 $detectedSubject', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.forestGreen)),
              const SizedBox(height: 16),

              // VISUAL HEALTH ASSESSMENT
              _buildSectionHeader('VISUAL HEALTH ASSESSMENT'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabelValue('Health Assessment', '${visualHealth['score'] ?? 0}%'),
                    const SizedBox(height: 6),
                    _buildProgressBar((visualHealth['score'] ?? 0) / 100),
                    const SizedBox(height: 8),
                    Text('Status: ${visualHealth['status'] ?? 'Attention Required'}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.burntUmber)),
                  ],
                ),
              ),

              // OBSERVED SYMPTOMS
              _buildSectionHeader('OBSERVED SYMPTOMS'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: symptoms.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text('• $s', style: const TextStyle(color: AppColors.burntUmber)),
                  )).toList(),
                ),
              ),

              // POSSIBLE PROBLEM
              _buildSectionHeader('POSSIBLE PROBLEM'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(problem['title'] ?? 'Potential Issue', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.burntUmber)),
                    const SizedBox(height: 8),
                    _buildLabelValue('Assessment Confidence', '${problem['confidence'] ?? 0}%'),
                    const SizedBox(height: 6),
                    _buildProgressBar((problem['confidence'] ?? 0) / 100, color: AppColors.softTerracotta),
                  ],
                ),
              ),

              // CONTRIBUTING FACTORS
              _buildSectionHeader('CONTRIBUTING FACTORS'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: factors.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text('• $f', style: const TextStyle(color: AppColors.burntUmber)),
                  )).toList(),
                ),
              ),

              // RISK INDICATORS
              _buildSectionHeader('RISK INDICATORS'),
              _buildCard(
                child: Column(
                  children: [
                    _buildKeyValueRow('🌱 Crop Risk', '${risks['cropRisk']}'),
                    _buildKeyValueRow('🧪 Nutrient Risk', '${risks['nutrientRisk']}'),
                    _buildKeyValueRow('🌦 Environment Risk', '${risks['environmentRisk']}'),
                  ],
                ),
              ),

              // RECOMMENDED ACTIONS
              _buildSectionHeader('RECOMMENDED ACTIONS'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: actions.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Text('${e.key + 1}. ${e.value}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.burntUmber)),
                  )).toList(),
                ),
              ),

              // KSHETRAIQ INSIGHT
              _buildSectionHeader('✨ KSHETRAIQ INSIGHT'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.sageBorder),
                ),
                child: Text(insight, style: const TextStyle(color: AppColors.burntUmber, height: 1.4)),
              ),

              const SizedBox(height: 20),
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.leafGreen, size: 18),
                    SizedBox(width: 6),
                    Text('Analysis saved ✓', style: TextStyle(color: AppColors.forestGreen, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sageBorder.withOpacity(0.5)),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.sageBorder, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(title, style: const TextStyle(color: AppColors.forestGreen, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
          ),
          const Expanded(child: Divider(color: AppColors.sageBorder, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildKeyValueRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(color: AppColors.burntUmber)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.forestGreen)),
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.burntUmber, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.forestGreen)),
      ],
    );
  }

  Widget _buildProgressBar(double progress, {Color color = AppColors.leafGreen}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor: AppColors.sageBorder.withOpacity(0.4),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}