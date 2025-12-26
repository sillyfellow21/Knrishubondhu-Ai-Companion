import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/main_layout.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return MainLayout(
      title: 'হোম',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withAlpha((0.7 * 255).toInt()),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'স্বাগতম কৃষিবন্ধু AI তে',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'আপনার কৃষি সহায়ক',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Features Grid
            Text(
              'ফিচার সমূহ',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _FeatureCard(
                  icon: Icons.chat_bubble_outline,
                  title: 'AI চ্যাটবট',
                  subtitle: 'কৃষি পরামর্শ',
                  color: Colors.blue,
                  onTap: () => context.go('/chatbot'),
                ),
                _FeatureCard(
                  icon: Icons.cloud_outlined,
                  title: 'আবহাওয়া',
                  subtitle: 'পূর্বাভাস',
                  color: Colors.orange,
                  onTap: () => context.go('/weather'),
                ),
                _FeatureCard(
                  icon: Icons.landscape_outlined,
                  title: 'জমির তথ্য',
                  subtitle: 'ব্যবস্থাপনা',
                  color: Colors.green,
                  onTap: () => context.go('/lands'),
                ),
                _FeatureCard(
                  icon: Icons.calendar_month_outlined,
                  title: 'ফসল ক্যালেন্ডার',
                  subtitle: 'সময়সূচী',
                  color: Colors.teal,
                  onTap: () => context.go('/crop-calendar'),
                ),
                _FeatureCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'ঋণ ট্র্যাকার',
                  subtitle: 'হিসাব রাখুন',
                  color: Colors.purple,
                  onTap: () => context.go('/loans'),
                ),
                _FeatureCard(
                  icon: Icons.forum_outlined,
                  title: 'কৃষক ফোরাম',
                  subtitle: 'সম্প্রদায়',
                  color: Colors.indigo,
                  onTap: () => context.go('/forum'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
