import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation State Provider
final navigationStateProvider = StateNotifierProvider<NavigationStateNotifier, String>((ref) {
  return NavigationStateNotifier();
});

/// Navigation State Notifier
class NavigationStateNotifier extends StateNotifier<String> {
  NavigationStateNotifier() : super('chatbot'); // Default to chatbot

  /// Set active menu item
  void setActiveItem(String itemId) {
    state = itemId;
  }

  /// Check if item is active
  bool isActive(String itemId) {
    return state == itemId;
  }
}
