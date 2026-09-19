import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kshetraiq/theme/app_colors.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  static const LinearGradient _bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFA2E1BA),
      Color(0xFFFCF3CF),
      Color(0xFFEADBC8),
    ],
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Selected Planner Mode
  bool _isAiPlanner = true;

  // Form Controllers & Selections
  final TextEditingController _activityNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedAiRecommendation;
  String _aiReason = 'Based on recent AI farm analysis metrics.';

  String? _selectedFarm;
  String? _selectedField;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedPriority = 'Medium';

  bool _isSaving = false;

  final List<String> _priorities = ['Low', 'Medium', 'High'];

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
            'Add Activity',
            style: TextStyle(
              color: AppColors.forestGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SELECT PLANNER TYPE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestGreen,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),

              // TYPE SELECTOR CARDS
              _buildTypeCard(
                title: '✨ AI PLANNER',
                subtitle: 'Add an activity suggested by AI',
                isSelected: _isAiPlanner,
                onTap: () => setState(() => _isAiPlanner = true),
              ),
              const SizedBox(height: 12),
              _buildTypeCard(
                title: '📝 MANUAL PLANNER',
                subtitle: 'Create your own farm activity',
                isSelected: !_isAiPlanner,
                onTap: () => setState(() => _isAiPlanner = false),
              ),

              const SizedBox(height: 24),

              // DIVIDER
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.sageBorder)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      _isAiPlanner ? 'AI PLANNER' : 'MANUAL PLANNER',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.sageBorder)),
                ],
              ),
              const SizedBox(height: 16),

              // DYNAMIC FORM CONTENT
              if (_isAiPlanner) ...[
                _buildLabel('AI SUGGESTION'),
                _buildAiSuggestionsDropdown(),
                const SizedBox(height: 14),
                _buildLabel('Reason'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.sageBorder.withOpacity(0.5)),
                  ),
                  child: Text(
                    _aiReason,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.burntUmber.withOpacity(0.8),
                    ),
                  ),
                ),
              ] else ...[
                _buildLabel('Activity Name'),
                _buildTextField(_activityNameController, 'e.g. Check irrigation pipes'),
              ],

              const SizedBox(height: 14),
              _buildLabel('Farm'),
              _buildFarmsDropdown(),

              const SizedBox(height: 14),
              _buildLabel('Field'),
              _buildFieldsDropdown(),

              const SizedBox(height: 14),
              _buildLabel('Date'),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.sageBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                        style: const TextStyle(color: AppColors.burntUmber),
                      ),
                      const Icon(Icons.calendar_today_rounded,
                          size: 18, color: AppColors.forestGreen),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),
              _buildLabel('Priority'),
              _buildDropdown(
                value: _selectedPriority,
                items: _priorities,
                onChanged: (val) => setState(() => _selectedPriority = val!),
              ),

              if (!_isAiPlanner) ...[
                const SizedBox(height: 14),
                _buildLabel('Notes'),
                _buildTextField(_notesController, 'Optional notes...', maxLines: 3),
              ],

              const SizedBox(height: 28),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Save Activity',
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

  // --- DYNAMIC FIRESTORE DROPDOWNS ---

  Widget _buildAiSuggestionsDropdown() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('ai_history')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LinearProgressIndicator(color: AppColors.forestGreen);
        }

        final List<String> recs = [];
        for (var doc in snapshot.data!.docs) {
          final result = doc.data()['resultData'] as Map<String, dynamic>?;
          if (result != null && result['recommendations'] != null) {
            final fetched = (result['recommendations'] as List).cast<String>();
            recs.addAll(fetched);
          }
        }

        if (recs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'No AI suggestions available. Perform an AI analysis first.',
              style: TextStyle(fontSize: 12, color: AppColors.burntUmber),
            ),
          );
        }

        if (_selectedAiRecommendation == null || !recs.contains(_selectedAiRecommendation)) {
          _selectedAiRecommendation = recs.first;
        }

        return _buildDropdown(
          value: _selectedAiRecommendation,
          items: recs,
          onChanged: (val) => setState(() => _selectedAiRecommendation = val),
        );
      },
    );
  }

  Widget _buildFarmsDropdown() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('farms').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LinearProgressIndicator(color: AppColors.forestGreen);
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'No farms saved in database. Add a farm first.',
              style: TextStyle(fontSize: 12, color: AppColors.burntUmber),
            ),
          );
        }

        final farmNames = docs.map((d) => (d.data()['farmName'] ?? 'Farm').toString()).toList();

        if (_selectedFarm == null || !farmNames.contains(_selectedFarm)) {
          _selectedFarm = farmNames.first;
        }

        return _buildDropdown(
          value: _selectedFarm,
          items: farmNames,
          onChanged: (val) {
            setState(() {
              _selectedFarm = val;
              _selectedField = null; // Reset field on farm change
            });
          },
        );
      },
    );
  }

  Widget _buildFieldsDropdown() {
    if (_selectedFarm == null) {
      return _buildDisabledContainer('Select a farm first');
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('farms')
          .where('farmName', isEqualTo: _selectedFarm)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LinearProgressIndicator(color: AppColors.forestGreen);
        }

        final docs = snapshot.data!.docs;
        List<String> fieldList = [];

        if (docs.isNotEmpty) {
          final data = docs.first.data();
          if (data['fields'] != null && data['fields'] is List) {
            fieldList = (data['fields'] as List).map((f) => f.toString()).toList();
          }
        }

        if (fieldList.isEmpty) {
          fieldList = ['Field A', 'Field B', 'Main Field']; // Fallback field options for selected farm
        }

        if (_selectedField == null || !fieldList.contains(_selectedField)) {
          _selectedField = fieldList.first;
        }

        return _buildDropdown(
          value: _selectedField,
          items: fieldList,
          onChanged: (val) => setState(() => _selectedField = val),
        );
      },
    );
  }

  // --- ACTIONS & UI HELPER WIDGETS ---

  Future<void> _saveActivity() async {
    final title = _isAiPlanner
        ? (_selectedAiRecommendation ?? '')
        : _activityNameController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or select a valid activity title.')),
      );
      return;
    }

    if (_selectedFarm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a saved farm.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _firestore.collection('planner_activities').add({
        'title': title,
        'farm': _selectedFarm,
        'field': _selectedField ?? 'Field A',
        'dueDate': Timestamp.fromDate(_selectedDate),
        'priority': _selectedPriority,
        'source': _isAiPlanner ? 'AI Planner' : 'Manual Planner',
        'isCompleted': false,
        'reason': _isAiPlanner ? _aiReason : null,
        'notes': _notesController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity saved to Planner!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save activity: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildTypeCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.forestGreen : AppColors.sageBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.burntUmber.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.forestGreen : AppColors.burntUmber.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.forestGreen,
        ),
      ),
    );
  }

  Widget _buildDisabledContainer(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.sageBorder.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: AppColors.burntUmber.withOpacity(0.5), fontSize: 13),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.burntUmber, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.burntUmber.withOpacity(0.5), fontSize: 13),
        filled: true,
        fillColor: AppColors.secondaryBackground.withOpacity(0.9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.sageBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.forestGreen),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.sageBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          isExpanded: true,
          dropdownColor: AppColors.secondaryBackground,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.forestGreen),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(color: AppColors.burntUmber, fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}