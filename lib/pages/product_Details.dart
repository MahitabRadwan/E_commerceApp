import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final List<String> sizes;
  final List<String> colors;
  final bool inStock;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.sizes = const ['S', 'M', 'L', 'XL'],
    this.colors = const ['Black', 'White', 'Blue', 'Red'],
    this.inStock = true,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 4.5).toDouble(),
      reviewCount: (map['reviewCount'] ?? 0).toInt(),
      sizes: List<String>.from(map['sizes'] ?? ['S', 'M', 'L', 'XL']),
      colors: List<String>.from(
        map['colors'] ?? ['Black', 'White', 'Blue', 'Red'],
      ),
      inStock: map['inStock'] ?? true,
    );
  }
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;
  final User? user = FirebaseAuth.instance.currentUser;
  bool isInWishlist = false;
  ProductModel? product;
  bool isLoading = true;
  String selectedSize = 'M';
  String selectedColor = 'Black';
  int currentImageIndex = 0;
  List<String> productImages = [];

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
    _checkWishlistStatus();
  }

  Future<void> _loadProductDetails() async {
    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (productDoc.exists) {
        setState(() {
          product = ProductModel.fromMap(productDoc.data()!);

          productImages = [
            product!.imageUrl,
            product!.imageUrl,
            product!.imageUrl,
          ];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading product: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkWishlistStatus() async {
    if (user != null) {
      try {
        final wishlistDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('wishlist')
            .doc(widget.productId)
            .get();

        setState(() {
          isInWishlist = wishlistDoc.exists;
        });
      } catch (e) {
        debugPrint('Error checking wishlist: $e');
      }
    }
  }

  Future<void> _toggleWishlist() async {
    if (user == null) {
      Get.snackbar(
        'Login Required',
        'Please login to add to wishlist',
        backgroundColor: Colors.deepPurple,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      if (isInWishlist) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('wishlist')
            .doc(widget.productId)
            .delete();
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('wishlist')
            .doc(widget.productId)
            .set({
              'productId': widget.productId,
              'addedAt': DateTime.now(),
              'productName': product?.name,
              'productPrice': product?.price,
              'productImage': product?.imageUrl,
            });
      }

      setState(() {
        isInWishlist = !isInWishlist;
      });

      Get.snackbar(
        'Success',
        isInWishlist ? 'Added to Wishlist 💖' : 'Removed from Wishlist',
        backgroundColor: Colors.deepPurple,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update wishlist',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _addToCart() async {
    if (user == null) {
      Get.snackbar(
        'Login Required',
        'Please login to add to cart',
        backgroundColor: Colors.deepPurple,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (product == null) return;

    try {
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('cart')
          .doc(widget.productId);

      final cartDoc = await cartRef.get();

      if (cartDoc.exists) {
        await cartRef.update({
          'quantity': FieldValue.increment(quantity),
          'updatedAt': DateTime.now(),
          'selectedSize': selectedSize,
          'selectedColor': selectedColor,
        });
      } else {
        await cartRef.set({
          'productId': product!.id,
          'productName': product!.name,
          'price': product!.price,
          'imageUrl': product!.imageUrl,
          'quantity': quantity,
          'selectedSize': selectedSize,
          'selectedColor': selectedColor,
          'addedAt': DateTime.now(),
        });
      }

      Get.snackbar(
        '🎉 Success',
        'Added $quantity ${product!.name} to Cart',
        backgroundColor: Colors.deepPurple,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      setState(() => quantity = 1);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add to cart',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  Widget _buildSizeOption(String size) {
    final isSelected = size == selectedSize;
    return GestureDetector(
      onTap: () => setState(() => selectedSize = size),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
          ),
        ),
        child: Text(
          size,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(String color) {
    final isSelected = color == selectedColor;
    final colorMap = {
      'Black': Colors.black,
      'White': Colors.white,
      'Blue': Colors.blue,
      'Red': Colors.red,
      'Green': Colors.green,
    };

    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorMap[color] ?? Colors.grey,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
        ),
      );
    }

    if (product == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 16),
              const Text(
                'Product not found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.deepPurple,
            elevation: 0,
            pinned: true,
            floating: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.red : Colors.deepPurple,
                ),
                onPressed: _toggleWishlist,
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: productImages.length,
                onPageChanged: (index) =>
                    setState(() => currentImageIndex = index),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        productImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.deepPurple,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(productImages.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentImageIndex == index
                        ? Colors.deepPurple
                        : Colors.grey[300],
                  ),
                );
              }),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        '\$${product!.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withAlpha(
                            25,
                          ), // استخدام withAlpha بدلاً من withOpacity
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product!.category,
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildRatingStars(product!.rating),
                      const SizedBox(width: 4),
                      Text(
                        '(${product!.reviewCount})',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Icon(
                        product!.inStock ? Icons.check_circle : Icons.cancel,
                        color: product!.inStock ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product!.inStock ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          color: product!.inStock ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product!.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Size',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: product!.sizes.map(_buildSizeOption).toList(),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Color',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: product!.colors.map(_buildColorOption).toList(),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() => quantity--);
                            }
                          },
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            quantity.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => quantity++);
                          },
                          icon: const Icon(Icons.add, color: Colors.deepPurple),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[200]!),
          ), // تم التصحيح هنا
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$quantity item${quantity > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Text(
              '\$${(product!.price * quantity).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            const Spacer(),

            Expanded(
              child: ElevatedButton(
                onPressed: product!.inStock ? _addToCart : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
