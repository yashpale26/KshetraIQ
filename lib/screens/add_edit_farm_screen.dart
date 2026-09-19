import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:kshetraiq/models/farm_model.dart';
import 'package:kshetraiq/theme/app_colors.dart';

class AddEditFarmScreen extends StatefulWidget {
  final FarmModel? farm;

  const AddEditFarmScreen({super.key, this.farm});

  @override
  State<AddEditFarmScreen> createState() => _AddEditFarmScreenState();
}

class _AddEditFarmScreenState extends State<AddEditFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Farm Details
  late TextEditingController _farmNameController;
  late TextEditingController _locationController;
  late TextEditingController _farmAreaController;
  String _areaUnit = 'Acres';
  String? _selectedFarmType;
  String? _selectedWaterSource;

  // Field Details
  late TextEditingController _fieldNameController;
  late TextEditingController _fieldAreaController;
  String? _selectedIrrigationMethod;
  late TextEditingController _fieldConditionController;

  // Crop Details
  String? _selectedCrop;
  DateTime _sowingDate = DateTime.now();
  String? _selectedGrowthStage;
  String? _selectedCropHealth;

  // Soil Details
  String? _selectedSoilType;
  late TextEditingController _phController;
  late TextEditingController _moistureController;
  String _selectedNitrogen = 'Medium';
  String _selectedPhosphorus = 'Medium';
  String _selectedPotassium = 'Medium';

  // Environment Details
  late TextEditingController _tempController;
  late TextEditingController _humidityController;
  late TextEditingController _rainfallController;
  late TextEditingController _windSpeedController;
  String? _selectedWeather;
  late TextEditingController _notesController;

  final List<String> _farmTypes = [
    'Organic',
    'Conventional',
    'Hydroponic',
    'Aquaponic',
    'Mixed',
    'Regenerative',
    'Natural Farming',
    'Permaculture',
    'Precision Farming',
    'Integrated Farming',
    'Vertical Farming',
    'Terrace Farming',
    'Dryland Farming',
    'Irrigated Farming',
    'Rainfed Farming',
    'Greenhouse Farming',
    'Polyhouse Farming',
    'Protected Farming',
    'Agroforestry',
    'Horticulture Farming',
    'Plantation Farming',
    'Livestock Farming',
    'Dairy Farming',
    'Poultry Farming',
    'Fish Farming',
    'Integrated Crop-Livestock',
    'Integrated Crop-Livestock-Fish',
    'Urban Farming',
    'Community Farming',
    'Subsistence Farming',
    'Commercial Farming',
    'Contract Farming',
    'Cooperative Farming',
    'Other',
  ];
  final List<String> _waterSources = [
    'Borewell',
    'Open Well',
    'Tube Well',
    'Canal',
    'River',
    'Lake',
    'Pond',
    'Reservoir',
    'Rainwater Harvesting',
    'Rainfed',
    'Farm Pond',
    'Drip Tank',
    'Water Tank',
    'Community Water Supply',
    'Municipal Water Supply',
    'Spring',
    'Stream',
    'Dam',
    'Groundwater',
    'Surface Water',
    'Treated Wastewater',
    'Recycled Water',
    'Desalinated Water',
    'Other',
  ];
  final List<String> _irrigationMethods = [
    'Drip',
    'Sprinkler',
    'Micro Sprinkler',
    'Flood',
    'Furrow',
    'Basin',
    'Border Strip',
    'Manual',
    'Rain Gun',
    'Center Pivot',
    'Linear Move',
    'Subsurface Drip',
    'Surface Irrigation',
    'Trickle Irrigation',
    'Underground Irrigation',
    'Wick Irrigation',
    'Capillary Irrigation',
    'Fog Irrigation',
    'Other',
  ];
  final List<String> _crops = [
    // Cereals & Grains
    'Rice',
    'Wheat',
    'Maize',
    'Barley',
    'Sorghum',
    'Pearl Millet',
    'Finger Millet',
    'Foxtail Millet',
    'Little Millet',
    'Kodo Millet',
    'Proso Millet',
    'Barnyard Millet',

    // Pulses
    'Chickpea',
    'Pigeon Pea',
    'Green Gram',
    'Black Gram',
    'Lentil',
    'Field Pea',
    'Cowpea',
    'Horse Gram',
    'Moth Bean',

    // Oilseeds
    'Groundnut',
    'Soybean',
    'Mustard',
    'Sunflower',
    'Sesame',
    'Safflower',
    'Castor',
    'Linseed',

    // Vegetables
    'Tomato',
    'Potato',
    'Onion',
    'Garlic',
    'Ginger',
    'Carrot',
    'Radish',
    'Beetroot',
    'Cabbage',
    'Cauliflower',
    'Broccoli',
    'Spinach',
    'Fenugreek',
    'Okra',
    'Brinjal',
    'Capsicum',
    'Chilli',
    'Green Peas',
    'Cucumber',
    'Pumpkin',
    'Bottle Gourd',
    'Bitter Gourd',
    'Ridge Gourd',
    'Ash Gourd',
    'Snake Gourd',
    'Drumstick',
    'Sweet Corn',

    // Fruits
    'Mango',
    'Banana',
    'Apple',
    'Orange',
    'Mandarin',
    'Lemon',
    'Grapefruit',
    'Guava',
    'Papaya',
    'Pomegranate',
    'Grapes',
    'Watermelon',
    'Muskmelon',
    'Pineapple',
    'Jackfruit',
    'Sapota',
    'Custard Apple',
    'Strawberry',
    'Fig',
    'Ber',

    // Commercial & Cash Crops
    'Cotton',
    'Sugarcane',
    'Jute',
    'Tobacco',
    'Tea',
    'Coffee',
    'Cocoa',
    'Rubber',

    // Spices & Plantation Crops
    'Turmeric',
    'Black Pepper',
    'Cardamom',
    'Coriander',
    'Cumin',
    'Fennel',
    'Fenugreek',
    'Clove',
    'Nutmeg',
    'Cinnamon',
    'Ginger',
    'Vanilla',
    'Coconut',
    'Arecanut',
    'Cashew',

    // Fodder & Forage Crops
    'Berseem',
    'Lucerne',
    'Napier Grass',
    'Fodder Maize',
    'Fodder Sorghum',

    // Other
    'Bamboo',
    'Medicinal Plants',
    'Aromatic Plants',
    'Other',
  ];
  final List<String> _growthStages = [
    'Land Preparation',
    'Seed Selection',
    'Seed Treatment',
    'Sowing',
    'Germination',
    'Seedling',
    'Transplanting',
    'Vegetative',
    'Bud Formation',
    'Flowering',
    'Fruit Setting',
    'Fruiting',
    'Grain Filling',
    'Maturity',
    'Ripening',
    'Harvesting',
    'Post-Harvest',
    'Storage',
    'Dormancy',
    'Other',
  ];
  final List<String> _cropHealthList = [
    'Healthy',
    'Very Healthy',
    'Good',
    'Moderate',
    'Moderate Risk',
    'Nutrient Deficiency',
    'Nutrient Stress',
    'Water Stress',
    'Drought Stress',
    'Heat Stress',
    'Cold Stress',
    'Environmental Stress',
    'Pest Attack',
    'Pest Infestation',
    'Disease Suspected',
    'Diseased',
    'Fungal Infection',
    'Bacterial Infection',
    'Viral Infection',
    'Root Damage',
    'Leaf Damage',
    'Stem Damage',
    'Wilting',
    'Yellowing',
    'Stunted Growth',
    'Weed Competition',
    'Severe Stress',
    'Critical',
    'Recovering',
    'Post-Treatment',
    'Other',
  ];
  final List<String> _soilTypes = [
    'Loamy',
    'Clay',
    'Sandy',
    'Silty',
    'Sandy Loam',
    'Clay Loam',
    'Silty Loam',
    'Sandy Clay',
    'Silty Clay',
    'Sandy Clay Loam',
    'Silty Clay Loam',
    'Black',
    'Red',
    'Alluvial',
    'Laterite',
    'Desert',
    'Arid',
    'Saline',
    'Alkaline',
    'Peaty',
    'Marshy',
    'Mountain',
    'Forest',
    'Gravelly',
    'Calcareous',
    'Volcanic',
    'Loess',
    'Chalky',
    'Organic-Rich',
    'Humus-Rich',
    'Other',
  ];
  final List<String> _npkLevels = [
    'Very Low',
    'Low',
    'Slightly Low',
    'Medium',
    'Optimal',
    'Slightly High',
    'High',
    'Very High',
    'Deficient',
    'Excessive',
    'Unknown',
    'Other',
  ];
  final List<String> _weatherConditions = [
    'Clear',
    'Sunny',
    'Mostly Sunny',
    'Partly Cloudy',
    'Mostly Cloudy',
    'Cloudy',
    'Overcast',
    'Rainy',
    'Light Rain',
    'Moderate Rain',
    'Heavy Rain',
    'Drizzle',
    'Thunderstorm',
    'Stormy',
    'Windy',
    'Strong Winds',
    'Hazy',
    'Foggy',
    'Misty',
    'Humid',
    'Dry',
    'Hot',
    'Very Hot',
    'Cold',
    'Very Cold',
    'Hailstorm',
    'Dust Storm',
    'Heatwave',
    'Frost',
    'Drought Conditions',
    'Other',
  ];

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
  void initState() {
    super.initState();
    final f = widget.farm;

    _farmNameController = TextEditingController(text: f?.farmName ?? '');
    _locationController = TextEditingController(text: f?.location ?? '');
    _farmAreaController = TextEditingController(text: f != null ? f.farmArea.toString() : '');
    _areaUnit = f?.areaUnit ?? 'Acres';
    _selectedFarmType = f?.farmType.isNotEmpty == true ? f!.farmType : null;
    _selectedWaterSource = f?.waterSource.isNotEmpty == true ? f!.waterSource : null;

    _fieldNameController = TextEditingController(text: f?.fieldName ?? '');
    _fieldAreaController = TextEditingController(text: f != null ? f.fieldArea.toString() : '');
    _selectedIrrigationMethod = f?.irrigationMethod.isNotEmpty == true ? f!.irrigationMethod : null;
    _fieldConditionController = TextEditingController(text: f?.fieldCondition ?? '');

    _selectedCrop = f?.cropName.isNotEmpty == true ? f!.cropName : null;
    _sowingDate = f?.sowingDate ?? DateTime.now();
    _selectedGrowthStage = f?.growthStage.isNotEmpty == true ? f!.growthStage : null;
    _selectedCropHealth = f?.cropHealth.isNotEmpty == true ? f!.cropHealth : null;

    _selectedSoilType = f?.soilType.isNotEmpty == true ? f!.soilType : null;
    _phController = TextEditingController(text: f != null ? f.ph.toString() : '');
    _moistureController = TextEditingController(text: f != null ? f.moisture.toString() : '');
    _selectedNitrogen = f?.nitrogen ?? 'Medium';
    _selectedPhosphorus = f?.phosphorus ?? 'Medium';
    _selectedPotassium = f?.potassium ?? 'Medium';

    _tempController = TextEditingController(text: f != null ? f.temperature.toString() : '');
    _humidityController = TextEditingController(text: f != null ? f.humidity.toString() : '');
    _rainfallController = TextEditingController(text: f != null ? f.rainfall.toString() : '');
    _windSpeedController = TextEditingController(text: f != null ? f.windSpeed.toString() : '');
    _selectedWeather = f?.weatherCondition.isNotEmpty == true ? f!.weatherCondition : null;
    _notesController = TextEditingController(text: f?.additionalNotes ?? '');
  }

  @override
  void dispose() {
    _farmNameController.dispose();
    _locationController.dispose();
    _farmAreaController.dispose();
    _fieldNameController.dispose();
    _fieldAreaController.dispose();
    _fieldConditionController.dispose();
    _phController.dispose();
    _moistureController.dispose();
    _tempController.dispose();
    _humidityController.dispose();
    _rainfallController.dispose();
    _windSpeedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _calculateExpectedHarvest() {
    const estimatedDays = 90;
    final harvestDate = _sowingDate.add(const Duration(days: estimatedDays));
    return DateFormat('dd MMM yyyy').format(harvestDate);
  }

  Future<void> _saveFarm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final farmData = FarmModel(
        id: widget.farm?.id,
        farmName: _farmNameController.text.trim(),
        location: _locationController.text.trim(),
        farmArea: double.tryParse(_farmAreaController.text) ?? 0.0,
        areaUnit: _areaUnit,
        farmType: _selectedFarmType ?? '',
        waterSource: _selectedWaterSource ?? '',
        fieldName: _fieldNameController.text.trim(),
        fieldArea: double.tryParse(_fieldAreaController.text) ?? 0.0,
        irrigationMethod: _selectedIrrigationMethod ?? '',
        fieldCondition: _fieldConditionController.text.trim(),
        cropName: _selectedCrop ?? '',
        sowingDate: _sowingDate,
        growthStage: _selectedGrowthStage ?? '',
        cropHealth: _selectedCropHealth ?? '',
        expectedHarvest: _calculateExpectedHarvest(),
        soilType: _selectedSoilType ?? '',
        ph: double.tryParse(_phController.text) ?? 7.0,
        moisture: double.tryParse(_moistureController.text) ?? 0.0,
        nitrogen: _selectedNitrogen,
        phosphorus: _selectedPhosphorus,
        potassium: _selectedPotassium,
        temperature: double.tryParse(_tempController.text) ?? 0.0,
        humidity: double.tryParse(_humidityController.text) ?? 0.0,
        rainfall: double.tryParse(_rainfallController.text) ?? 0.0,
        windSpeed: double.tryParse(_windSpeedController.text) ?? 0.0,
        weatherCondition: _selectedWeather ?? '',
        additionalNotes: _notesController.text.trim(),
      );

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('You must be logged in to save farm data.');
      }

      final farmMap = farmData.toMap();
      farmMap['userId'] = currentUser.uid;

      final collection = FirebaseFirestore.instance.collection('farms');
      if (widget.farm?.id != null) {
        await collection.doc(widget.farm!.id).update(farmMap);
      } else {
        await collection.add(farmMap);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save farm: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: _bgGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.forestGreen),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.farm == null ? 'Add Farm' : 'Edit Farm',
            style: const TextStyle(color: AppColors.forestGreen, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Your Farm Profile',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.burntUmber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // FARM DETAILS
                _buildSectionHeader('FARM DETAILS'),
                _buildTextField('Farm Name', _farmNameController, required: true),
                _buildTextField('Location', _locationController, required: true),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField('Farm Area', _farmAreaController, keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _buildDropdown(
                        label: 'Unit',
                        value: _areaUnit,
                        items: ['Acres', 'Hectares'],
                        onChanged: (val) => setState(() => _areaUnit = val!),
                      ),
                    ),
                  ],
                ),
                _buildDropdown(
                  label: 'Farm Type',
                  value: _selectedFarmType,
                  items: _farmTypes,
                  onChanged: (val) => setState(() => _selectedFarmType = val),
                ),
                _buildDropdown(
                  label: 'Water Source',
                  value: _selectedWaterSource,
                  items: _waterSources,
                  onChanged: (val) => setState(() => _selectedWaterSource = val),
                ),

                // FIELD DETAILS
                _buildSectionHeader('FIELD DETAILS'),
                _buildTextField('Field Name', _fieldNameController),
                _buildTextField('Field Area (Acres)', _fieldAreaController, keyboardType: TextInputType.number),
                _buildDropdown(
                  label: 'Irrigation Method',
                  value: _selectedIrrigationMethod,
                  items: _irrigationMethods,
                  onChanged: (val) => setState(() => _selectedIrrigationMethod = val),
                ),
                _buildTextField('Field Condition', _fieldConditionController, hint: 'Describe field condition'),

                // CROP DETAILS
                _buildSectionHeader('CROP DETAILS'),
                _buildDropdown(
                  label: 'Crop Name',
                  value: _selectedCrop,
                  items: _crops,
                  onChanged: (val) => setState(() => _selectedCrop = val),
                ),
                _buildDatePicker('Sowing Date', _sowingDate, (picked) {
                  setState(() => _sowingDate = picked);
                }),
                _buildDropdown(
                  label: 'Growth Stage',
                  value: _selectedGrowthStage,
                  items: _growthStages,
                  onChanged: (val) => setState(() => _selectedGrowthStage = val),
                ),
                _buildDropdown(
                  label: 'Crop Health',
                  value: _selectedCropHealth,
                  items: _cropHealthList,
                  onChanged: (val) => setState(() => _selectedCropHealth = val),
                ),
                _buildReadOnlyField('Expected Harvest', _calculateExpectedHarvest()),

                // SOIL DETAILS
                _buildSectionHeader('SOIL DETAILS'),
                _buildDropdown(
                  label: 'Soil Type',
                  value: _selectedSoilType,
                  items: _soilTypes,
                  onChanged: (val) => setState(() => _selectedSoilType = val),
                ),
                _buildTextField('pH', _phController, keyboardType: TextInputType.number),
                _buildTextField('Moisture %', _moistureController, keyboardType: TextInputType.number),
                _buildDropdown(
                  label: 'Nitrogen',
                  value: _selectedNitrogen,
                  items: _npkLevels,
                  onChanged: (val) => setState(() => _selectedNitrogen = val!),
                ),
                _buildDropdown(
                  label: 'Phosphorus',
                  value: _selectedPhosphorus,
                  items: _npkLevels,
                  onChanged: (val) => setState(() => _selectedPhosphorus = val!),
                ),
                _buildDropdown(
                  label: 'Potassium',
                  value: _selectedPotassium,
                  items: _npkLevels,
                  onChanged: (val) => setState(() => _selectedPotassium = val!),
                ),

                // ENVIRONMENT DETAILS
                _buildSectionHeader('ENVIRONMENT DETAILS'),
                _buildTextField('Temperature (°C)', _tempController, keyboardType: TextInputType.number),
                _buildTextField('Humidity (%)', _humidityController, keyboardType: TextInputType.number),
                _buildTextField('Rainfall (mm)', _rainfallController, keyboardType: TextInputType.number),
                _buildTextField('Wind Speed (km/h)', _windSpeedController, keyboardType: TextInputType.number),
                _buildDropdown(
                  label: 'Weather Condition',
                  value: _selectedWeather,
                  items: _weatherConditions,
                  onChanged: (val) => setState(() => _selectedWeather = val),
                ),
                _buildTextField('Additional Notes', _notesController, maxLines: 3),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.softTerracotta,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSaving ? null : _saveFarm,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Save Farm Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.sageBorder, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.forestGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.sageBorder, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        bool required = false,
        TextInputType keyboardType = TextInputType.text,
        String? hint,
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.burntUmber),
        validator: required
            ? (val) => (val == null || val.isEmpty) ? 'This field is required' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: AppColors.burntUmber),
          filled: true,
          fillColor: AppColors.secondaryBackground.withOpacity(0.85),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.sageBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.forestGreen, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: value,
        style: const TextStyle(color: AppColors.burntUmber),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.burntUmber),
          filled: true,
          fillColor: AppColors.secondaryBackground.withOpacity(0.85),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.sageBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.forestGreen, width: 1.5),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime currentDate, ValueChanged<DateTime> onPicked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: currentDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (date != null) onPicked(date);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: AppColors.burntUmber),
            filled: true,
            fillColor: AppColors.secondaryBackground.withOpacity(0.85),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.sageBorder),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd MMM yyyy').format(currentDate),
                style: const TextStyle(color: AppColors.burntUmber),
              ),
              const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.forestGreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.burntUmber),
          filled: true,
          fillColor: AppColors.secondaryBackground.withOpacity(0.5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.sageBorder),
          ),
        ),
        child: Text(
          value,
          style: TextStyle(color: AppColors.burntUmber.withOpacity(0.7)),
        ),
      ),
    );
  }
}
