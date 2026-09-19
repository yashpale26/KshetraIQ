import 'package:flutter/material.dart';
import 'package:kshetraiq/theme/app_colors.dart';

class FarmAnalysisResultScreen extends StatelessWidget {
  final String farmName;
  final Map<String, dynamic> data;

  const FarmAnalysisResultScreen({
    super.key,
    required this.farmName,
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
    final score = data['farmIntelligenceScore'] ?? 0;
    final overallCondition = data['overallCondition'] ?? 'Normal';
    final cropHealth = data['cropHealth'] ?? {};
    final problemAnalysis = data['cropProblemAnalysis'] ?? {};
    final soil = data['soilAnalysis'] ?? {};
    final irrigation = data['irrigationAdvisor'] ?? {};
    final env = data['environmentalAnalysis'] ?? {};
    final risks = data['riskIndicators'] ?? {};
    final actions = List<String>.from(data['recommendedActions'] ?? []);
    final cropRecommendations = List<Map<String, dynamic>>.from(data['cropRecommendations'] ?? []);

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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Farm Analysis', style: TextStyle(color: AppColors.forestGreen, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(farmName, style: const TextStyle(color: AppColors.burntUmber, fontSize: 13)),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SCORE CARD
              _buildScoreCard(score, overallCondition),
              const SizedBox(height: 20),

              // CROP HEALTH
              _buildSectionHeader('CROP HEALTH'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🍅 ${cropHealth['cropName'] ?? 'Crop'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.forestGreen)),
                    const SizedBox(height: 8),
                    _buildLabelValue('Health Score', '${cropHealth['healthScore'] ?? 0}%'),
                    const SizedBox(height: 6),
                    _buildProgressBar((cropHealth['healthScore'] ?? 0) / 100),
                    const SizedBox(height: 8),
                    Text('Status: ${cropHealth['status'] ?? 'Unknown'}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.burntUmber)),
                  ],
                ),
              ),

              // CROP PROBLEM ANALYSIS
              _buildSectionHeader('CROP PROBLEM ANALYSIS'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabelValue('Problem Risk', '${problemAnalysis['problemRisk'] ?? 0}%'),
                    const SizedBox(height: 6),
                    _buildProgressBar((problemAnalysis['problemRisk'] ?? 0) / 100, color: Colors.orangeAccent),
                    const SizedBox(height: 12),
                    const Text('Possible Factors:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.burntUmber)),
                    const SizedBox(height: 4),
                    ...List<Widget>.from((problemAnalysis['possibleFactors'] ?? []).map((f) => Text('• $f', style: const TextStyle(color: AppColors.burntUmber)))),
                  ],
                ),
              ),

              // SOIL ANALYSIS
              _buildSectionHeader('SOIL ANALYSIS'),
              _buildCard(
                child: Column(
                  children: [
                    _buildKeyValueRow('pH', '${soil['ph']}'),
                    _buildKeyValueRow('Moisture', '${soil['moisture']}'),
                    _buildKeyValueRow('Nitrogen', '${soil['nitrogen']}'),
                    _buildKeyValueRow('Phosphorus', '${soil['phosphorus']}'),
                    _buildKeyValueRow('Potassium', '${soil['potassium']}'),
                    const Divider(color: AppColors.sageBorder),
                    _buildKeyValueRow('Soil Suitability', '${soil['soilSuitability']}%', isBold: true),
                  ],
                ),
              ),

              // IRRIGATION ADVISOR
              _buildSectionHeader('IRRIGATION ADVISOR'),
              _buildCard(
                child: Column(
                  children: [
                    _buildKeyValueRow('Water Requirement', '${irrigation['waterRequirement']}'),
                    _buildKeyValueRow('Irrigation Priority', '${irrigation['irrigationPriority']}'),
                  ],
                ),
              ),

              // ENVIRONMENT ANALYSIS
              _buildSectionHeader('ENVIRONMENT ANALYSIS'),
              _buildCard(
                child: Column(
                  children: [
                    _buildKeyValueRow('Temperature', '${env['temperature']}'),
                    _buildKeyValueRow('Humidity', '${env['humidity']}'),
                    _buildKeyValueRow('Rainfall', '${env['rainfall']}'),
                    _buildKeyValueRow('Wind', '${env['wind']}'),
                    const Divider(color: AppColors.sageBorder),
                    _buildKeyValueRow('Environment Suitability', '${env['environmentSuitability']}%', isBold: true),
                  ],
                ),
              ),

              // RISK INDICATORS
              _buildSectionHeader('RISK INDICATORS'),
              _buildCard(
                child: Column(
                  children: [
                    _buildKeyValueRow('🌱 Crop Risk', '${risks['cropRisk']}'),
                    _buildKeyValueRow('🧪 Soil Risk', '${risks['soilRisk']}'),
                    _buildKeyValueRow('💧 Water Risk', '${risks['waterRisk']}'),
                    _buildKeyValueRow('🌦 Weather Risk', '${risks['weatherRisk']}'),
                  ],
                ),
              ),

              // RECOMMENDED ACTIONS
              _buildSectionHeader('RECOMMENDED ACTIONS'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: actions
                      .asMap()
                      .entries
                      .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text('${e.key + 1}. ${e.value}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.burntUmber)),
                  ))
                      .toList(),
                ),
              ),

              // CROP RECOMMENDATION
              _buildSectionHeader('CROP RECOMMENDATION'),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Based on your complete farm conditions', style: TextStyle(color: AppColors.burntUmber.withOpacity(0.8), fontSize: 13)),
              ),
              ...cropRecommendations.map((crop) => _buildCropRecommendationCard(crop)),

              // KSHETRAIQ RECOMMENDATION INSIGHT
              const SizedBox(height: 12),
              _buildSectionHeader('✨ KSHETRAIQ RECOMMENDATION'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.forestGreen.withOpacity(0.3)),
                ),
                child: Text(
                  data['kshetraIqRecommendation'] ?? 'Evaluation complete.',
                  style: const TextStyle(color: AppColors.forestGreen, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
                ),
              ),

              const SizedBox(height: 24),
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

  Widget _buildScoreCard(int score, String condition) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sageBorder),
      ),
      child: Column(
        children: [
          const Text('FARM INTELLIGENCE SCORE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: AppColors.burntUmber)),
          const SizedBox(height: 12),
          Text('$score / 100', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.forestGreen)),
          const SizedBox(height: 10),
          _buildProgressBar(score / 100, height: 12),
          const SizedBox(height: 12),
          Text('Overall Farm Condition: $condition', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.burntUmber)),
        ],
      ),
    );
  }

  Widget _buildCropRecommendationCard(Map<String, dynamic> crop) {
    final name = crop['cropName'] ?? '';
    final badge = crop['badge'] ?? '🌾';
    final suitability = crop['suitability'] ?? 0;
    final reasons = List<String>.from(crop['reasons'] ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sageBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$badge $name', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.forestGreen)),
            ],
          ),
          const SizedBox(height: 8),
          _buildLabelValue('Suitability / Success Potential', '$suitability%'),
          const SizedBox(height: 6),
          _buildProgressBar(suitability / 100),
          const SizedBox(height: 12),
          Text(suitability > 75 ? 'Suitable because:' : 'Suitable with conditions:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.burntUmber)),
          const SizedBox(height: 4),
          ...reasons.map((r) => Text('• $r', style: const TextStyle(fontSize: 13, color: AppColors.burntUmber))),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
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

  Widget _buildKeyValueRow(String key, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: TextStyle(color: AppColors.burntUmber, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(color: isBold ? AppColors.forestGreen : AppColors.burntUmber, fontWeight: FontWeight.bold)),
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

  Widget _buildProgressBar(double progress, {Color color = AppColors.leafGreen, double height = 8}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: AppColors.sageBorder.withOpacity(0.4),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}