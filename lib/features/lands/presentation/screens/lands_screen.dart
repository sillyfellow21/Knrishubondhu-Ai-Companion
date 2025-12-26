import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/lands_providers.dart';
import '../providers/lands_state.dart';
import '../widgets/land_card.dart';

/// All Lands Screen
class LandsScreen extends ConsumerStatefulWidget {
  const LandsScreen({super.key});
  
  @override
  ConsumerState<LandsScreen> createState() => _LandsScreenState();
}

class _LandsScreenState extends ConsumerState<LandsScreen> {
  @override
  void initState() {
    super.initState();
    // Load lands on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(landsViewModelProvider.notifier).loadLands();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final landsState = ref.watch(landsViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'সব জমির তথ্য',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(landsViewModelProvider.notifier).refresh();
            },
            tooltip: 'রিফ্রেশ করুন',
          ),
        ],
      ),
      body: _buildBody(landsState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLandDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('জমি যোগ করুন'),
      ),
    );
  }
  
  Widget _buildBody(LandsState state) {
    if (state is LandsLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'জমির তথ্য লোড হচ্ছে...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    if (state is LandsError) {
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
                  ref.read(landsViewModelProvider.notifier).refresh();
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
    
    if (state is LandsEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.landscape_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'কোনো জমি যোগ করা হয়নি',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'নতুন জমি যোগ করতে নিচের বাটনে ক্লিক করুন',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (state is LandsLoaded) {
      return RefreshIndicator(
        onRefresh: () async {
          await ref.read(landsViewModelProvider.notifier).refresh();
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: state.lands.length,
          itemBuilder: (context, index) {
            final land = state.lands[index];
            return LandCard(
              land: land,
              onView: () => context.push('/land-details', extra: land),
              onDelete: () => _deleteLand(land.id),
            );
          },
        ),
      );
    }
    
    return const Center(
      child: Text('জমির তথ্য পাওয়া যায়নি'),
    );
  }
  
  void _showAddLandDialog(BuildContext context) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final areaController = TextEditingController();
    final soilTypeController = TextEditingController();
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('নতুন জমি যোগ করুন'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'জমির নাম *',
                  hintText: 'উদাহরণ: উত্তর পাড়ার জমি',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'অবস্থান *',
                  hintText: 'উদাহরণ: গ্রাম - পাড়া',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: areaController,
                decoration: const InputDecoration(
                  labelText: 'আয়তন (একর) *',
                  hintText: 'উদাহরণ: 2.5',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: soilTypeController,
                decoration: const InputDecoration(
                  labelText: 'মাটির ধরন',
                  hintText: 'উদাহরণ: দোআঁশ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'নোট',
                  hintText: 'অতিরিক্ত তথ্য',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final location = locationController.text.trim();
              final areaText = areaController.text.trim();
              
              if (name.isEmpty || location.isEmpty || areaText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('সব প্রয়োজনীয় তথ্য পূরণ করুন')),
                );
                return;
              }
              
              final area = double.tryParse(areaText);
              if (area == null || area <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('সঠিক আয়তন লিখুন')),
                );
                return;
              }
              
              Navigator.pop(context);
              
              final success = await ref.read(landsViewModelProvider.notifier).addLand(
                name: name,
                location: location,
                area: area,
                soilType: soilTypeController.text.trim().isEmpty 
                    ? null 
                    : soilTypeController.text.trim(),
                notes: notesController.text.trim().isEmpty 
                    ? null 
                    : notesController.text.trim(),
              );
              
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('জমি সফলভাবে যোগ করা হয়েছে')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('জমি যোগ করতে ব্যর্থ হয়েছে')),
                );
              }
            },
            child: const Text('যোগ করুন'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteLand(String landId) async {
    final success = await ref.read(landsViewModelProvider.notifier).deleteLand(landId);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('জমি সফলভাবে মুছে ফেলা হয়েছে')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('জমি মুছে ফেলতে ব্যর্থ হয়েছে')),
      );
    }
  }
}
