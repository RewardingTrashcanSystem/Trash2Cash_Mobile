// features/history/data/model/history_model.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

class HistoryModel {
  final int id;
  final int points;
  final String action;
  final String description;
  final String? materialType;
  final DateTime createdAt;
  final String formattedDate;
  final String formattedTime;
  final String icon;
  final String color;
  final String? materialDisplay;
  final int? userId; // Make nullable for safety

  HistoryModel({
    required this.id,
    required this.points,
    required this.action,
    required this.description,
    this.materialType,
    required this.createdAt,
    required this.formattedDate,
    required this.formattedTime,
    required this.icon,
    required this.color,
    this.materialDisplay,
    this.userId,
  });
  
  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    // Debug log
    log('Parsing HistoryModel from JSON: ${json.keys.toList()}');
    
    // Parse createdAt - handle different formats
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at']);
    } catch (e) {
      log('Error parsing created_at: ${json['created_at']}, using current time');
      createdAt = DateTime.now();
    }
    
    // Try to get user ID - check different possible field names
    int? userId;
    if (json.containsKey('user')) {
      if (json['user'] is int) {
        userId = json['user'];
      } else if (json['user'] is Map<String, dynamic>) {
        userId = json['user']['id'];
      }
    }
    
    return HistoryModel(
      id: json['id'] ?? 0,
      points: json['points'] ?? 0,
      action: json['action'] ?? 'unknown',
      description: json['description'] ?? '',
      materialType: json['material_type'],
      createdAt: createdAt,
      formattedDate: json['formatted_date'] ?? 
        createdAt.toLocal().toString().split(' ')[0],
      formattedTime: json['formatted_time'] ?? 
        createdAt.toLocal().toString().split(' ')[1].substring(0, 5),
      icon: json['icon'] ?? 'history',
      color: json['color'] ?? 'gray',
      materialDisplay: json['material_display'],
      userId: userId,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points,
      'action': action,
      'description': description,
      'material_type': materialType,
      'created_at': createdAt.toIso8601String(),
      'formatted_date': formattedDate,
      'formatted_time': formattedTime,
      'icon': icon,
      'color': color,
      'material_display': materialDisplay,
      'user': userId,
    };
  }
  
  // Helper getters for UI
  String get pointsWithPrefix {
    if (action == 'transfer_out') {
      return '-$points';
    } else if (action == 'transfer_in') {
      return '+$points';
    }
    return '+$points';
  }
  
  Color get pointsColor {
    if (action == 'transfer_out') {
      return Colors.red;
    } else if (action == 'transfer_in') {
      return Colors.green;
    }
    return Colors.blue;
  }
  
  IconData get iconData {
    switch (icon) {
      case 'send':
        return Icons.send;
      case 'receipt':
        return Icons.receipt;
      case 'qr_code_scanner':
        return Icons.qr_code_scanner;
      default:
        return Icons.history;
    }
  }
  
  Color get colorValue {
    switch (color) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  bool belongsToUser(int currentUserId) {
    return userId == currentUserId;
  }
  
  @override
  String toString() {
    return 'HistoryModel(id: $id, action: $action, points: $points, user: $userId)';
  }
}