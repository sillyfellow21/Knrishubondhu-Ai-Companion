import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Navigation Menu Item
class NavigationMenuItem extends Equatable {
  final String id;
  final String title;
  final IconData icon;
  final String route;

  const NavigationMenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
  });

  @override
  List<Object?> get props => [id, title, icon, route];
}

/// Navigation Menu Items
class NavigationMenuItems {
  static const home = NavigationMenuItem(
    id: 'home',
    title: 'হোম',
    icon: Icons.home_outlined,
    route: '/',
  );

  static const profile = NavigationMenuItem(
    id: 'profile',
    title: 'প্রোফাইল',
    icon: Icons.person_outline,
    route: '/profile',
  );

  static const chatbot = NavigationMenuItem(
    id: 'chatbot',
    title: 'চ্যাটবট',
    icon: Icons.chat_bubble_outline,
    route: '/chatbot',
  );

  static const weather = NavigationMenuItem(
    id: 'weather',
    title: 'আবহাওয়া',
    icon: Icons.wb_sunny_outlined,
    route: '/weather',
  );

  static const lands = NavigationMenuItem(
    id: 'lands',
    title: 'সব জমির তথ্য',
    icon: Icons.landscape_outlined,
    route: '/lands',
  );

  static const cropCalendar = NavigationMenuItem(
    id: 'crop-calendar',
    title: 'ফসল ক্যালেন্ডার',
    icon: Icons.calendar_today_outlined,
    route: '/crop-calendar',
  );

  static const loans = NavigationMenuItem(
    id: 'loans',
    title: 'ঋণ হিসাব',
    icon: Icons.account_balance_wallet_outlined,
    route: '/loans',
  );

  static const forum = NavigationMenuItem(
    id: 'forum',
    title: 'কৃষক ফোরাম',
    icon: Icons.forum_outlined,
    route: '/forum',
  );

  static const List<NavigationMenuItem> allItems = [
    home,
    profile,
    chatbot,
    weather,
    lands,
    cropCalendar,
    loans,
    forum,
  ];
}
