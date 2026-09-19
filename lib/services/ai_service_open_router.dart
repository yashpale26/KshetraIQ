// Open Router API Service
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );

  static const String _model = 'openrouter/free';
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';

  static const int _maxAttempts = 3;

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
      try {
        final dynamic timestamp = data;

        if (timestamp.toDate != null &&
            timestamp.toDate() is DateTime) {
          return (timestamp.toDate() as DateTime).toIso8601String();
        }
      } catch (_) {}

      return data;
    }
  }

  static void _validateApiKey() {
    if (_apiKey.trim().isEmpty) {
      throw Exception(
        'OpenRouter API key is missing. '
            'Run the app with --dart-define=OPENROUTER_API_KEY=YOUR_API_KEY',
      );
    }
  }

  static bool _isRetryableError(Object error) {
    final message = error.toString().toLowerCase();

    return message.contains('429') ||
        message.contains('503') ||
        message.contains('502') ||
        message.contains('500') ||
        message.contains('unavailable') ||
        message.contains('temporarily unavailable') ||
        message.contains('service unavailable') ||
        message.contains('timeout') ||
        message.contains('timed out') ||
        message.contains('connection');
  }

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

  static Map<String, dynamic> _decodeAIJson(String responseText) {
    String cleaned = responseText.trim();

    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7).trim();
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3).trim();
    }

    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3).trim();
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

  static String _extractResponseText(dynamic data) {
    try {
      final choices = data['choices'];

      if (choices == null ||
          choices is! List ||
          choices.isEmpty) {
        throw Exception(
          'OpenRouter returned no choices in the response.',
        );
      }

      final message = choices[0]['message'];

      if (message == null) {
        throw Exception(
          'OpenRouter response did not contain a message.',
        );
      }

      final content = message['content'];

      if (content is String) {
        return content;
      }

      if (content is List) {
        final buffer = StringBuffer();

        for (final item in content) {
          if (item is Map && item['text'] != null) {
            buffer.write(item['text'].toString());
          }
        }

        final result = buffer.toString().trim();

        if (result.isNotEmpty) {
          return result;
        }
      }

      throw Exception(
        'OpenRouter returned an unsupported response format.',
      );
    } catch (e) {
      throw Exception(
        'Unable to read the OpenRouter AI response: $e',
      );
    }
  }

  static Future<String> _sendTextRequest(
      String prompt,
      ) async {
    final uri = Uri.parse(_baseUrl);

    final requestBody = {
      'model': _model,
      'messages': [
        {
          'role': 'user',
          'content': prompt,
        }
      ],
      'response_format': {
        'type': 'json_object',
      },
    };

    final response = await http
        .post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'X-Title': 'KshetraIQ',
      },
      body: jsonEncode(requestBody),
    )
        .timeout(
      const Duration(seconds: 90),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      String errorMessage = response.body;

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map &&
            decoded['error'] is Map &&
            decoded['error']['message'] != null) {
          errorMessage =
              decoded['error']['message'].toString();
        }
      } catch (_) {}

      throw Exception(
        'OpenRouter request failed '
            '(${response.statusCode}): $errorMessage',
      );
    }

    final decoded = jsonDecode(response.body);

    return _extractResponseText(decoded);
  }

  static Future<String> _sendImageRequest(
      String prompt,
      Uint8List imageBytes,
      ) async {
    final uri = Uri.parse(_baseUrl);

    final base64Image = base64Encode(imageBytes);

    final requestBody = {
      'model': _model,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': prompt,
            },
            {
              'type': 'image_url',
              'image_url': {
                'url':
                'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        }
      ],
      'response_format': {
        'type': 'json_object',
      },
    };

    final response = await http
        .post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'X-Title': 'KshetraIQ',
      },
      body: jsonEncode(requestBody),
    )
        .timeout(
      const Duration(seconds: 120),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      String errorMessage = response.body;

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map &&
            decoded['error'] is Map &&
            decoded['error']['message'] != null) {
          errorMessage =
              decoded['error']['message'].toString();
        }
      } catch (_) {}

      throw Exception(
        'OpenRouter image request failed '
            '(${response.statusCode}): $errorMessage',
      );
    }

    final decoded = jsonDecode(response.body);

    return _extractResponseText(decoded);
  }

  static Future<Map<String, dynamic>> analyzeFarmData(
      Map<String, dynamic> farmData,
      ) async {
    _validateApiKey();

    final sanitizedFarmData =
    _sanitizeData(farmData);

    final prompt = '''
You are an expert agricultural AI assistant named KshetraIQ.

Analyze the following complete farm profile data carefully:

${jsonEncode(sanitizedFarmData)}

Your task is to generate a comprehensive agricultural farm analysis.

Generate the result in strict JSON format matching this exact schema:

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
4. Use the actual farm data supplied by the application.
5. Do not blindly copy the example values.
6. Calculate the analysis from the supplied farm, field, soil and environmental data.
7. Calculate crop recommendations using the actual available farm information.
8. Consider farm details.
9. Consider field details.
10. Consider soil details.
11. Consider environmental conditions.
12. Consider water and irrigation information.
13. Include multiple suitable crops whenever enough information is available.
14. The suitability value must be a percentage from 0 to 100.
15. Sort crop recommendations from highest suitability to lowest suitability.
16. The first crop should be the crop with the highest calculated suitability.
17. Give realistic reasons for every recommended crop.
18. Do not invent measured values that are not available in the supplied farm data.
19. If a value is unavailable, make a reasonable qualitative assessment instead of pretending that an exact measurement exists.
20. Keep the exact JSON property names shown in the schema.
21. farmIntelligenceScore must be between 0 and 100.
22. healthScore must be between 0 and 100.
23. problemRisk must be between 0 and 100.
24. soilSuitability must be between 0 and 100.
25. environmentSuitability must be between 0 and 100.
26. Every crop suitability must be between 0 and 100.
27. The final kshetraIqRecommendation must summarize the analysis and identify the most suitable crop based on the available information.
''';

    Object? lastError;

    for (int attempt = 1;
    attempt <= _maxAttempts;
    attempt++) {
      try {
        final responseText =
        await _sendTextRequest(prompt);

        if (responseText.trim().isEmpty) {
          throw Exception(
            'OpenRouter returned an empty farm analysis response.',
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

    throw Exception(
      'KshetraIQ AI farm analysis is temporarily unavailable. '
          'Please try again in a few moments.\n\n'
          'Error: $lastError',
    );
  }

  static Future<Map<String, dynamic>>
  analyzeAgriculturalImage(
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

Analyze the uploaded agricultural image carefully.

Generate a structured visual report in strict JSON format matching this exact schema:

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
4. Analyze the actual uploaded image.
5. Do not blindly copy the example values.
6. Identify the visible agricultural subject.
7. Describe only symptoms that are visually supported by the image.
8. Do not claim certainty when the image does not provide enough evidence.
9. If image quality is insufficient, clearly state that in the JSON.
10. visualHealthAssessment.score must be between 0 and 100.
11. possibleProblem.confidence must be between 0 and 100.
12. Recommended actions must be practical and relevant.
13. Keep the exact JSON property names shown in the schema.
14. Use the selected category and user question as additional context.
15. Do not invent laboratory results or measurements from the image.
16. If multiple problems are possible, identify the most likely visible problem while acknowledging uncertainty.
17. The final insight should explain the result in a concise agricultural context.
''';

    Object? lastError;

    for (int attempt = 1;
    attempt <= _maxAttempts;
    attempt++) {
      try {
        final responseText =
        await _sendImageRequest(
          prompt,
          imageBytes,
        );

        if (responseText.trim().isEmpty) {
          throw Exception(
            'OpenRouter returned an empty image analysis response.',
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

    throw Exception(
      'KshetraIQ image analysis is temporarily unavailable. '
          'Please try again in a few moments.\n\n'
          'Error: $lastError',
    );
  }
  static Future<String> chatWithAssistant({
    required List<Map<String, String>> messages,
    Map<String, dynamic>? selectedFarmData,
    Map<String, dynamic>? selectedAnalysisData,
  }) async {
    _validateApiKey();

    String systemContext =
        'You are KshetraIQ AI Assistant, a friendly and expert agricultural assistant. ';

    if (selectedFarmData != null) {
      systemContext +=
      '\n\nACTIVE FARM CONTEXT:\nThe user has selected a specific farm to discuss:\n${jsonEncode(_sanitizeData(selectedFarmData))}\nUse this farm profile to accurately answer user questions.';
    }

    if (selectedAnalysisData != null) {
      systemContext +=
      '\n\nACTIVE ANALYSIS RECORD CONTEXT:\nThe user has selected an analysis report to discuss:\n${jsonEncode(_sanitizeData(selectedAnalysisData))}\nUse this report data to answer questions.';
    }

    final formattedMessages = [
      {'role': 'system', 'content': systemContext},
      ...messages
    ];

    final uri = Uri.parse(_baseUrl);

    final requestBody = {
      'model': _model,
      'messages': formattedMessages,
    };

    final response = await http
        .post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'X-Title': 'KshetraIQ',
      },
      body: jsonEncode(requestBody),
    )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'OpenRouter chatbot request failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return _extractResponseText(decoded);
  }
}