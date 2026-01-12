import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<Map<String, String>> categories = [
    {'image': 'assets/images/food.png', 'title': 'Food G...'},
    {'image': 'assets/images/oil.png', 'title': 'Edible Oils'},
    {'image': 'assets/images/spices.png', 'title': 'Spices'},
    {'image': 'assets/images/instant.png', 'title': 'Instant Fo...'},
    {'image': 'assets/images/milk.png', 'title': 'Milk Prod.'},
    {'image': 'assets/images/snacks.png', 'title': 'Snacks'},
    {'image': 'assets/images/beverages.png', 'title': 'Beverages'},
    {'image': 'assets/images/personal.png', 'title': 'Personal'},
    {'image': 'assets/images/health.png', 'title': 'Health Care'},
    {'image': 'assets/images/household.png', 'title': 'Household'},
    {'image': 'assets/images/fruits.png', 'title': 'Fruits'},
    {'image': 'assets/images/all.png', 'title': 'All Other'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
        children: [
          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              gradient: LinearGradient(
                colors: [Color(0xFFE23A83), Color(0xFFF26741)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery 10 minutes',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 18, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Singapore',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            Icon(Icons.keyboard_arrow_down,
                               size: 10, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    _iconBadge(Icons.shopping_cart_outlined),
                    const SizedBox(width: 12),
                    _iconBadge(Icons.notifications_none_outlined),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ShaderMask(
  shaderCallback: (Rect bounds) {
    return const LinearGradient(
      colors: [
        Color(0xFFE23A83),
        Color(0xFFF26741),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(bounds);
  },
  child: const Icon(
    Icons.search,
    size: 24,
    color: Colors.white, 
  ),
),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Products',
                            hintStyle: TextStyle(fontWeight: FontWeight.w400, fontFamily: 'Poppins', color: Color(0xFF888888)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const Icon(Icons.filter_list, color: Color(0xFF888888)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// SCROLL CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Category'),
                  const SizedBox(height: 12),
                  Container(
  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
  decoration: BoxDecoration(
    color: const Color(0xFFF4F7FA),
    borderRadius: BorderRadius.circular(24),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const SizedBox(height: 12),

      /// GRID
      _categoryGrid(),
    ],
  ),
),
                  const SizedBox(height: 20),

                  SizedBox(
  height: 140,
  child: PageView.builder(
    controller: PageController(viewportFraction: 0.92),
    itemCount: 2,
    itemBuilder: (context, index) {
      return _orderCard(
        backgroundColor:
            index == 0 ? const Color(0xFFF1C27D) : const Color(0xFFF26A6A),
      );
    },
  ),
),


                  const SizedBox(height: 20),
                  _sectionHeader('Flash sale'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _productCard(
                        title: 'Cooking Oil',
                        subtitle: '1L',
                        price: '\$100.00',
                        oldPrice: '\$100.00',
                        image: 'assets/images/oil.png',
                        showAdd: true,
                      ),
                      const SizedBox(width: 12),
                      _productCard(
                        title: 'Everest Chicken Masala',
                        subtitle: '100 g',
                        price: '\$10.00',
                        image: 'assets/images/masala.png',
                        counter: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _sectionHeader('Special Offer'),
                  const SizedBox(height: 12),
SizedBox(
  height: 160,
  child: PageView.builder(
    controller: PageController(viewportFraction: 0.9),
    itemCount: 2,
    itemBuilder: (context, index) {
      return _offerCard(
        backgroundColor:
            index == 0 ? const Color(0xFFF1C27D) : const Color(0xFFF26A6A),
      );
    },
  ),
),

                  const SizedBox(height: 20),
                  _sectionHeader('Best Selling'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _productCard(
                        title: 'Cooking Oil',
                        subtitle: '1L',
                        price: '\$100.00',
                        image: 'assets/images/oil.png',
                        showAdd: true,
                      ),
                      const SizedBox(width: 12),
                      _productCard(
                        title: 'Everest Chicken Masala',
                        subtitle: '100 g',
                        price: '\$10.00',
                        image: 'assets/images/masala.png',
                        counter: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _sectionHeader('Most Popular'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _productCard(
                        title: 'Cooking Oil',
                        subtitle: '1L',
                        price: '\$100.00',
                        image: 'assets/images/oil.png',
                        showAdd: true,
                      ),
                      const SizedBox(width: 12),
                      _productCard(
                        title: 'Everest Chicken Masala',
                        subtitle: '100 g',
                        price: '\$10.00',
                        image: 'assets/images/masala.png',
                        counter: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      /// BOTTOM NAV
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomItem(Icons.home_outlined, 'Home', true),
            _bottomItem(Icons.shopping_cart_outlined, 'Cart', false),
            _bottomItem(Icons.favorite_border_outlined, 'Favourite', false),
            _bottomItem(Icons.person_outline, 'Account', false),
          ],
        ),
      ),
    );
  }

  Widget _productCard({
  required String title,
  required String subtitle,
  required String price,
  required String image,
  String? oldPrice,
  bool showAdd = false,
  bool counter = false,
}) {
  return Flexible(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              image,
              height: 104, 
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            maxLines: 2,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(subtitle, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),

          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (oldPrice != null)
                    Text(
                      oldPrice,
                      style: const TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              if (showAdd)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE23A83),
                        Color(0xFFF26741),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              if (counter)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.remove, color: Colors.black, size: 16),
                      const SizedBox(width: 6),
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            const LinearGradient(
                          colors: [
                            Color(0xFFE23A83),
                            Color(0xFFF26741),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          '2',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),
                      const Icon(Icons.add, color: Colors.black, size: 16),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _iconBadge(IconData icon) {
    return Stack(
      children: [
        Icon(icon, color: Colors.white),
        Positioned(
          right: 0,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        )
      ],
    );
  }

  Widget _sectionHeader(String title) {
  const LinearGradient gradient = LinearGradient(
    colors: [
      Color(0xFFE23A83),
      Color(0xFFF26741),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  return Row(
    children: [
      Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const Spacer(),
      ShaderMask(
        shaderCallback: (bounds) => gradient.createShader(bounds),
        child: const Row(
          children: [
            Text(
              'View All',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.white, 
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_right,
              size: 18,
              color: Colors.white, 
            ),
          ],
        ),
      ),
    ],
  );
}

  Widget _orderCard({required Color backgroundColor}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final cardHeight = constraints.maxHeight;
      final imageSize = cardHeight * 0.65;
      final shadowSize = cardHeight * 0.55;

      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              /// LEFT CONTENT
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order before 2PM for\nsame day delivery',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Accept all type of payments',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Best price, Best Deals, Save a lot',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// RIGHT IMAGE SECTION
             Expanded(
  flex: 4,
  child: LayoutBuilder(
    builder: (context, constraints) {
      final cardHeight = constraints.maxHeight;
      final cardWidth = constraints.maxWidth;

      final imageBoxHeight = cardHeight * 0.65; 
      final imageBoxWidth = cardWidth * 0.85;   
      final shadowSize = imageBoxHeight * 0.55;
      final imageSize = imageBoxHeight * 0.85;

      return Stack(
        alignment: Alignment.center,
        children: [
          /// WHITE SHADOW (BOTTOM LEFT)
          Positioned(
            bottom: imageBoxHeight * 0.0,
            left: imageBoxWidth * 0.10,
            child: Container(
              width: shadowSize,
              height: shadowSize,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SizedBox(
            width: imageBoxWidth,
            height: imageBoxHeight,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/oil.png',
                  height: imageSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      );
    },
  ),
),


            ],
          ),
        ),
      );
    },
  );
}

  Widget _offerCard({required Color backgroundColor}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final cardHeight = constraints.maxHeight;
      final cardWidth = constraints.maxWidth;

      final imageBoxHeight = cardHeight * 0.68;
      final imageBoxWidth = cardWidth * 0.85;
      final imageSize = imageBoxHeight * 0.9;
      final ellipseWidth = imageBoxWidth * 0.8;

      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              /// LEFT CONTENT
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Special Offer',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A2C1B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Cold Press Sunflower Oil',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Color(0xFF3A2C1B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '20% Offer',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),

                      /// BUY NOW BUTTON
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A2C1B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Buy Now',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// RIGHT IMAGE SECTION
              Expanded(
                flex: 4,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration( 
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    /// ELLIPSE UNDER IMAGE
                    Positioned(
                      bottom: imageBoxHeight * 0.08,
                      child: Image.asset(
                        'assets/images/ellipse2.png',
                        width: ellipseWidth,
                        fit: BoxFit.contain,
                      ),
                    ),

                    /// IMAGE WHITE CARD
                    SizedBox(
                      width: imageBoxWidth,
                      height: imageBoxHeight,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Center(
                          child: Image.asset(
                            'assets/images/oil.png',
                            height: imageSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _categoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,        
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.78,   
      ),
      itemBuilder: (_, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              /// IMAGE (FIXED + FILLED)
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      categories[index]['image']!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              /// TEXT (FIXED CENTER)
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Center(
                    child: Text(
                      categories[index]['title']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6A6A6A),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomItem(IconData icon, String label, bool active) {
  const gradient = LinearGradient(
    colors: [
      Color(0xFFE23A83),
      Color(0xFFF26741),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      /// ICON
      active
          ? ShaderMask(
              shaderCallback: (bounds) =>
                  gradient.createShader(bounds),
              child: Icon(
                icon,
                color: Colors.white, 
              ),
            )
          : Icon(
              icon,
              color: const Color(0xFFA0A0A0),
            ),

      const SizedBox(height: 4),
      active
          ? ShaderMask(
              shaderCallback: (bounds) =>
                  gradient.createShader(bounds),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: Colors.white, 
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: Color(0xFFA0A0A0),
              ),
            ),
    ],
  );
}
}
