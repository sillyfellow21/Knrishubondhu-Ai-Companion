import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/presentation/providers/auth_view_model.dart';
import '../providers/chat_view_model.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_field.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _sessionId = const Uuid().v4();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        ref
            .read(chatViewModelProvider(_sessionId).notifier)
            .setSelectedImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ছবি নির্বাচন করতে ব্যর্থ হয়েছে'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    final authState = ref.read(authViewModelProvider);
    final currentUser = authState.user;

    if (currentUser == null) return;

    final chatState = ref.read(chatViewModelProvider(_sessionId));
    final selectedImage = chatState.selectedImagePath;

    if (message.isEmpty && selectedImage == null) return;

    final chatViewModel = ref.read(chatViewModelProvider(_sessionId).notifier);

    if (selectedImage != null) {
      // Send message with image
      await chatViewModel.sendMessageWithImage(
        userId: currentUser.id,
        message: message,
        imagePath: selectedImage,
      );
    } else {
      // Send text message
      await chatViewModel.sendMessage(
        userId: currentUser.id,
        message: message,
      );
    }

    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider(_sessionId));
    final theme = Theme.of(context);

    // Show error message if any
    ref.listen<String?>(
      chatViewModelProvider(_sessionId).select((state) => state.errorMessage),
      (previous, next) {
        if (next != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          ref.read(chatViewModelProvider(_sessionId).notifier).clearError();
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('চ্যাটবট'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // TODO: Implement clear chat
            },
            tooltip: 'চ্যাট মুছুন',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatState.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'কোনো বার্তা নেই',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'আপনার প্রশ্ন লিখে শুরু করুন',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chatState.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatState.messages[index];
                          return ChatMessageBubble(message: message);
                        },
                      ),
          ),

          // Image Preview (if selected)
          if (chatState.selectedImagePath != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(chatState.selectedImagePath!),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ছবি নির্বাচিত হয়েছে',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      ref
                          .read(chatViewModelProvider(_sessionId).notifier)
                          .setSelectedImage(null);
                    },
                  ),
                ],
              ),
            ),

          // Input Field
          ChatInputField(
            controller: _messageController,
            isSending: chatState.isSending,
            onSend: _sendMessage,
            onPickImage: _pickImage,
          ),
        ],
      ),
    );
  }
}
