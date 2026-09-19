import 'package:cloud_firestore/cloud_firestore.dart';

class FarmModel {
  final String? id;
  final String farmName;
  final String location;
  final double farmArea;
  final String areaUnit;
  final String farmType;
  final String waterSource;

  final String fieldName;
  final double fieldArea;
  final String irrigationMethod;
  final String fieldCondition;

  final String cropName;
  final DateTime sowingDate;
  final String growthStage;
  final String cropHealth;
  final String expectedHarvest;

  final String soilType;
  final double ph;
  final double moisture;
  final String nitrogen;
  final String phosphorus;
  final String potassium;

  final double temperature;
  final double humidity;
  final double rainfall;
  final double windSpeed;
  final String weatherCondition;
  final String additionalNotes;

  FarmModel({
    this.id,
    required this.farmName,
    required this.location,
    required this.farmArea,
    required this.areaUnit,
    required this.farmType,
    required this.waterSource,
    required this.fieldName,
    required this.fieldArea,
    required this.irrigationMethod,
    required this.fieldCondition,
    required this.cropName,
    required this.sowingDate,
    required this.growthStage,
    required this.cropHealth,
    required this.expectedHarvest,
    required this.soilType,
    required this.ph,
    required this.moisture,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.windSpeed,
    required this.weatherCondition,
    required this.additionalNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'farmName': farmName,
      'location': location,
      'farmArea': farmArea,
      'areaUnit': areaUnit,
      'farmType': farmType,
      'waterSource': waterSource,
      'fieldName': fieldName,
      'fieldArea': fieldArea,
      'irrigationMethod': irrigationMethod,
      'fieldCondition': fieldCondition,
      'cropName': cropName,
      'sowingDate': Timestamp.fromDate(sowingDate),
      'growthStage': growthStage,
      'cropHealth': cropHealth,
      'expectedHarvest': expectedHarvest,
      'soilType': soilType,
      'ph': ph,
      'moisture': moisture,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'temperature': temperature,
      'humidity': humidity,
      'rainfall': rainfall,
      'windSpeed': windSpeed,
      'weatherCondition': weatherCondition,
      'additionalNotes': additionalNotes,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory FarmModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FarmModel(
      id: doc.id,
      farmName: data['farmName'] ?? '',
      location: data['location'] ?? '',
      farmArea: (data['farmArea'] ?? 0.0).toDouble(),
      areaUnit: data['areaUnit'] ?? 'Acres',
      farmType: data['farmType'] ?? '',
      waterSource: data['waterSource'] ?? '',
      fieldName: data['fieldName'] ?? '',
      fieldArea: (data['fieldArea'] ?? 0.0).toDouble(),
      irrigationMethod: data['irrigationMethod'] ?? '',
      fieldCondition: data['fieldCondition'] ?? '',
      cropName: data['cropName'] ?? '',
      sowingDate: (data['sowingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      growthStage: data['growthStage'] ?? '',
      cropHealth: data['cropHealth'] ?? '',
      expectedHarvest: data['expectedHarvest'] ?? '',
      soilType: data['soilType'] ?? '',
      ph: (data['ph'] ?? 0.0).toDouble(),
      moisture: (data['moisture'] ?? 0.0).toDouble(),
      nitrogen: data['nitrogen'] ?? 'Medium',
      phosphorus: data['phosphorus'] ?? 'Medium',
      potassium: data['potassium'] ?? 'Medium',
      temperature: (data['temperature'] ?? 0.0).toDouble(),
      humidity: (data['humidity'] ?? 0.0).toDouble(),
      rainfall: (data['rainfall'] ?? 0.0).toDouble(),
      windSpeed: (data['windSpeed'] ?? 0.0).toDouble(),
      weatherCondition: data['weatherCondition'] ?? '',
      additionalNotes: data['additionalNotes'] ?? '',
    );
  }
}