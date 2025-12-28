import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/forum_post.dart';
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
        title: const Text('কৃষক ফোরাম',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(forumViewModelProvider.notifier).refresh(),
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
                onPressed: () =>
                    ref.read(forumViewModelProvider.notifier).refresh(),
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
        onRefresh: () async =>
            await ref.read(forumViewModelProvider.notifier).refresh(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: state.posts.length,
          itemBuilder: (context, index) {
            final post = state.posts[index];
            return ForumPostCard(
              post: post,
              isOwner: state.currentUserId == post.userId,
              onTap: () => _navigateToPostDetail(context, post),
              onDelete: state.currentUserId == post.userId
                  ? () => _confirmDeletePost(context, post.id)
                  : null,
            );
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
              if (titleController.text.isEmpty ||
                  descriptionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('সব তথ্য পূরণ করুন')),
                );
                return;
              }

              Navigator.pop(context);

              final success =
                  await ref.read(forumViewModelProvider.notifier).addPost(
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

  void _navigateToPostDetail(BuildContext context, ForumPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: post),
      ),
    );
  }

  void _confirmDeletePost(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('পোস্ট মুছে ফেলুন'),
        content: const Text('আপনি কি নিশ্চিত যে আপনি এই পোস্ট মুছে ফেলতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(forumViewModelProvider.notifier)
                  .deletePost(postId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'পোস্ট মুছে ফেলা হয়েছে'
                        : 'পোস্ট মুছে ফেলতে ব্যর্থ হয়েছে'),
                  ),
                );
              }
            },
            child: const Text('মুছে ফেলুন'),
          ),
        ],
      ),
    );
  }
}

// Post Detail Screen with Comments
class PostDetailScreen extends ConsumerStatefulWidget {
  final ForumPost post;

  const PostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(postDetailViewModelProvider.notifier)
          .loadPostDetail(widget.post);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postDetailViewModelProvider);
    final dateFormat = DateFormat('d MMM yyyy, h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('পোস্ট বিস্তারিত'),
      ),
      body: _buildBody(state, dateFormat),
    );
  }

  Widget _buildBody(PostDetailState state, DateFormat dateFormat) {
    if (state is PostDetailLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PostDetailError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(postDetailViewModelProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      );
    }

    if (state is PostDetailLoaded) {
      return Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => await ref
                  .read(postDetailViewModelProvider.notifier)
                  .refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Card
                    Card(
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.post.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.post.description,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFF10B981),
                                  child: Text(
                                    state.post.userName.isNotEmpty
                                        ? state.post.userName[0].toUpperCase()
                                        : 'ক',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.post.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        dateFormat.format(state.post.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Comments Section Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.comment,
                              size: 20, color: Color(0xFF10B981)),
                          const SizedBox(width: 8),
                          Text(
                            'মন্তব্য (${state.comments.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(indent: 16, endIndent: 16),

                    // Comments List
                    if (state.comments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'এখনো কোনো মন্তব্য নেই',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.comments.length,
                        itemBuilder: (context, index) {
                          final comment = state.comments[index];
                          final isOwner = state.currentUserId == comment.userId;
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.blue.shade400,
                                        child: Text(
                                          comment.userName.isNotEmpty
                                              ? comment.userName[0]
                                                  .toUpperCase()
                                              : 'ক',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              comment.userName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              dateFormat
                                                  .format(comment.createdAt),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isOwner)
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              size: 18, color: Colors.red),
                                          onPressed: () =>
                                              _confirmDeleteComment(
                                                  context, comment.id),
                                          tooltip: 'মন্তব্য মুছুন',
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    comment.content,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),

          // Comment Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'মন্তব্য লিখুন...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF10B981)),
                    onPressed: _submitComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return const Center(child: Text('তথ্য পাওয়া যায়নি'));
  }

  void _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('মন্তব্য লিখুন')),
      );
      return;
    }

    final success = await ref
        .read(postDetailViewModelProvider.notifier)
        .addComment(content);
    if (success && mounted) {
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('মন্তব্য যোগ করা হয়েছে')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('মন্তব্য যোগ করতে ব্যর্থ হয়েছে')),
      );
    }
  }

  void _confirmDeleteComment(BuildContext context, String commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('মন্তব্য মুছে ফেলুন'),
        content: const Text('আপনি কি নিশ্চিত?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final success = await ref
                  .read(postDetailViewModelProvider.notifier)
                  .deleteComment(commentId);
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'মন্তব্য মুছে ফেলা হয়েছে'
                        : 'মন্তব্য মুছতে ব্যর্থ হয়েছে'),
                  ),
                );
              }
            },
            child: const Text('মুছুন'),
          ),
        ],
      ),
    );
  }
}
