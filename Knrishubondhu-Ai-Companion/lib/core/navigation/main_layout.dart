import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_drawer.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBackButton;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.floatingActionButton,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we can go back
    final canGoBack = GoRouter.of(context).canPop();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        leading: canGoBack && showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              )
            : null,
        actions: actions,
      ),
      drawer: const AppDrawer(),
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}
