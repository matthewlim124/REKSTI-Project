import 'package:flutter/material.dart';
import 'dart:math' as math;

// Placeholder data for products
class Product {
  final String name;
  final String imagePath;

  Product({required this.name, required this.imagePath});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavIndex = 0; // To track selected bottom nav item

  // Mock product data
  final List<Product> _todayOrders = List.generate(
    1, //note: base on how many order there are
    (index) => Product(
      name: 'Get from db',
      // IMPORTANT: Replace with your actual product image path or use a placeholder
      imagePath: 'assets/images/drug.png',
    ),
  );

  // Placeholder widget for image assets
  Widget _buildImagePlaceholder({
    double? width,
    double? height,
    IconData icon = Icons.image,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.grey[600], size: (width ?? 50) / 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background color
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

          // 2. Your Main Page Content, wrapped in SafeArea (Top Layer)
          // This SafeArea is now correctly placed as a child of the Stack
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Assuming these methods are defined in your State class
                    _buildTopHeader(),
                    const SizedBox(height: 25),
                    _buildWelcomeSection(),
                    const SizedBox(height: 25),
                    _buildHistoryCard(),
                    const SizedBox(height: 30),
                    _buildTodayOrdersSection(),
                    const SizedBox(
                      height: 20,
                    ), // Space for bottom nav bar if content is short
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          _buildBottomNavigationBar(), // Correctly placed as a property of Scaffold
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Home',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.grey[700],
                size: 28,
              ),
              // onPressed: () { /* TODO: Notification action */ },
              // OR using an image asset:
              // child: Image.asset('assets/images/icon_bell.png', width: 28, height: 28),
              onPressed: () {},
            ),

            // User Profile Avatar
            // IMPORTANT: Replace with your user profile image
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'get from db', // Replace with dynamic data if needed
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        // Waving Hand Image
        // IMPORTANT: Replace with your waving hand image/emoji
        // For example, an Image.asset or a Text widget with an emoji
        // Image.asset('assets/images/waving_hand.png', width: 40, height: 40),
        Text(
          '👋', // Emoji placeholder
          style: TextStyle(fontSize: 36),
        ),
      ],
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        gradient: LinearGradient(
          colors: [Colors.pink[100]!, Colors.purple[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3, // Give more space to text content
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Histori Pesananmu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cek hasil pesanan yang sudah Anda pindaiin',
                      style: TextStyle(fontSize: 13, color: Colors.purple[700]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to History Page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        'Lihat Histori',
                        style: TextStyle(
                          color: Colors.purple[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(
                flex: 1,
              ), // Spacer to push illustration to the right if needed
            ],
          ),
          Positioned(
            right: -20, // Adjust as needed to position illustration
            top: -10,
            bottom: -10,
            width: MediaQuery.of(context).size.width * 0.25, // Adjust width
            child: Opacity(
              opacity:
                  0.8, // Illustration seems a bit transparent or softly blended
              // IMPORTANT: Replace with your history card illustration
              child: Image.asset(
                'assets/images/home_img.png',
                fit: BoxFit.contain, // or BoxFit.fitHeight
                errorBuilder:
                    (context, error, stacktrace) =>
                        _buildImagePlaceholder(icon: Icons.medical_services),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pesananmu Hari ini',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap:
              true, // Important for GridView inside SingleChildScrollView
          physics:
              const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
          itemCount: _todayOrders.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of items per row
            crossAxisSpacing: 12.0, // Horizontal spacing
            mainAxisSpacing: 12.0, // Vertical spacing
            childAspectRatio: 0.9, // Adjust aspect ratio (width / height)
          ),
          itemBuilder: (context, index) {
            final product = _todayOrders[index];
            return _buildProductCard(product);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              // IMPORTANT: Replace with your product image
              child: Image.asset(
                product.imagePath,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stacktrace) =>
                        _buildImagePlaceholder(icon: Icons.medication),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- DYNAMIC CUSTOM BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNavigationBar() {
    const double barHeight = 80.0;
    const double fabSize = 50.0; // Size of the circular item
    const double fabMargin = 10.0; // Margin for the curve calculation
    // How much the selected item's icon should visually dip into the ravine
    final double enlargedSelectedCircleSize = fabSize * 1.35;
    final double selectedItemLift = enlargedSelectedCircleSize * 0.6;

    return SizedBox(
      height:
          barHeight, // Total height, allowing space for labels below items in ravine
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Custom painted background with dynamic ravine position
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight + 20, // The painted bar itself is this tall
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, barHeight),
              painter: _BottomNavPainter(
                navColor: Color(0xFFBCA0DC), // Light purple from image
                fabSize: enlargedSelectedCircleSize,
                fabMargin: fabMargin,
                selectedIndex: _bottomNavIndex,
                itemCount: 3,
                ravineDepthFactor:
                    0.85, // How deep the ravine is relative to fabRadius
                ravineCurveControlFactor: 0.7,
              ),
            ),
          ),
          // Navigation items in a Row
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight + 2, // Allow space for labels to be fully visible
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start, // Align items to the top of their space
              children: [
                _buildBottomNavItem(
                  icon: Icons.home_filled,
                  label: 'Home',
                  itemIndex: 0,
                  currentIndex: _bottomNavIndex,
                  onTap: () => setState(() => _bottomNavIndex = 0),
                  fabSize: fabSize,
                  enlargedFabSize: enlargedSelectedCircleSize,
                  selectedItemLift: selectedItemLift,
                ),
                _buildBottomNavItem(
                  icon: Icons.qr_code_scanner,
                  label: 'Scan',
                  itemIndex: 1,
                  currentIndex: _bottomNavIndex,
                  onTap: () => setState(() => _bottomNavIndex = 1),
                  fabSize: fabSize,
                  enlargedFabSize: enlargedSelectedCircleSize,
                  selectedItemLift: selectedItemLift,
                ),
                _buildBottomNavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  itemIndex: 2,
                  currentIndex: _bottomNavIndex,
                  onTap: () => setState(() => _bottomNavIndex = 2),
                  fabSize: fabSize,
                  enlargedFabSize: enlargedSelectedCircleSize,
                  selectedItemLift: selectedItemLift,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int itemIndex,
    required int currentIndex,
    required VoidCallback onTap,
    required double fabSize,
    required double enlargedFabSize,
    required double selectedItemLift, // How much the selected item is lifted
  }) {
    bool isSelected = itemIndex == currentIndex;
    Color itemActiveIconColor = Color(0xFF69F0AE);
    Color itemInactiveColor = Colors.white;
    Color labelColor = Colors.white;

    double currentDisplayCircleSize = isSelected ? enlargedFabSize : fabSize;
    double iconSize = isSelected ? fabSize * 0.8 : 50;
    // If selected, the item (icon + text) is translated upwards.
    double verticalOffset =
        isSelected ? -selectedItemLift - 10 : 0; // Negative to LIFT UP

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Transform.translate(
          offset: Offset(0, verticalOffset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                MainAxisAlignment.center, // Align to bottom for label placement
            children: [
              Container(
                width: currentDisplayCircleSize + 10,
                height: currentDisplayCircleSize - 5,
                decoration:
                    isSelected
                        ? BoxDecoration(
                          color: Color(0xFFBCA0DC),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        )
                        : null,
                child: Icon(
                  icon,
                  color: isSelected ? itemActiveIconColor : itemInactiveColor,
                  size: iconSize,
                ),
              ),

              Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavPainter extends CustomPainter {
  final Color navColor;
  final double fabSize;
  final double fabMargin;
  final int selectedIndex;
  final int itemCount;
  final double ravineDepthFactor;
  final double ravineCurveControlFactor; // Factor to control steepness

  _BottomNavPainter({
    required this.navColor,
    required this.fabSize,
    required this.fabMargin,
    required this.selectedIndex,
    required this.itemCount,
    this.ravineDepthFactor = 0.85, // MODIFIED: Increased default depth
    this.ravineCurveControlFactor =
        0.7, // MODIFIED: Adjusted for steeper curve (0.0 to 1.0)
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = navColor
          ..style = PaintingStyle.fill;

    final path = Path();
    final double fabRadius = fabSize / 2;
    final double cornerRadius = 7.5;
    final double actualRavineDepth = fabRadius * ravineDepthFactor;

    final double itemWidth = size.width / itemCount;
    final double centerFabX = (itemWidth * selectedIndex) + (itemWidth / 2);

    // Define the horizontal start and end points of the entire ravine section
    // These points are where the flat top line of the bar meets the curve of the ravine
    final double ravineShoulderSpan =
        fabRadius +
        fabMargin; // How far the curve 'shoulders' extend from centerFabX
    final double ravineStartPointX = centerFabX - ravineShoulderSpan;
    final double ravineEndPointX = centerFabX + ravineShoulderSpan;

    path.moveTo(cornerRadius, 0);

    // Line to the point where the ravine begins
    path.lineTo(math.max(0, ravineStartPointX), 0);

    // Control points for the first half of the ravine (dipping down)
    // cp1 is on the top line, cp2 is at the bottom of the ravine
    double cp1x =
        ravineStartPointX +
        (centerFabX - ravineStartPointX) * (1 - ravineCurveControlFactor);
    double cp1y = 0;
    double cp2x =
        centerFabX -
        (centerFabX - ravineStartPointX) *
            (ravineCurveControlFactor *
                0.5); // Pulls towards center for steepness
    double cp2y = actualRavineDepth;

    path.cubicTo(
      cp1x.clamp(0, size.width),
      cp1y,
      cp2x.clamp(0, size.width),
      cp2y,
      centerFabX.clamp(0, size.width),
      actualRavineDepth,
    );

    // Control points for the second half of the ravine (coming up)
    // cp3 is at the bottom of the ravine, cp4 is on the top line
    double cp3x =
        centerFabX +
        (ravineEndPointX - centerFabX) *
            (ravineCurveControlFactor * 0.5); // Pulls from center for steepness
    double cp3y = actualRavineDepth;
    double cp4x =
        ravineEndPointX -
        (ravineEndPointX - centerFabX) * (1 - ravineCurveControlFactor);
    double cp4y = 0;

    path.cubicTo(
      cp3x.clamp(0, size.width),
      cp3y,
      cp4x.clamp(0, size.width),
      cp4y,
      math.min(size.width, ravineEndPointX),
      0,
    );

    path.lineTo(size.width - cornerRadius, 0);
    path.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: Radius.circular(cornerRadius),
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, 0),
      radius: Radius.circular(cornerRadius),
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BottomNavPainter oldDelegate) {
    return oldDelegate.navColor != navColor ||
        oldDelegate.fabSize != fabSize ||
        oldDelegate.fabMargin != fabMargin ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.itemCount != itemCount ||
        oldDelegate.ravineDepthFactor != ravineDepthFactor ||
        oldDelegate.ravineCurveControlFactor != ravineCurveControlFactor;
  }
}
