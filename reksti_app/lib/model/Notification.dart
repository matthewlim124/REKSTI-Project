import 'package:flutter/material.dart';

class NotificationItem {
  final int id;
  final String shipmentCode;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final String
  appName; // Kept for UI consistency, can be made dynamic if API provides
  final IconData icon; // Kept for UI, can be made dynamic

  NotificationItem({
    required this.id,
    required this.shipmentCode,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.appName = "SIMILIKITI", // Default app name
    this.icon = Icons.notifications_active_outlined, // Default icon
  });

  // factory NotificationItem.fromjson(Map<String, dynamic> json) {
  //   // int id = json["id"] as int;
  //   // String shipmentCode = json["shipmentCode"] as String;
  //   // String message = json["message"] as String;
  //   // bool isRead = json["isRead"] as bool;
  //   // DateTime createdAt = DateTime.parse(json["createdAt"] as String);

  //   // return NotificationItem(
  //   //   id: id,
  //   //   shipmentCode: shipmentCode,
  //   //   message: message,
  //   //   isRead: isRead,
  //   //   createdAt: createdAt,
  //   // );

  // }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    // DateTime parsedDate;
    // try {
    //   parsedDate = DateTime.parse(json['created_at'] as String);
    // } catch (e) {
    //   print("Error parsing date: ${json['created_at']}. Using current date.");
    //   parsedDate = DateTime.now(); // Fallback
    // }

    // Determine icon based on message or status (example)
    IconData displayIcon = Icons.info_outline;
    if (json['message'] != null) {
      String lcMessage = (json['message'] as String).toLowerCase();
      if (lcMessage.contains("diterima")) {
        displayIcon = Icons.check_circle_outline;
      } else if (lcMessage.contains("dikirim")) {
        displayIcon = Icons.local_shipping_outlined;
      } else if (lcMessage.contains("gagal")) {
        displayIcon = Icons.error_outline;
      }
    }

    return NotificationItem(
      id: json['id'] as int? ?? 0,
      shipmentCode: json['shipment_code'] as String? ?? 'N/A',
      message: json['message'] as String? ?? 'Tidak ada pesan.',
      isRead: json['read'] as bool? ?? false,
      createdAt: json['created_at'] as DateTime?,
      icon: displayIcon, // Assign determined icon
      // appName could also come from json if available: json['app_name'] ?? "Nama Aplikasi"
    );
  }
}
