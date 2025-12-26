import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/forum_providers.dart';
import '../providers/forum_state.dart';
import '../widgets/forum_post_card.dart';

class ForumScreen extends ConsumerStatefulWidget {
  const ForumScreen({super.key});
  
  @override
  ConsumerState<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(forumViewModelProvider.notifier).loadPosts();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final forumState = ref.watch(forumViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('কৃষক ফোরাম', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(forumViewModelProvider.notifier).refresh(),
            tooltip: 'রিফ্রেশ করুন',
          ),
        ],
      ),
      body: _buildBody(forumState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPostDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('নতুন পোস্ট'),
      ),
    );
  }
  
  Widget _buildBody(ForumState state) {
    if (state is ForumLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('পোস্ট লোড হচ্ছে...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }
    
    if (state is ForumError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.read(forumViewModelProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('আবার চেষ্টা করুন'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (state is ForumEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.forum_outlined, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'এখনো কোনো পোস্ট নেই',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'প্রথম পোস্ট করতে নিচের বাটনে ক্লিক করুন',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }
    
    if (state is ForumLoaded) {
      return RefreshIndicator(
        onRefresh: () async => await ref.read(forumViewModelProvider.notifier).refresh(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: state.posts.length,
          itemBuilder: (context, index) {
            return ForumPostCard(post: state.posts[index]);
          },
        ),
      );
    }
    
    return const Center(child: Text('পোস্টের তথ্য পাওয়া যায়নি'));
  }
  
  void _showAddPostDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('নতুন পোস্ট'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'শিরোনাম *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'বিবরণ *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
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
              if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('সব তথ্য পূরণ করুন')),
                );
                return;
              }
              
              Navigator.pop(context);
              
              final success = await ref.read(forumViewModelProvider.notifier).addPost(
                title: titleController.text,
                description: descriptionController.text,
              );
              
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('পোস্ট সফলভাবে যোগ করা হয়েছে')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('পোস্ট যোগ করতে ব্যর্থ হয়েছে')),
                );
              }
            },
            child: const Text('পোস্ট করুন'),
          ),
        ],
      ),
    );
  }
}
