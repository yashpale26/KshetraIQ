import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kshetraiq/screens/add_activity_screen.dart';
import 'package:kshetraiq/theme/app_colors.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
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

  Future<void> _toggleActivityCompletion(String docId, bool currentStatus) async {
    try {
      await _firestore.collection('planner_activities').doc(docId).update({
        'isCompleted': !currentStatus,
        'completedAt': !currentStatus ? FieldValue.serverTimestamp() : null,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating activity: $e')),
        );
      }
    }
  }

  Future<void> _quickAddAiSuggestion(String title, String farm, String field) async {
    try {
      await _firestore.collection('planner_activities').add({
        'title': title,
        'farm': farm,
        'field': field,
        'source': 'AI Planner',
        'priority': 'Medium',
        'dueDate': Timestamp.fromDate(DateTime.now()),
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'notes': 'Added directly from AI Suggested Actions',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to Planner!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding activity: $e')),
        );
      }
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
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Planner',
                style: TextStyle(
                  color: AppColors.forestGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              Text(
                'Farm Activities',
                style: TextStyle(
                  color: AppColors.forestGreen,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded, color: AppColors.forestGreen, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddActivityScreen()),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore
              .collection('planner_activities')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.forestGreen),
              );
            }

            final docs = snapshot.data?.docs ?? [];
            final upcomingActivities = docs.where((d) => !(d.data()['isCompleted'] ?? false)).toList();
            final completedActivities = docs.where((d) => d.data()['isCompleted'] ?? false).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // UPCOMING SECTION
                  _buildSectionHeader('UPCOMING'),
                  const SizedBox(height: 8),
                  if (upcomingActivities.isEmpty)
                    _buildEmptyState('No upcoming activities found.')
                  else
                    ...upcomingActivities.map((doc) => _buildUpcomingCard(doc)),

                  const SizedBox(height: 24),

                  // AI SUGGESTED ACTIONS SECTION
                  _buildSectionHeader('AI SUGGESTED ACTIONS'),
                  const SizedBox(height: 8),
                  _buildAiSuggestionsStream(),

                  const SizedBox(height: 24),

                  // COMPLETED SECTION
                  _buildSectionHeader('✓ COMPLETED'),
                  const SizedBox(height: 8),
                  if (completedActivities.isEmpty)
                    _buildEmptyState('No completed activities yet.')
                  else
                    ...completedActivities.map((doc) => _buildCompletedTile(doc)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.forestGreen,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.burntUmber.withOpacity(0.7),
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final id = doc.id;
    final title = data['title'] ?? 'Activity';
    final farm = data['farm'] ?? 'N/A';
    final field = data['field'] ?? 'N/A';
    final source = data['source'] ?? 'Manual Planner';
    final priority = data['priority'] ?? 'Medium';
    final Timestamp? dueTs = data['dueDate'] as Timestamp?;
    final dateStr = dueTs != null ? DateFormat('dd MMM').format(dueTs.toDate()) : 'Today';

    final isAi = source == 'AI Planner';
    final iconData = isAi ? Icons.water_drop_rounded : Icons.science_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sageBorder.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isAi
                ? AppColors.forestGreen.withOpacity(0.1)
                : AppColors.burntUmber.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            iconData,
            color: isAi ? AppColors.forestGreen : AppColors.burntUmber,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.burntUmber,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$farm ($field) • $dateStr',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.burntUmber.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    source,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isAi ? AppColors.forestGreen : AppColors.softTerracotta,
                    ),
                  ),
                  if (priority.isNotEmpty) ...[
                    const Text(' • ', style: TextStyle(fontSize: 11)),
                    Text(
                      '$priority Priority',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.burntUmber.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        trailing: Checkbox(
          value: false,
          activeColor: AppColors.forestGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (_) => _toggleActivityCompletion(id, false),
        ),
      ),
    );
  }

  Widget _buildAiSuggestionsStream() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('ai_history')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.forestGreen),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No AI recommendations available. Run AI Farm Analysis first.');
        }

        final doc = snapshot.data!.docs.first.data();
        final farmName = doc['farmName'] ?? 'Farm';
        final result = doc['resultData'] as Map<String, dynamic>? ?? {};
        final recs = (result['recommendations'] as List?)?.cast<String>() ?? [];

        if (recs.isEmpty) {
          return _buildEmptyState('No pending recommendations found in recent AI history.');
        }

        final suggestionText = recs.first;
        return _buildAiSuggestionCard(suggestionText, farmName, 'Field A');
      },
    );
  }

  Widget _buildAiSuggestionCard(String title, String farm, String field) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sageBorder.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.forestGreen, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.burntUmber,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _quickAddAiSuggestion(title, farm, field),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Add to Planner',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTile(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final id = doc.id;
    final title = data['title'] ?? 'Completed Activity';
    final farm = data['farm'] ?? 'Farm';
    final Timestamp? completedTs = data['completedAt'] as Timestamp?;
    final dateStr = completedTs != null
        ? DateFormat('dd MMM').format(completedTs.toDate())
        : 'Recently';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: IconButton(
          icon: const Icon(Icons.check_circle_rounded, color: AppColors.forestGreen),
          onPressed: () => _toggleActivityCompletion(id, true),
        ),
        title: Text(
          title,
          style: const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: AppColors.burntUmber,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          '$farm • $dateStr',
          style: TextStyle(
            color: AppColors.burntUmber.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}