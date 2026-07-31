import 'package:flutter/material.dart';

class NotificationService extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Dynamic notifications list
  final List<String> _notifications = [
    'Welcome to Smart Admin Dashboard Suite v1.2'
  ];

  List<String> get notifications => _notifications;
  int get unreadCount => _notifications.length;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Naya alert add karne ka method
  void checkAndAddAlert(String productName, int stock) {
    if (stock <= 10) {
      _notifications.insert(0, 'Alert: "$productName" is running low on stock ($stock left)!');
      notifyListeners(); // UI ko instantly notify karega red badge ke liye
    }
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
