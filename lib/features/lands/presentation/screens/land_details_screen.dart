import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/land.dart';
import '../widgets/seasonal_info_card.dart';

/// Single Land Details Screen
class LandDetailsScreen extends ConsumerWidget {
  final Land land;
  
  const LandDetailsScreen({
    super.key,
    required this.land,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          land.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit land screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('সম্পাদনা শীঘ্রই আসছে')),
              );
            },
            tooltip: 'সম্পাদনা করুন',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Land Details Card
            _buildLandDetailsCard(context),
            
            const SizedBox(height: 16),
            
            // Seasonal Information Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'মৌসুম অনুযায়ী তথ্য',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Seasonal Cards
            _buildSeasonalCards(context),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLandDetailsCard(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy', 'bn_BD');
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withAlpha((0.7 * 255).toInt()),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Land Name
              Text(
                land.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Location
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'অবস্থান',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          land.location,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Area
              Row(
                children: [
                  const Icon(
                    Icons.square_foot,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'আয়তন',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${land.area.toStringAsFixed(2)} একর',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Soil Type (if available)
              if (land.soilType != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.grass,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'মাটির ধরন',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          land.soilType!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              
              // Notes (if available)
              if (land.notes != null) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white38),
                const SizedBox(height: 12),
                const Text(
                  'নোট',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  land.notes!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              const Divider(color: Colors.white38),
              const SizedBox(height: 8),
              
              // Created date
              Text(
                'যোগ করা হয়েছে: ${dateFormat.format(land.createdAt)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSeasonalCards(BuildContext context) {
    // Bangladesh seasons
    final seasons = [
      {'name': 'গ্রীষ্ম', 'icon': '☀️', 'months': 'বৈশাখ - জ্যৈষ্ঠ', 'color': Colors.orange},
      {'name': 'বর্ষা', 'icon': '🌧️', 'months': 'আষাঢ় - শ্রাবণ', 'color': Colors.blue},
      {'name': 'শরৎ', 'icon': '🌤️', 'months': 'ভাদ্র - আশ্বিন', 'color': Colors.cyan},
      {'name': 'হেমন্ত', 'icon': '🌾', 'months': 'কার্তিক - অগ্রহায়ণ', 'color': Colors.amber},
      {'name': 'শীত', 'icon': '❄️', 'months': 'পৌষ - মাঘ', 'color': Colors.blueGrey},
      {'name': 'বসন্ত', 'icon': '🌸', 'months': 'ফাল্গুন - চৈত্র', 'color': Colors.pink},
    ];
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: seasons.length,
      itemBuilder: (context, index) {
        final season = seasons[index];
        return SeasonalInfoCard(
          landId: land.id,
          seasonName: season['name'] as String,
          seasonIcon: season['icon'] as String,
          seasonMonths: season['months'] as String,
          seasonColor: season['color'] as Color,
        );
      },
    );
  }
}
