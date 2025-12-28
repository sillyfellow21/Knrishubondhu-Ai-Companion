import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_view_model.dart';
import '../providers/profile_setup_view_model.dart';
import '../widgets/profile_text_field.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _landAmountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _landAmountController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = ref.read(authViewModelProvider);
    final currentUser = authState.user;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ব্যবহারকারী তথ্য পাওয়া যায়নি'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final profileViewModel = ref.read(profileSetupViewModelProvider.notifier);

    final success = await profileViewModel.saveProfile(
      userId: currentUser.id,
      fullName: _nameController.text.trim(),
      area: _areaController.text.trim(),
      landAmount: double.parse(_landAmountController.text.trim()),
    );

    if (success && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('প্রোফাইল সফলভাবে সংরক্ষিত হয়েছে'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to home screen
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileSetupViewModelProvider);
    final theme = Theme.of(context);

    // Show error message if any
    ref.listen<String?>(
      profileSetupViewModelProvider.select((state) => state.errorMessage),
      (previous, next) {
        if (next != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          ref.read(profileSetupViewModelProvider.notifier).clearError();
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('প্রোফাইল সেটআপ'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Logo
                Icon(
                  Icons.agriculture_rounded,
                  size: 80,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'KrishiBondhu AI',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'আপনার তথ্য দিন',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Name Field
                ProfileTextField(
                  controller: _nameController,
                  label: 'পুরো নাম',
                  hint: 'আপনার নাম লিখুন',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'নাম লিখুন';
                    }
                    if (value.trim().length < 3) {
                      return 'নাম কমপক্ষে ৩ অক্ষরের হতে হবে';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Area Field
                ProfileTextField(
                  controller: _areaController,
                  label: 'এলাকা',
                  hint: 'আপনার এলাকার নাম লিখুন',
                  prefixIcon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'এলাকা লিখুন';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Land Amount Field
                ProfileTextField(
                  controller: _landAmountController,
                  label: 'জমির পরিমাণ (একর)',
                  hint: 'জমির পরিমাণ লিখুন',
                  prefixIcon: Icons.landscape_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'জমির পরিমাণ লিখুন';
                    }
                    final amount = double.tryParse(value.trim());
                    if (amount == null) {
                      return 'সঠিক সংখ্যা দিন';
                    }
                    if (amount <= 0) {
                      return 'জমির পরিমাণ ০ এর চেয়ে বেশি হতে হবে';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: profileState.isLoading ? null : _handleSubmit,
                    child: profileState.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'সংরক্ষণ করুন',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Skip Button
                TextButton(
                  onPressed: profileState.isLoading
                      ? null
                      : () {
                          context.go('/');
                        },
                  child: Text(
                    'পরে করবো',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
