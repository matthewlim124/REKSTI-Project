import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Import Provider

import 'dart:math' as math; // For PI
import 'dart:io';
import 'package:reksti_app/user_provider.dart';

import 'package:reksti_app/services/token_service.dart';

import 'package:reksti_app/screens/login_page.dart';
import 'package:reksti_app/screens/home_page.dart';
import 'package:reksti_app/screens/scan_page.dart';
import 'package:reksti_app/screens/syarat_page.dart';
import 'package:reksti_app/screens/privacy_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Set initial index to 2 for Profile page
  int _bottomNavIndex = 2;
  // MODIFIED: State variables for profile data

  final TokenStorageService tokenStorage = TokenStorageService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _triggerPickProfileImage() async {
    // Call the provider's method to handle image picking and state update
    await Provider.of<UserProvider>(
      context,
      listen: false,
    ).pickAndSaveProfileImage();
    // Optionally show a SnackBar from here if pickAndSaveProfileImage doesn't,
    // or if it returns a status.
  }

  Widget _buildImagePlaceholder({
    double? width,
    double? height,
    IconData icon = Icons.image,
    Color backgroundColor = const Color(0xFFE0E0E0), // Slightly darker grey
    Color iconColor = const Color(0xFF9E9E9E),
  }) {
    double concreteIconSize;

    // Determine a finite size for the icon
    if (width != null && width.isFinite && width > 0) {
      concreteIconSize = width / 3.5; // Make icon smaller relative to width
    } else if (height != null && height.isFinite && height > 0) {
      concreteIconSize = height / 3.5; // Or base it on height
    } else {
      concreteIconSize = 24.0; // Default fallback size
    }
    // Ensure the icon size is not excessively large if container is huge but unconstrained
    concreteIconSize = math.min(concreteIconSize, 48.0); // Max icon size
    concreteIconSize = math.max(16.0, concreteIconSize); // Min icon size

    return Container(
      width: width, // Container can still try to match the requested width
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: iconColor, size: concreteIconSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final topSafeAreaPadding = MediaQuery.of(context).padding.top;

    final userProvider = Provider.of<UserProvider>(context);

    return
    // 3. Main Scaffold (Top Layer)
    Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFAF4F5), Color(0xFFFFFFFF)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // To see the Stack background
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          // Use PreferredSize to remove AppBar but keep height for status bar
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle:
                SystemUiOverlayStyle.dark, // For status bar icons
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(
                screenSize,
                topSafeAreaPadding,
                userProvider.isLoadingProfile,
                userProvider.profileRecipientName,
                userProvider.profileRecipientAddress,
                userProvider.profileImageFile,
                userProvider.profileError,
              ),
              _buildProfileMenuList(userProvider),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildProfileHeader(
    Size screenSize,
    double topSafeArea,
    bool isLoading, // From provider
    String? recipientName, // From provider
    String? recipientAddress, // From provider
    File? profileImageFile, // From provider
    String profileError, // From provider
  ) {
    String displayName =
        isLoading && recipientName == null
            ? ""
            : (recipientName ?? "Nama tidak tersedia");
    String displayAddress =
        isLoading && recipientAddress == null
            ? ""
            : (recipientAddress ?? "Alamat tidak tersedia");
    String avatarLetter =
        isLoading || recipientName == null || recipientName.isEmpty
            ? "X"
            : recipientName[0].toUpperCase();

    if (profileError.isNotEmpty && !isLoading) {
      displayName = "Error";
      displayAddress = "Gagal memuat data";
    }

    return Stack(
      clipBehavior: Clip.none,
      // alignment: Alignment.topLeft,
      children: [
        // Banner Image
        Container(
          height: screenSize.height * 0.22, // Adjust height as needed
          width: double.infinity,
          child: Image.asset(
            // IMPORTANT: Replace with your banner image
            'assets/images/profile_banner.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stacktrace) {
              return _buildImagePlaceholder(
                width: double.infinity,
                height: screenSize.height * 0.22,
                icon: Icons.medical_services_outlined,
              );
            },
          ),
        ),
        // Edit Icon Button

        // Profile Avatar, Name, and Address
        Positioned(
          top:
              screenSize.height * 0.22 -
              50, // (Banner Height - Half of Avatar Height)
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurple[400], // Color from image
                backgroundImage:
                    profileImageFile != null && profileImageFile.existsSync()
                        ? FileImage(profileImageFile)
                        : null,
                child:
                    profileImageFile == null
                        ?
                        // Initial or from user data
                        Text(
                          avatarLetter,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                        : null,
              ),
              const SizedBox(height: 12),
              if (isLoading && recipientName == null)
                CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                )
              else
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    // To prevent overflow if address is long
                    child: Text(
                      displayAddress, // Replace
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenuList(UserProvider userProvider) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 145.0,
            left: 20.0,
            right: 20.0,
            bottom: 20.0,
          ), // Added top padding
          child: Column(
            children: [
              _buildProfileMenuItem(
                icon: Icons.notifications_none_outlined,
                text: 'Notifikasi',
                onTap: () {
                  // TODO: Navigate to Notifikasi page
                  print("Notifikasi tapped");
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.article_outlined, // Or a custom icon
                text: 'Syarat dan Ketentuan',
                onTap: () {
                  // TODO: Navigate to Syarat dan Ketentuan page
                  Navigator.push(
                    // Or Navigator.push if you want 'back' functionality
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SyaratPage(),
                    ), // Navigate to your actual HomePage
                  );
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.shield_outlined, // Or a custom icon
                text: 'Privacy Policy',
                onTap: () {
                  // TODO: Navigate to Privacy Policy page
                  Navigator.push(
                    // Or Navigator.push if you want 'back' functionality
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPage(),
                    ), // Navigate to your actual HomePage
                  );
                },
              ),
              const SizedBox(height: 10), // Spacer
              _buildProfileMenuItem(
                icon: Icons.logout,
                text: 'Keluar',
                isLogout: true, // Special styling for logout
                onTap: () {
                  // TODO: Implement logout functionality
                  print("Keluar tapped");
                  // Example: show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: Text("Konfirmasi Keluar"),
                        content: Text("Apakah Anda yakin ingin keluar?"),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Batal"),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Keluar",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () async {
                              Navigator.of(
                                dialogContext,
                              ).pop(); // Dismiss dialog first

                              // Perform actual logout actions
                              await tokenStorage.deleteAllTokens();
                              await userProvider.clearProfileDataOnLogout();

                              // Navigate to Login Page and remove all previous routes
                              if (mounted) {
                                // Check if _ProfilePageState is still mounted
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ), // Replace with your actual LoginPage
                                  (Route<dynamic> route) =>
                                      false, // Remove all routes
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Positioned(
          // Adjust 'top' to position it relative to the start of the menu list.
          // The Padding widget above has top: 70.0.
          // So, a top value here of around 70 - (buttonHeight/2) would place it near the top edge of the list.
          // Let's try to place it aligned with the top of the first menu item, considering padding.
          // Or, simply from the top of the Stack (which is aligned with the bottom of the header).
          top:
              10, // (padding.top - half of button approx height) to align with top of first item
          right: 10, // Align with the right padding of the menu list
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: Colors.deepPurple[400],
                size: 22,
              ),
              onPressed: () async {
                await _triggerPickProfileImage();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final double borderRadiusValue = 12.0;
    final double borderWidth =
        1.5; // Thickness of the gradient border for non-logout items

    // Content (Row with Icon and Text) will always have this padding
    final EdgeInsets contentPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 14.0,
    );

    Widget itemContent = Padding(
      padding: contentPadding,
      child: Row(
        children: [
          Icon(
            icon,
            color:
                isLogout
                    ? Colors.deepPurple[700]
                    : Colors.deepPurple[400], // Adjusted logout icon color
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isLogout ? Colors.deepPurple[700] : Colors.black87,
              ),
            ),
          ),
          if (!isLogout)
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
        ],
      ),
    );

    if (isLogout) {
      // Logout item: Solid color background
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFCBC6F0), Color(0xFFF1C4E4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadiusValue),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadiusValue),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadiusValue),
            child: itemContent, // Directly use the padded content
          ),
        ),
      );
    } else {
      // Non-logout item: Gradient border, white background inside
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.all(borderWidth), // This padding creates the border
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFCBC6F0), Color(0xFFF1C4E4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadiusValue),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Container(
          // Inner container for white background
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              borderRadiusValue - borderWidth,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(
              borderRadiusValue - borderWidth,
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(
                borderRadiusValue - borderWidth,
              ),
              child: itemContent, // Content is already padded
            ),
          ),
        ),
      );
    }
  }

  // --- Reusing Bottom Navigation Bar from HomePage ---
  Widget _buildBottomNavigationBar() {
    const double barHeight = 160; // Adjust to the actual height of your images
    String currentNavBarImage;

    switch (_bottomNavIndex) {
      case 0: // Home selected
        currentNavBarImage = 'assets/images/navbar1.png';
        break;
      case 1: // Scan selected
        currentNavBarImage = 'assets/images/navbar2.png';
        break;
      case 2: // Profile selected
        currentNavBarImage = 'assets/images/navbar3.png';
        break;
      default:
        currentNavBarImage = 'assets/images/navbar3.png'; // Default
    }

    return Container(
      height: barHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(currentNavBarImage),
          fit: BoxFit.cover, // Or BoxFit.fill, BoxFit.fitWidth
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Make InkWells fill height
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
                // setState(() => _bottomNavIndex = 0);
                Navigator.push(
                  // Or Navigator.push if you want 'back' functionality
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ), // Navigate to your actual HomePage
                );
              },
              splashColor: Colors.white.withOpacity(
                0.1,
              ), // Optional visual feedback
              highlightColor: Colors.white.withOpacity(0.05),
              child:
                  Container(), // Empty container, tap area is the Expanded widget
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                //setState(() => _bottomNavIndex = 1);
                Navigator.push(
                  // Or Navigator.push if you want 'back' functionality
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScanPage(),
                  ), // Navigate to your actual ScanPage
                );
              },
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Container(),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _bottomNavIndex = 2);
              },
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}
