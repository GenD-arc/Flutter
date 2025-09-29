import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserUtils {
  static String getUserInitials(String name) {
    final words = name.trim().split(' ').where((word) => word.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words.last[0]).toUpperCase();
  }

  static List<Color> getUserGradientColors(String roleType) {
    switch (roleType) {
      case 'User':
      case 'Organization':
      case 'Adviser':
      case 'Staff':
        return [Colors.green, Colors.greenAccent];
      case 'Admin':
        return [Colors.blue, Colors.blueAccent];
      case 'Super Admin':
        return [Colors.red, Colors.redAccent];
      default:
        return [Colors.grey, Colors.grey[400]!];
    }
  }

  static List<Color> getRoleBadgeColors(String roleType) {
    switch (roleType) {
      case 'User':
      case 'Organization':
      case 'Adviser':
      case 'Staff':
        return [Colors.green[700]!, Colors.green[500]!];
      case 'Admin':
        return [Colors.blue[700]!, Colors.blue[500]!];
      case 'Super Admin':
        return [Colors.red[700]!, Colors.red[500]!];
      default:
        return [Colors.grey[700]!, Colors.grey[500]!];
    }
  }

 static Map<String, int> getUserRoleCounts(List<User> users) {
  final counts = {
    'all': users.length,
    'User': 0,
    'Admin': 0,
    'Super Admin': 0,
    'Archived': 0,
  };

  for (var user in users) {
    if (!user.active) {
      // inactive users go to archived
      counts['Archived'] = counts['Archived']! + 1;
    } else {
      // active users count by role
      if (user.roleType == 'User' ||
          user.roleType == 'Organization' ||
          user.roleType == 'Adviser' ||
          user.roleType == 'Staff') {
        counts['User'] = counts['User']! + 1;
      } else if (counts.containsKey(user.roleType)) {
        counts[user.roleType] = counts[user.roleType]! + 1;
      }
    }
  }

  return counts;
}

}