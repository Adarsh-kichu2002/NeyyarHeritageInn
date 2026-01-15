import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final Map<String, int> cartCount = {};

  static const LinearGradient pinkGradient = LinearGradient(
  colors: [
    Color(0xFFE23A83),
    Color(0xFFF26741),
  ],
);


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
    backgroundColor: const Color(0xFFE23A83),

    body: Column(
      children: [
        // Top
        Container(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
          decoration: const BoxDecoration(
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
                        style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.w400,fontSize: 14, color: Color(0xFFFFFFFF)),
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down,
                              color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  _iconBadgeImage('assets/images/cart.png', () {
                    Navigator.pushNamed(context, '/cart');
                  }),
                  _iconBadgeImage('assets/images/notification.png', () {
                    Navigator.pushNamed(context, '/notification');
                  }),
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
  shaderCallback: (bounds) {
    return pinkGradient.createShader(
      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
    );
  },
  child: const Icon(
    Icons.search,
    size: 22,
    color: Colors.white, 
  ),
),

                    const SizedBox(width: 8),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Products',
                          hintStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFF888888)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Image.asset(
  'assets/images/filter.png',
  width: 22,
  height: 22,
),

                  ],
                ),
              ),
            ],
          ),
        ),

        // Body
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF4F7FA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: CustomScrollView(
              slivers: [
                /// Category Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 28, 16, 10),
                    child: Row(
                      children: [
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            color: Color(0xFF070707),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        ShaderMask(
  shaderCallback: (bounds) {
    return pinkGradient.createShader(
      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
    );
  },
  child: const Text(
    'View All',
    style: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: Colors.white, 
    ),
  ),
),
ShaderMask(
  shaderCallback: (bounds) {
    return pinkGradient.createShader(
      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
    );
  },
  child: const Icon(
    Icons.chevron_right,
    size: 18,
    color: Colors.white,
  ),
),


                      ],
                    ),
                  ),
                ),

                // Category Grid
                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = categories[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.asset(
                                  item['image']!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['title']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style:
                                    const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: categories.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                  ),
                ),

                //Other Cards
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 140,
                    child: PageView.builder(
                      controller:
                          PageController(viewportFraction: 0.92),
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return _orderCard(
                          backgroundColor: index == 0
                              ? const Color(0xFFF1C27D)
                              : const Color(0xFFF26A6A),
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                    child: SizedBox(height: 40)),

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _sectionHeaderWithAction(
                            title: 'Flash sale'),
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
                              title:
                                  'Everest Chicken Masala',
                              subtitle: '100 g',
                              price: '\$10.00',
                              image:
                                  'assets/images/masala.png',
                              counter: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        _sectionHeaderWithAction(title: 'Special Offer'),
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

                        _sectionHeaderWithAction(title: 'Best Selling'),
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
            const SizedBox(height: 40),
            _sectionHeaderWithAction(title: 'Most Popular'),
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

                      ],
                    ),
                  ),
                  
                ),
              ],
            ),
          ),
        ),
      ],
    ),

    // Bottom Navigation Bar
    bottomNavigationBar: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomItemImage('assets/images/home.png', 'Home', true),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/cart'),
            child: _bottomItemImage(
                'assets/images/cart.png', 'Cart', false),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, '/favourite'),
            child: _bottomItemImage(
                'assets/images/favourite.png', 'Favourite', false),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, '/account'),
            child: _bottomItemImage(
                'assets/images/account.png', 'Account', false),
          ),
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
  String? id,
}) {
  final count = cartCount[id ?? title] ?? 0;

  return Flexible(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(image, height: 100, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Text(title, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),

          Row(
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),

              (showAdd && count == 0)
                  ? GestureDetector(
                      onTap: () {
                        setState(() => cartCount[id ?? title] = 1);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE23A83), Color(0xFFF26741)],
                          ),
                        ),
                        child: const Text('Add', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600 , color: Colors.white)),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                final key = id ?? title;
                                if (cartCount[key]! > 1) {
                                  cartCount[key] = cartCount[key]! - 1;
                                } else {
                                  cartCount.remove(key);
                                }
                              });
                            },
                            child: const Icon(Icons.remove, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              final key = id ?? title;
                              setState(() => cartCount[key] = cartCount[key]! + 1);
                            },
                            child: const Icon(Icons.add, size: 16),
                          ),
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

  Widget _iconBadgeImage(String imagePath, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        imagePath,
        width: 22,
        height: 22,
        color: Colors.white, 
      ),
    ),
  );
}

  Widget _sectionHeaderWithAction({
  required String title,
  VoidCallback? onTap,
}) {
  return 
  Padding(padding:  const EdgeInsets.fromLTRB(10, 10, 16, 16),
  child:
  Row(
    children: [
      Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600
        ),
      ),
      const Spacer(),
      GestureDetector(
        onTap: onTap,
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFE23A83), Color(0xFFF26741)],
          ).createShader(bounds),
          child: const Row(
            children: [
              Text('View All', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500 )),
              Icon(Icons.chevron_right, size: 18, color: Colors.white),
            ],
          ),
        ),
      ),
    ],
  ),
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
                    Positioned(
                      bottom: imageBoxHeight * 0.08,
                      child: Image.asset(
                        'assets/images/ellipse2.png',
                        width: ellipseWidth,
                        fit: BoxFit.contain,
                      ),
                    ),

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

Widget _bottomItemImage(
    String imagePath, String label, bool isActive) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        imagePath,
        width: 24,
        height: 24,
        color: isActive ? Colors.pink : Colors.grey,
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.pink : Colors.grey,
        ),
      ),
    ],
  );
}
}
