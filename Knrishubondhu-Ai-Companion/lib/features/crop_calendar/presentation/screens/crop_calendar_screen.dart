import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/crop_calendar_providers.dart';
import '../providers/crop_calendar_state.dart';
import '../widgets/season_card.dart';
import '../../domain/entities/season_calendar.dart';

/// Crop Calendar Screen
class CropCalendarScreen extends ConsumerStatefulWidget {
  const CropCalendarScreen({super.key});
  
  @override
  ConsumerState<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends ConsumerState<CropCalendarScreen> {
  @override
  void initState() {
    super.initState();
    // Load seasons on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cropCalendarViewModelProvider.notifier).loadSeasons();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(cropCalendarViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ফসল ক্যালেন্ডার',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(cropCalendarViewModelProvider.notifier).refresh();
            },
            tooltip: 'রিফ্রেশ করুন',
          ),
        ],
      ),
      body: _buildBody(calendarState),
    );
  }
  
  Widget _buildBody(CropCalendarState state) {
    if (state is CropCalendarLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'ফসল ক্যালেন্ডার লোড হচ্ছে...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    if (state is CropCalendarError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(cropCalendarViewModelProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('আবার চেষ্টা করুন'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (state is CropCalendarLoaded) {
      return RefreshIndicator(
        onRefresh: () async {
          await ref.read(cropCalendarViewModelProvider.notifier).refresh();
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: state.seasons.length,
          itemBuilder: (context, index) {
            final season = state.seasons[index];
            return SeasonCard(
              season: season,
              onTap: () => _showSeasonDetails(context, season),
            );
          },
        ),
      );
    }
    
    return const Center(
      child: Text('ফসল ক্যালেন্ডার পাওয়া যায়নি'),
    );
  }
  
  void _showSeasonDetails(BuildContext context, SeasonCalendar season) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Season header
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt()),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          season.icon,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            season.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            season.months,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                // Crops list
                const Text(
                  'এই মৌসুমের ফসল',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                ...season.crops.map((crop) => _buildCropCard(context, crop)).toList(),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCropCard(BuildContext context, crop) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              crop.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.spa, 'রোপণ', crop.plantingMonth),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.event_available, 'সংগ্রহ', crop.harvestMonth),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.schedule, 'সময়কাল', crop.duration),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha((0.05 * 255).toInt()),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withAlpha((0.2 * 255).toInt()),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      crop.tips,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
