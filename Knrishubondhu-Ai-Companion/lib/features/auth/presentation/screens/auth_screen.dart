import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/auth_view_model.dart';
import '../widgets/auth_text_field.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = ref.read(authViewModelProvider.notifier);
    final isSignUpMode = ref.read(authViewModelProvider).isSignUpMode;

    bool success;

    if (isSignUpMode) {
      success = await authViewModel.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim().isEmpty
            ? null
            : _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );
      // After signup, always go to profile setup
      if (success && mounted) {
        context.go('/profile-setup');
      }
    } else {
      success = await authViewModel.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // After login, check if profile exists
      if (success && mounted) {
        final authState = ref.read(authViewModelProvider);
        final currentUser = authState.user;

        if (currentUser != null) {
          // Check if user has a profile
          final getProfileUseCase = ref.read(getProfileUseCaseProvider);
          final profileResult = await getProfileUseCase(currentUser.id);

          profileResult.fold(
            (failure) {
              // On error, go to profile setup to be safe
              if (mounted) context.go('/profile-setup');
            },
            (profile) {
              if (mounted) {
                if (profile == null) {
                  // No profile exists, go to profile setup
                  context.go('/profile-setup');
                } else {
                  // Profile exists, go to home
                  context.go('/');
                }
              }
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final theme = Theme.of(context);

    // Show error message if any
    ref.listen<String?>(
      authViewModelProvider.select((state) => state.errorMessage),
      (previous, next) {
        if (next != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          ref.read(authViewModelProvider.notifier).clearError();
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo
                Icon(
                  Icons.agriculture_rounded,
                  size: 80,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 16),

                // App Title
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
                  authState.isSignUpMode
                      ? 'নতুন অ্যাকাউন্ট তৈরি করুন'
                      : 'আপনার অ্যাকাউন্টে প্রবেশ করুন',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Full Name Field (Sign Up only)
                if (authState.isSignUpMode) ...[
                  AuthTextField(
                    controller: _fullNameController,
                    label: 'পুরো নাম',
                    prefixIcon: Icons.person_outline,
                    validator: authState.isSignUpMode
                        ? (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'নাম লিখুন';
                            }
                            return null;
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],

                // Phone Number Field (Sign Up only)
                if (authState.isSignUpMode) ...[
                  AuthTextField(
                    controller: _phoneController,
                    label: 'ফোন নম্বর (ঐচ্ছিক)',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                ],

                // Email Field
                AuthTextField(
                  controller: _emailController,
                  label: 'ইমেইল',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'ইমেইল লিখুন';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'সঠিক ইমেইল ঠিকানা দিন';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password Field
                AuthTextField(
                  controller: _passwordController,
                  label: 'পাসওয়ার্ড',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'পাসওয়ার্ড লিখুন';
                    }
                    if (value.length < 6) {
                      return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleSubmit,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            authState.isSignUpMode
                                ? 'সাইন আপ করুন'
                                : 'লগইন করুন',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Toggle Mode Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      authState.isSignUpMode
                          ? 'ইতিমধ্যে অ্যাকাউন্ট আছে? '
                          : 'নতুন ব্যবহারকারী? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () {
                              ref
                                  .read(authViewModelProvider.notifier)
                                  .toggleMode();
                            },
                      child: Text(
                        authState.isSignUpMode ? 'লগইন করুন' : 'সাইন আপ করুন',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
