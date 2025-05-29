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
  final TokenStorageService tokenStorage = TokenStorageService();

  // Keys for other profile data if you persist them (optional)
  // static const String _profileNameKey = 'user_profile_name';
  // static const String _profileAddressKey = 'user_profile_address';
  bool _hasFetchedInitialData = false; // To prevent multiple initial fetches

  String? get profileRecipientName => _profileRecipientName;
  String? get profileRecipientAddress => _profileRecipientAddress;
  File? get profileImageFile => _profileImageFile;

  bool get isLoadingProfile => _isLoadingProfile;
  String get profileError => _profileError;

  UserProvider() {
    // Load initial data when the provider is first created
    print("UserProvider: Constructor called, calling loadUserData.");
    loadUserData();
  }

  Future<void> loadUserData({bool forceRefresh = false}) async {
    // Prevent multiple loads if already loading or data exists (optional, depends on strategy)
    // if (_isLoadingProfile || _profileRecipientName != null) return;

    if ((_isLoadingProfile) && !forceRefresh) {
      print(
        "UserProvider: Load already in progress and not forcing refresh. Skipping.",
      );
      return;
    }

    // If data has been successfully fetched once and we are not forcing a refresh, skip.
    if (_hasFetchedInitialData && !forceRefresh) {
      print(
        "UserProvider: Data already fetched, not forcing refresh. Ensuring loading flags are false.",
      );
      if (_isLoadingProfile) {
        // If somehow they were true, reset
        _isLoadingProfile = false;

        notifyListeners();
      }
      return;
    }

    _isLoadingProfile = true;

    _profileError = '';

    notifyListeners(); // Notify listeners that loading has started

    // Load image first

    // Simulate fetching other profile data (name, address)
    // In a real app, this would be an API call.
    try {
      final List<dynamic> rawShipmentData = await _logicService.getOrder();

      if (rawShipmentData.isNotEmpty) {
        // Assuming the first record might contain primary user info for profile page
        final Shipment firstShipmentData = Shipment.fromJson(
          rawShipmentData.first as Map<String, dynamic>,
        );

        _profileRecipientAddress = firstShipmentData.recipientAddress;

        // Process all shipments for today's orders list
        final List<Shipment> shipments =
            rawShipmentData.map((data) => Shipment.fromJson(data)).toList();
        List<ShipmentItem> allItems = [];
        for (var shipment in shipments) {
          // You might add a filter here if these are all orders and not just today's
          // e.g., if (isToday(shipment.shippingDate))
          allItems.addAll(shipment.items);
        }
      }
      final List<Shipment> shipments =
          rawShipmentData.map((data) => Shipment.fromJson(data)).toList();
      List<ShipmentItem> allItems = [];
      for (var shipment in shipments) {
        // You might add a filter here if these are all orders and not just today's
        // e.g., if (isToday(shipment.shippingDate))
        allItems.addAll(shipment.items);
      }

      _profileRecipientName = await tokenStorage.getUsername();
      await _loadPersistedProfileImage();
      _hasFetchedInitialData = true;
    } catch (e) {
      _profileError = "Gagal memuat data profil: ${e.toString()}";

      _hasFetchedInitialData = false;
    } finally {
      _isLoadingProfile = false;

      notifyListeners(); // Notify listeners that loading is complete (or failed)
    }
  }

  Future<void> initializeSession() async {
    String? username = await tokenStorage.getUsername();
    print(
      "UserProvider DEBUG: initializeSession - username from tokenStorage: $username",
    );
    if (username != null && username.isNotEmpty) {
      print(
        "UserProvider: Session found for $username. Initializing and loading data.",
      );
      if (_profileRecipientName != username || !_hasFetchedInitialData) {
        await loadUserData(forceRefresh: false);
      } else {
        print(
          "UserProvider: Data for $username already loaded in this session.",
        );
        if (_isLoadingProfile) {
          _isLoadingProfile = false;

          notifyListeners();
        }
      }
    } else {
      print("UserProvider: No active session found on app start.");
      notifyListeners();
    }
  }

  Future<void> _loadPersistedProfileImage() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String userPrefix = "${_profileRecipientName}_";

      List<FileSystemEntity> files = appDir.listSync();
      List<File> userImageFiles = [];

      for (var entity in files) {
        if (entity is File) {
          final String fileName = p.basename(entity.path);
          if (fileName.startsWith(userPrefix) && fileName.endsWith(".jpg")) {
            userImageFiles.add(entity);
          }
        }
      }

      if (userImageFiles.isEmpty) {
        _profileImageFile = null;
        print(
          "UserProvider: No profile images found for user $_profileRecipientName",
        );
        return;
      }

      userImageFiles.sort((a, b) {
        try {
          String tsAString = p
              .basename(a.path)
              .replaceAll(userPrefix, '')
              .replaceAll('.jpg', '');
          String tsBString = p
              .basename(b.path)
              .replaceAll(userPrefix, '')
              .replaceAll('.jpg', '');
          int tsA = int.tryParse(tsAString) ?? 0;
          int tsB = int.tryParse(tsBString) ?? 0;
          return tsB.compareTo(tsA); // Sort descending by timestamp
        } catch (e) {
          return 0;
        }
      });

      _profileImageFile =
          userImageFiles.first; // The one with the latest timestamp
      print(
        "UserProvider: Loaded latest profile image: ${_profileImageFile?.path} for $_profileRecipientName",
      );
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
    final Directory appDir = await getApplicationDocumentsDirectory();

    if (pickedImage != null) {
      final File imageFile = File(pickedImage.path);
      print(imageFile);
      try {
        final String fileName =
            '${_profileRecipientName}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final String localPath = p.join(appDir.path, fileName);

        final File newImage = await imageFile.copy(localPath);
        print("Image copied to: ${newImage.path}");

        // final prefs = await SharedPreferences.getInstance();

        // await prefs.setString(profileImageKey, newImage.path);

        _profileImageFile = newImage;
        newImagePath = newImage.path;
        _profileError = '';

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
    // final String? profileImageKey = _getProfileImageKeyForUser(
    //   usernameToClear,
    //   existinglocalPath,
    // );

    // final prefs = await SharedPreferences.getInstance();
    // if (profileImageKey != null) {
    //   await prefs.remove(profileImageKey);
    //   print(
    //     "UserProvider: Cleared profile image SharedPreferences for key $profileImageKey",
    //   );
    // }
    // await prefs.remove(_profileNameKey); // If you persist other data
    // await prefs.remove(_profileAddressKey);
    await tokenStorage.deleteAllTokens();
    _profileImageFile = null;
    _profileRecipientName = null;
    _profileRecipientAddress = null;
    _profileError = '';
    _isLoadingProfile = false; // Reset loading state
    _hasFetchedInitialData = false;

    print("UserProfileProvider: Profile data cleared for logout.");
    notifyListeners();
  }
}
