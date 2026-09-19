import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kshetraiq/screens/image_analysis_result_screen.dart';
import 'package:kshetraiq/services/ai_service_open_router.dart';
import '../theme/app_colors.dart';


class AiImageAnalysisScreen extends StatefulWidget {
  const AiImageAnalysisScreen({super.key});

  @override
  State<AiImageAnalysisScreen> createState() => _AiImageAnalysisScreenState();
}

class _AiImageAnalysisScreenState extends State<AiImageAnalysisScreen> {
  static const LinearGradient _bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFA2E1BA),
      Color(0xFFFCF3CF),
      Color(0xFFEADBC8),
    ],
  );

  Uint8List? _imageBytes;
  String _selectedAnalysisType = 'Auto Detect';
  final TextEditingController _questionController = TextEditingController();
  bool _isAnalyzing = false;

  final List<String> _analysisTypes = [
    'Auto Detect',
    'Plant / Crop',
    'Leaf / Crop Problem',
    'Field / Farm',
    'Soil',
    'Fertilizer'
  ];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture or select an image first.')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final result = await AIService.analyzeAgriculturalImage(
        _imageBytes!,
        _selectedAnalysisType,
        _questionController.text.trim(),
      );

      final detectedSubject = result['detectedSubject'] ?? 'Agricultural Subject';

      // Save History to Firestore
      await FirebaseFirestore.instance.collection('ai_history').add({
        'type': 'IMAGE_ANALYSIS',
        'title': detectedSubject,
        'timestamp': FieldValue.serverTimestamp(),
        'scoreText': 'Health Assessment: ${result['visualHealthAssessment']?['score'] ?? 0}%',
        'resultData': result,
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageAnalysisResultScreen(
              imageBytes: _imageBytes!,
              data: result,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image Analysis Error: $e')),
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
          title: const Text('AI Image Analysis', style: TextStyle(color: AppColors.forestGreen, fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Analyze Agricultural Images', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.forestGreen)),
              const SizedBox(height: 8),
              const Text('Capture or select an image of:', style: TextStyle(color: AppColors.burntUmber)),
              const SizedBox(height: 8),
              const Text('🌱 Plant / Crop\n🍃 Leaf / Crop Problem\n🌾 Field / Farm\n🧪 Soil\n🧴 Fertilizer', style: TextStyle(color: AppColors.burntUmber, height: 1.4)),
              const SizedBox(height: 16),

              // IMAGE PREVIEW AREA
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.sageBorder),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                )
                    : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded, size: 48, color: AppColors.forestGreen),
                    SizedBox(height: 8),
                    Text('Select Image', style: TextStyle(color: AppColors.burntUmber)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // CAMERA / GALLERY BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.forestGreen),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.white.withOpacity(0.4),
                      ),
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, color: AppColors.forestGreen),
                      label: const Text('Camera\nCapture Image', textAlign: TextAlign.center, style: TextStyle(color: AppColors.forestGreen, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.forestGreen),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.white.withOpacity(0.4),
                      ),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, color: AppColors.forestGreen),
                      label: const Text('Gallery\nSelect Image', textAlign: TextAlign.center, style: TextStyle(color: AppColors.forestGreen, fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ANALYSIS TYPE DROPDOWN
              const Text('ANALYSIS TYPE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.forestGreen, letterSpacing: 1.1)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedAnalysisType,
                style: const TextStyle(color: AppColors.burntUmber),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.secondaryBackground.withOpacity(0.85),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.sageBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.forestGreen)),
                ),
                items: _analysisTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _selectedAnalysisType = val!),
              ),
              const SizedBox(height: 16),

              // ADDITIONAL QUESTION
              const Text('Additional Question', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.forestGreen)),
              const SizedBox(height: 6),
              TextField(
                controller: _questionController,
                style: const TextStyle(color: AppColors.burntUmber),
                decoration: InputDecoration(
                  hintText: 'What should I know about this?',
                  hintStyle: TextStyle(color: AppColors.burntUmber.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppColors.secondaryBackground.withOpacity(0.85),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.sageBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.forestGreen)),
                ),
              ),
              const SizedBox(height: 24),

              // ANALYZE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softTerracotta,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isAnalyzing ? null : _analyzeImage,
                  icon: _isAnalyzing
                      ? const SizedBox.shrink()
                      : const Icon(Icons.auto_awesome, color: Colors.white),
                  label: _isAnalyzing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('✨ Analyze Image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}