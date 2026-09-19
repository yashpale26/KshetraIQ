import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // ============================================================
  // API KEY
  // ============================================================
  //
  // Recommended:
  // flutter run --dart-define=GEMINI_API_KEY=YOUR_NEW_API_KEY
  //
  // IMPORTANT:
  // Do NOT keep a real API key directly inside source code.
  //
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  // ============================================================
  // MODELS
  // ============================================================

  // Primary model
  static const String _primaryModel = 'gemini-3.6-flash';

  // Fallback model if primary model is temporarily unavailable
  static const String _fallbackModel = 'gemini-2.5-flash';

  // Number of attempts for each model
  static const int _maxAttempts = 3;

  // ============================================================
  // FIRESTORE DATA SANITIZER
  // ============================================================

  /// Helper to recursively sanitize Firestore types
  /// into JSON-encodable formats.
  static dynamic _sanitizeData(dynamic data) {
    if (data == null) return null;

    if (data is DateTime) {
      return data.toIso8601String();
    } else if (data is Map) {
      return data.map(
            (key, value) => MapEntry(
          key.toString(),
          _sanitizeData(value),
        ),
      );
    } else if (data is List) {
      return data.map((item) => _sanitizeData(item)).toList();
    } else {
      // Fallback duck-typing for Firestore Timestamp
      // without requiring direct import.
      try {
        final dynamic timestamp = data;

        if (timestamp.toDate != null &&
            timestamp.toDate() is DateTime) {
          return (timestamp.toDate() as DateTime)
              .toIso8601String();
        }
      } catch (_) {}

      return data;
    }
  }

  // ============================================================
  // CHECK API KEY
  // ============================================================

  static void _validateApiKey() {
    if (_apiKey.trim().isEmpty) {
      throw Exception(
        'Gemini API key is missing. '
            'Run the app with --dart-define=GEMINI_API_KEY=YOUR_API_KEY',
      );
    }
  }

  // ============================================================
  // CHECK WHETHER ERROR IS TEMPORARY
  // ============================================================

  static bool _isRetryableError(Object error) {
    final message = error.toString().toLowerCase();

    return message.contains('503') ||
        message.contains('unavailable') ||
        message.contains('high demand') ||
        message.contains('temporarily unavailable') ||
        message.contains('service unavailable') ||
        message.contains('deadline exceeded') ||
        message.contains('timeout');
  }

  // ============================================================
  // WAIT BEFORE RETRY
  // ============================================================

  static Future<void> _waitBeforeRetry(int attempt) async {
    Duration delay;

    switch (attempt) {
      case 1:
        delay = const Duration(seconds: 2);
        break;

      case 2:
        delay = const Duration(seconds: 5);
        break;

      default:
        delay = const Duration(seconds: 8);
        break;
    }

    await Future.delayed(delay);
  }

  // ============================================================
  // CLEAN AI JSON RESPONSE
  // ============================================================

  static Map<String, dynamic> _decodeAIJson(String responseText) {
    String cleaned = responseText.trim();

    // Remove Markdown code fences if Gemini returns them.
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7).trim();
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3).trim();
    }

    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(
        0,
        cleaned.length - 3,
      ).trim();
    }

    try {
      final decoded = jsonDecode(cleaned);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      throw Exception(
        'AI returned JSON, but the response was not an object.',
      );
    } catch (e) {
      throw Exception(
        'AI returned an invalid JSON response. '
            'Please try again.\n\nRaw response:\n$cleaned',
      );
    }
  }

  // ============================================================
  // FARM ANALYSIS REQUEST
  // ============================================================

  static Future<GenerateContentResponse> _generateFarmAnalysis(
      String prompt,
      String modelName,
      ) async {
    final model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );

    return await model.generateContent([
      Content.text(prompt),
    ]);
  }

  // ============================================================
  // IMAGE ANALYSIS REQUEST
  // ============================================================

  static Future<GenerateContentResponse> _generateImageAnalysis(
      String prompt,
      Uint8List imageBytes,
      String modelName,
      ) async {
    final model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );

    final imagePart = DataPart(
      'image/jpeg',
      imageBytes,
    );

    return await model.generateContent([
      Content.multi([
        TextPart(prompt),
        imagePart,
      ]),
    ]);
  }

  // ============================================================
  // FARM ANALYSIS
  // ============================================================

  /// Generates full Farm Analysis based on dynamic farm data
  /// retrieved from Firestore.
  ///
  /// PUBLIC METHOD KEPT EXACTLY THE SAME.
  static Future<Map<String, dynamic>> analyzeFarmData(
      Map<String, dynamic> farmData,
      ) async {
    _validateApiKey();

    // Sanitize Firestore data.
    final sanitizedFarmData = _sanitizeData(farmData);

    final prompt = '''
You are an expert agricultural AI assistant named KshetraIQ. Analyze the following complete farm profile data carefully:

${jsonEncode(sanitizedFarmData)}

Generate a comprehensive farm analytical report in strict JSON format matching this exact schema:

{
  "farmIntelligenceScore": 82,
  "overallCondition": "Good",
  "cropHealth": {
    "cropName": "Tomato",
    "healthScore": 84,
    "status": "Healthy"
  },
  "cropProblemAnalysis": {
    "problemRisk": 28,
    "possibleFactors": [
      "Nutrient imbalance",
      "Environmental stress"
    ]
  },
  "soilAnalysis": {
    "ph": 6.7,
    "moisture": "42%",
    "nitrogen": "Medium",
    "phosphorus": "High",
    "potassium": "Medium",
    "soilSuitability": 81
  },
  "irrigationAdvisor": {
    "waterRequirement": "Medium",
    "irrigationPriority": "Moderate"
  },
  "environmentalAnalysis": {
    "temperature": "28°C",
    "humidity": "72%",
    "rainfall": "12 mm",
    "wind": "14 km/h",
    "environmentSuitability": 78
  },
  "riskIndicators": {
    "cropRisk": "Low",
    "soilRisk": "Low",
    "waterRisk": "Moderate",
    "weatherRisk": "Low"
  },
  "recommendedActions": [
    "Monitor crop condition",
    "Review irrigation requirement",
    "Monitor soil moisture"
  ],
  "cropRecommendations": [
    {
      "cropName": "TOMATO",
      "suitability": 86,
      "badge": "🥇",
      "reasons": [
        "Soil conditions are suitable",
        "Current environment is favorable",
        "Water requirement can be managed"
      ]
    },
    {
      "cropName": "CHILLI",
      "suitability": 79,
      "badge": "🌶",
      "reasons": [
        "Compatible soil conditions",
        "Suitable temperature range"
      ]
    },
    {
      "cropName": "WHEAT",
      "suitability": 64,
      "badge": "🌾",
      "reasons": [
        "Seasonal suitability required",
        "Irrigation must be monitored"
      ]
    }
  ],
  "kshetraIqRecommendation": "Based on the recorded farm, field, soil and environmental conditions, Tomato currently shows the highest suitability among the evaluated crops."
}

IMPORTANT INSTRUCTIONS:

1. Return ONLY valid JSON.
2. Do not use Markdown.
3. Do not put the JSON inside ```json code fences.
4. Use the actual farm data provided above.
5. Do not blindly copy the example values.
6. Calculate the crop recommendations based on the supplied farm, field, soil and environmental conditions.
7. The suitability values should represent relative suitability based on the available data.
8. Include multiple suitable crops when the available information allows it.
9. Keep the exact JSON property names shown in the schema.
''';

    Object? lastError;

    // ============================================================
    // PRIMARY MODEL RETRIES
    // ============================================================

    for (int attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final response = await _generateFarmAnalysis(
          prompt,
          _primaryModel,
        );

        final responseText = response.text;

        if (responseText == null ||
            responseText.trim().isEmpty) {
          throw Exception(
            'Gemini returned an empty farm analysis response.',
          );
        }

        return _decodeAIJson(responseText);
      } catch (e) {
        lastError = e;

        // Only retry temporary/server errors.
        if (!_isRetryableError(e)) {
          break;
        }

        // Don't wait after the final attempt.
        if (attempt < _maxAttempts) {
          await _waitBeforeRetry(attempt);
        }
      }
    }

    // ============================================================
    // FALLBACK MODEL
    // ============================================================

    try {
      final response = await _generateFarmAnalysis(
        prompt,
        _fallbackModel,
      );

      final responseText = response.text;

      if (responseText == null ||
          responseText.trim().isEmpty) {
        throw Exception(
          'Fallback Gemini model returned an empty response.',
        );
      }

      return _decodeAIJson(responseText);
    } catch (fallbackError) {
      throw Exception(
        'KshetraIQ AI analysis is temporarily unavailable. '
            'Please try again in a few moments.\n\n'
            'Primary error: $lastError\n'
            'Fallback error: $fallbackError',
      );
    }
  }

  // ============================================================
  // AGRICULTURAL IMAGE ANALYSIS
  // ============================================================

  /// Generates Multimodal Visual Analysis based on an uploaded image
  /// & optional user context.
  ///
  /// PUBLIC METHOD KEPT EXACTLY THE SAME.
  static Future<Map<String, dynamic>> analyzeAgriculturalImage(
      Uint8List imageBytes,
      String analysisType,
      String userQuestion,
      ) async {
    _validateApiKey();

    final prompt = '''
You are an expert agricultural computer vision AI named KshetraIQ.

Analyze the agricultural subject shown in the provided image.

Selected Category / Type:
$analysisType

User's Question / Note:
$userQuestion

Analyze the agricultural subject carefully and provide a structured visual report in strict JSON format matching this exact schema:

{
  "detectedSubject": "Tomato Plant",
  "visualHealthAssessment": {
    "score": 76,
    "status": "Attention Required"
  },
  "observedSymptoms": [
    "Leaf discoloration",
    "Irregular leaf appearance"
  ],
  "possibleProblem": {
    "title": "Potential Nutrient Stress",
    "confidence": 72
  },
  "contributingFactors": [
    "Soil nutrient imbalance may contribute",
    "Environmental conditions should be monitored"
  ],
  "riskIndicators": {
    "cropRisk": "Moderate",
    "nutrientRisk": "Moderate",
    "environmentRisk": "Low"
  },
  "recommendedActions": [
    "Monitor the affected plant",
    "Check soil nutrient condition",
    "Compare symptoms over time"
  ],
  "kshetraIqInsight": "The image indicates a condition that should be monitored. Additional farm data can improve the assessment."
}

IMPORTANT INSTRUCTIONS:

1. Return ONLY valid JSON.
2. Do not use Markdown.
3. Do not put the JSON inside ```json code fences.
4. Do not blindly copy the example values.
5. Analyze the actual uploaded image.
6. If the image quality is insufficient, clearly state that in the response.
7. Do not claim certainty when the image does not provide enough evidence.
8. Keep the exact JSON property names shown in the schema.
9. The confidence score must represent the visual evidence available in the image.
10. Recommended actions should be practical and relevant to the observed condition.
''';

    Object? lastError;

    // ============================================================
    // PRIMARY MODEL RETRIES
    // ============================================================

    for (int attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final response = await _generateImageAnalysis(
          prompt,
          imageBytes,
          _primaryModel,
        );

        final responseText = response.text;

        if (responseText == null ||
            responseText.trim().isEmpty) {
          throw Exception(
            'Gemini returned an empty image analysis response.',
          );
        }

        return _decodeAIJson(responseText);
      } catch (e) {
        lastError = e;

        if (!_isRetryableError(e)) {
          break;
        }

        if (attempt < _maxAttempts) {
          await _waitBeforeRetry(attempt);
        }
      }
    }

    // ============================================================
    // FALLBACK MODEL
    // ============================================================

    try {
      final response = await _generateImageAnalysis(
        prompt,
        imageBytes,
        _fallbackModel,
      );

      final responseText = response.text;

      if (responseText == null ||
          responseText.trim().isEmpty) {
        throw Exception(
          'Fallback Gemini model returned an empty image response.',
        );
      }

      return _decodeAIJson(responseText);
    } catch (fallbackError) {
      throw Exception(
        'KshetraIQ image analysis is temporarily unavailable. '
            'Please try again in a few moments.\n\n'
            'Primary error: $lastError\n'
            'Fallback error: $fallbackError',
      );
    }
  }
}