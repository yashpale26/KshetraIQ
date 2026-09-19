import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:kshetraiq/models/farm_model.dart';
import 'package:kshetraiq/screens/add_edit_farm_screen.dart';
import 'package:kshetraiq/theme/app_colors.dart';

class FarmsScreen extends StatelessWidget {
  const FarmsScreen({super.key});

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
      decoration: const BoxDecoration(
        gradient: _bgGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Farms Overview',
            style: TextStyle(color: AppColors.forestGreen, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.forestGreen, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddEditFarmScreen()),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('farms').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.forestGreen));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading farms: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.burntUmber),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Your Agricultural Data',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.burntUmber.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                if (docs.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No farms added yet. Click "+" or the button below to add.',
                        style: TextStyle(color: AppColors.burntUmber.withOpacity(0.6)),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final farm = FarmModel.fromSnapshot(docs[index]);
                        return _buildFarmCard(context, farm);
                      },
                      childCount: docs.length,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.forestGreen, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.white.withOpacity(0.4),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddEditFarmScreen()),
                        );
                      },
                      icon: const Icon(Icons.add, color: AppColors.forestGreen),
                      label: const Text(
                        'Add / Update Farm Data',
                        style: TextStyle(
                          color: AppColors.forestGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFarmCard(BuildContext context, FarmModel farm) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sageBorder.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🌾 ${farm.farmName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestGreen,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sageBorder.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${farm.farmArea} ${farm.areaUnit}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.burntUmber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            farm.location,
            style: TextStyle(fontSize: 14, color: AppColors.burntUmber.withOpacity(0.8)),
          ),
          if (farm.cropName.isNotEmpty || farm.fieldName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${farm.cropName.isNotEmpty ? farm.cropName : "No Crop"}${farm.fieldName.isNotEmpty ? " • ${farm.fieldName}" : ""}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.softTerracotta,
              ),
            ),
          ],
          const Divider(height: 24, color: AppColors.sageBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🧪 Soil: ${farm.ph} pH',
                style: const TextStyle(fontSize: 13, color: AppColors.burntUmber),
              ),
              Text(
                '🌦 ${farm.temperature}°C',
                style: const TextStyle(fontSize: 13, color: AppColors.burntUmber),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditFarmScreen(farm: farm),
                  ),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View / Edit Farm',
                    style: TextStyle(
                      color: AppColors.softTerracotta,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.softTerracotta),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}