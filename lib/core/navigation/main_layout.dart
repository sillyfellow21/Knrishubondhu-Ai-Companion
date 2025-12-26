import 'package:flutter/material.dart';
import 'app_drawer.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: const AppDrawer(),
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}
