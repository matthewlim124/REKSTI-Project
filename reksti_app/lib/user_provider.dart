import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reksti_app/model/Shipment.dart';
import 'dart:convert'; // For json.decode if you fetch structured data

import 'package:reksti_app/services/token_service.dart';
import 'package:reksti_app/services/logic_service.dart';
// Assuming your Shipment model is defined elsewhere and accessible
// For this example, we'll use a simplified version of what's needed from Shipment
// class Shipment {
//   final String recipientName;
//   final String recipientAddress;
//   Shipment({required this.recipientName, required this.recipientAddress});
//   factory Shipment.fromJson(Map<String, dynamic> json) {
//     return Shipment(
//       recipientName: json['recipient_name']?.toString() ?? 'N/A',
//       recipientAddress: json['recipient_address']?.toString() ?? 'N/A',
//     );
//   }
// }

class UserProvider with ChangeNotifier {
  String? _profileRecipientName;
  String? _profileRecipientAddress;
  File? _profileImageFile;
  bool _isLoadingProfile = false;
  String _profileError = '';
  final _logicService = LogicService();
  List<ShipmentItem> _processedTodayOrders = [];
  bool _isLoadingOrders = false;
  String _orderErrorMessage = '';

  static const String _profileImagePathKey = 'reksti_app/lib/user_images/';
  // Keys for other profile data if you persist them (optional)
  // static const String _profileNameKey = 'user_profile_name';
  // static const String _profileAddressKey = 'user_profile_address';
  bool _hasFetchedInitialData = false; // To prevent multiple initial fetches
  bool _hasFetchedInitialOrders = false;

  String? get profileRecipientName => _profileRecipientName;
  String? get profileRecipientAddress => _profileRecipientAddress;
  File? get profileImageFile => _profileImageFile;
  bool get isLoadingProfile => _isLoadingProfile;
  String get profileError => _profileError;

  List<ShipmentItem> get processedTodayOrders => _processedTodayOrders;
  bool get isLoadingOrders => _isLoadingOrders;
  String get orderErrorMessage => _orderErrorMessage;

  UserProvider() {
    // Load initial data when the provider is first created
    print("UserProvider: Constructor called, calling loadUserData.");
    loadUserData();
  }

  Future<void> loadUserData({bool forceRefresh = false}) async {
    // Prevent multiple loads if already loading or data exists (optional, depends on strategy)
    // if (_isLoadingProfile || _profileRecipientName != null) return;
    if ((_isLoadingProfile || _isLoadingOrders) && !forceRefresh) {
      print(
        "UserProvider: Load already in progress and not forcing refresh. Skipping.",
      );
      return;
    }

    // If data has been successfully fetched once and we are not forcing a refresh, skip.
    if (_hasFetchedInitialData && _hasFetchedInitialOrders && !forceRefresh) {
      print(
        "UserProvider: Data already fetched, not forcing refresh. Ensuring loading flags are false.",
      );
      if (_isLoadingProfile || _isLoadingOrders) {
        // If somehow they were true, reset
        _isLoadingProfile = false;
        _isLoadingOrders = false;
        notifyListeners();
      }
      return;
    }

    _isLoadingProfile = true;
    _isLoadingOrders = true;
    _profileError = '';
    _orderErrorMessage = '';
    notifyListeners(); // Notify listeners that loading has started

    await _loadPersistedProfileImage(); // Load image first

    // Simulate fetching other profile data (name, address)
    // In a real app, this would be an API call.
    try {
      final List<dynamic> rawShipmentData = await _logicService.getOrder();

      final List<Shipment> shipments =
          rawShipmentData.map((data) => Shipment.fromJson(data)).toList();
      List<ShipmentItem> allItems = [];
      for (var shipment in shipments) {
        allItems.addAll(shipment.items);
      }
      _processedTodayOrders = allItems;

      _hasFetchedInitialOrders = true;

      // Assuming the first record contains the relevant profile info
      final Shipment profileShipmentData = Shipment.fromJson(
        rawShipmentData.first as Map<String, dynamic>,
      );

      _profileRecipientName = profileShipmentData.recipientName;
      print("this is from user provider");
      print(_profileRecipientName);
      print(profileRecipientName);
      _profileRecipientAddress = profileShipmentData.recipientAddress;
      _isLoadingProfile = false;
      _hasFetchedInitialData = true;
    } catch (e) {
      _profileError = "Gagal memuat data profil: ${e.toString()}";
      _orderErrorMessage = "Gagal memuat pesanan: ${e.toString()}";
      _hasFetchedInitialData = false;
      _hasFetchedInitialOrders = false;
    } finally {
      _isLoadingProfile = false;
      _isLoadingOrders = false;
      notifyListeners(); // Notify listeners that loading is complete (or failed)
    }
  }

  Future<void> _loadPersistedProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? imagePath = prefs.getString(_profileImagePathKey);
      if (imagePath != null) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          _profileImageFile = imageFile;
        } else {
          await prefs.remove(_profileImagePathKey); // Clean up invalid path
          _profileImageFile = null;
        }
      } else {
        _profileImageFile = null;
      }
    } catch (e) {
      print("Error loading persisted profile image: $e");
      _profileImageFile = null; // Ensure it's null on error
    }
    // notifyListeners(); // Usually called by the wrapping function like loadProfileDataAndImage
  }

  Future<String?> pickAndSaveProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    String? newImagePath;

    if (pickedImage != null) {
      final File imageFile = File(pickedImage.path);
      try {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = p.basename(imageFile.path);
        final String localPath = p.join(appDir.path, fileName);

        final File newImage = await imageFile.copy(localPath);
        print("Image copied to: ${newImage.path}");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_profileImagePathKey, newImage.path);

        _profileImageFile = newImage;
        newImagePath = newImage.path;
        notifyListeners();
        return newImagePath;
      } catch (e) {
        print("Error copying or saving image path: $e");
        _profileError = "Gagal menyimpan gambar: ${e.toString()}";
        notifyListeners();
        return null;
      }
    } else {
      print("No image selected.");
      return null;
    }
  }

  Future<void> clearProfileDataOnLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileImagePathKey);
    // await prefs.remove(_profileNameKey); // If you persist other data
    // await prefs.remove(_profileAddressKey);

    _profileImageFile = null;
    _profileRecipientName = null;
    _profileRecipientAddress = null;
    _profileError = '';
    _isLoadingProfile = false; // Reset loading state
    _hasFetchedInitialData = false;
    _hasFetchedInitialOrders = false;
    print("UserProfileProvider: Profile data cleared for logout.");
    notifyListeners();
  }
}
