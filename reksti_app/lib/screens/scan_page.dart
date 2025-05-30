import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reksti_app/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:reksti_app/screens/home_page.dart';
import 'package:reksti_app/screens/profile_page.dart';
import 'package:reksti_app/screens/nfc_display_page.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // Set initial index to 1 for Scan page
  int _bottomNavIndex = 1;
  ValueNotifier<String> result = ValueNotifier(
    "Dekatkan perangkat ke tag NFC...",
  );
  bool _isScanning = false;
  NFCAvailability _nfcAvailability = NFCAvailability.not_supported;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  Future<void> _checkNfcAvailability() async {
    try {
      NFCAvailability availability = await FlutterNfcKit.nfcAvailability;
      if (mounted) {
        setState(() {
          _nfcAvailability = availability;
        });
      }
    } catch (e) {
      print("Error checking NFC availability: $e");
      if (mounted) {
        setState(() {
          _nfcAvailability = NFCAvailability.not_supported;
          result.value = "Error memeriksa NFC: ${e.toString()}";
        });
      }
    }
  }

  Future<void> _startNfcScan() async {
    if (_nfcAvailability != NFCAvailability.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'NFC tidak tersedia atau tidak aktif (${_nfcAvailability.name}).',
          ),
        ),
      );
      return;
    }
    if (_isScanning) {
      print("Scan already in progress");
      return;
    }

    setState(() {
      _isScanning = true;
      result.value = "Mendekati tag NFC...";
    });

    try {
      // Poll for NFC tags. Timeout is optional.
      // The poll method will show a system UI on iOS.
      NFCTag tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 20), // Optional: Timeout for polling
        iosAlertMessage:
            "Dekatkan iPhone ke tag NFC", // iOS specific alert message
      );

      if (mounted) {
        setState(() {
          result.value =
              "Tag terdeteksi!\nID: ${tag.id}\nType: ${tag.type}\nStandard: ${tag.standard}";
          // You can inspect tag.ndefAvailable, tag.ndefWritable etc.
        });
      }

      if (tag.ndefAvailable ?? false) {
        String ndefRecordsText = "Data NDEF:\n";
        // Read NDEF records
        // readNdefRecords() tries to parse known record types (Text, URI)
        // readNdefRecordsRaw() gives you raw NdefRecord objects
        var ndefRecords = await FlutterNfcKit.readNDEFRecords(
          cached: false,
        ); // read cached=false for fresh read

        if (ndefRecords.isEmpty) {
          ndefRecordsText +=
              "Tidak ada record NDEF yang dapat dibaca atau tag kosong.";
        }

        for (var record in ndefRecords) {
          print("Record: ${record.toString()}");
          ndefRecordsText +=
              "${record.toString()}\n"; // A more detailed string representation
        }
        if (mounted) {
          setState(() {
            result.value = ndefRecordsText;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            result.value +=
                "\nTag tidak mendukung NDEF atau tidak ada data NDEF.";
          });
        }
      }
    } on PlatformException catch (e) {
      // Handle specific platform exceptions (e.g., user cancelled)
      print("NFC Polling Error (PlatformException): ${e.message}");
      if (mounted) {
        setState(() {
          result.value =
              "Error NFC: ${e.message ?? 'Operasi dibatalkan atau gagal.'}";
        });
      }
    } catch (e) {
      print("NFC Polling Error (General Exception): $e");
      if (mounted) {
        setState(() {
          result.value = "Error NFC: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
      // On iOS, it's important to finish the session to dismiss the system UI
      // On Android, this might not be strictly necessary after a single poll,
      // but it's good practice if you're done with NFC for now.
      // await FlutterNfcKit.finish(iosAlertMessage: "Selesai", iosErrorMessage: "Gagal");
      // For continuous scanning, you might not call finish here but in dispose or a stop button.
      // Since poll() is a one-shot scan, session might be implicitly finished.
      // Let's explicitly finish on iOS if an error occurs or tag is read.
      // The example for flutter_nfc_kit usually shows finish being called after an operation.
      try {
        // It is important to call `finish` always after `poll`
        // if `IOSAlertMessage` is used, to close the native NFC UI on iOS
        await FlutterNfcKit.finish(iosAlertMessage: "Sesi NFC Selesai.");
      } catch (e) {
        print("Error finishing NFC session: $e");
      }
    }
  }

  @override
  void dispose() {
    // It's good practice to ensure NFC resources are released if your app
    // was actively managing a session (less critical for one-shot poll).
    // FlutterNfcKit.finish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // To see the Stack background

      body: Stack(
        // Stack is the direct child of the Scaffold's body
        children: <Widget>[
          // 1. Your Decorative Background Image (Bottom Layer)
          Positioned(
            top: 0, // Align to the top
            left: 0, // Align to the left
            child: Opacity(
              // Optional: if you want it to be slightly transparent
              opacity: 0.5, // Adjust opacity value (0.0 to 1.0)
              child: Image.asset(
                'assets/images/home_img1.png', // YOUR IMAGE PATH
                width: screenSize.width * 0.6, // Example: 60% of screen width
                // height: screenSize.height * 0.4, // Example: 40% of screen height
                fit: BoxFit.contain,
                alignment: Alignment.topLeft,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink(); // Don't show anything if image fails to load
                },
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (
                BuildContext context,
                BoxConstraints viewportConstraints,
              ) {
                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            viewportConstraints
                                .maxHeight, // Ensure content area can be at least as tall as viewport
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 20.0,
                        ), // Adjusted vertical padding
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center, // Vertically center the content
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .center, // Horizontally center children
                          children: [
                            // SizedBox(height: screenSize.height * 0.05), // Top space, can be adjusted or removed
                            Text(
                              'Panduan Melakukan\nPindahan Tags NFC',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.04,
                            ), // Space between title and card
                            _buildInstructionCard(),
                            SizedBox(
                              height: screenSize.height * 0.025,
                            ), // Bottom space, can be adjusted or removed

                            if (_nfcAvailability == NFCAvailability.available)
                              ElevatedButton.icon(
                                icon: Icon(
                                  _isScanning
                                      ? Icons.stop_circle_outlined
                                      : Icons.nfc,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  _isScanning
                                      ? 'Membaca Tag...'
                                      : 'Mulai Pindai NFC',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _isScanning
                                          ? Colors.orangeAccent[400]
                                          : Colors.deepPurple[400],
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                onPressed:
                                    _isScanning
                                        ? null
                                        : _startNfcScan, // Disable button while scanning
                              )
                            else
                              Text(
                                "NFC Status: ${_nfcAvailability.name.replaceAll('_', ' ')}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red[700],
                                ),
                              ),
                            const SizedBox(height: 20),
                            ValueListenableBuilder<String>(
                              valueListenable: result,
                              builder: (context, value, child) {
                                if (value.isEmpty ||
                                    value ==
                                            "Dekatkan perangkat ke tag NFC..." &&
                                        !_isScanning) {
                                  // Don't show the box if initial message or empty and not scanning
                                  return Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      value.isEmpty && !_isScanning
                                          ? "Hasil scan akan muncul di sini."
                                          : value,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  );
                                }
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.only(
                                    top: 8.0,
                                    bottom: 20.0,
                                  ), // Added bottom margin
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.25),
                                        spreadRadius: 1,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    value,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      decoration: BoxDecoration(
        color: Color(0xFFE8CDFD).withOpacity(0.10), // Semi-transparent white
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Column(
        children: [
          _buildInstructionStep(
            icon: Icons.nfc, // Material icon for NFC
            text: 'Aktifkan NFC pada perangkat \nAnda lewat Settings',
          ),
          SizedBox(height: 30),
          _buildInstructionStep(
            icon: Icons.discount, // Material icon for Tag
            text:
                'Letakkan bagian belakang \nperangkat pada tag NFC \nyang ingin dibaca.',
          ),
          SizedBox(height: 30),
          _buildInstructionStep(
            icon: Icons.article, // Material icon for Document/List
            text: 'Baca informasi yang \nterkandung dalam tag \ntersebut',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep({required IconData icon, required String text}) {
    return Column(
      children: [
        Icon(
          icon,
          size: 48,
          color: Color(0xFFB379DF), // Light purple icon color from image
        ),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF594A75), // Darker purple text for instructions
            height: 1.4,
          ),
        ),
      ],
    );
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
                setState(() => _bottomNavIndex = 1);
              },
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Container(),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                // setState(() => _bottomNavIndex = 2);
                Navigator.push(
                  // Or Navigator.push if you want 'back' functionality
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ), // Navigate to your actual ProfilePage
                );
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
