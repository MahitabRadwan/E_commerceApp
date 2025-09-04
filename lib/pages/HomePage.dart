import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late bool isEmailVerified;
  List<String> favoriteProducts = [];

  @override
  void initState() {
    super.initState();
    isEmailVerified = user?.emailVerified ?? false;
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    print("Logout executed, isLoggedIn set to false");
    await prefs.remove('username');
    FirebaseAuth.instance.signOut();
    Get.offAllNamed('/splash');
  }

  Future<String?> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? user?.displayName ?? "Guest";
  }

  void _toggleFavorite(String productName) {
    setState(() {
      if (favoriteProducts.contains(productName)) {
        favoriteProducts.remove(productName);
      } else {
        favoriteProducts.add(productName);
      }
    });
  }

  void _showDialog(String title, String message) {
    Color dialogColor = title == 'Success' ? Colors.green : Colors.red;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: dialogColor),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ShopEase"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.red,
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: FutureBuilder<String?>(
          future: _getUsername(),
          builder: (context, snapshot) {
            String username = snapshot.data ?? "Guest";

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    username,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  accountEmail: Text(user?.email ?? ""),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.deepPurple,
                    ),
                  ),
                  decoration: BoxDecoration(color: Colors.deepPurple),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text("Home"),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(Icons.task),
                  title: Text("Tasks"),
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/tasks'),
                ),
                ListTile(
                  leading: Icon(Icons.shopping_bag),
                  title: Text("Products"),
                  onTap: () => Get.toNamed('/products'),
                ),
                ListTile(
                  leading: Icon(Icons.shopping_cart),
                  title: Text("Cart"),
                  onTap: () => Get.toNamed('/cart'),
                ),
                ListTile(
                  leading: Icon(Icons.list_alt),
                  title: Text("Orders"),
                  onTap: () => Get.toNamed('/orders'),
                ),
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text("Favorites"),
                  onTap: () {
                    Get.to(
                      () => Scaffold(
                        appBar: AppBar(title: Text("My Favorites")),
                        body: favoriteProducts.isEmpty
                            ? Center(child: Text("No favorites added yet."))
                            : ListView.builder(
                                itemCount: favoriteProducts.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    ),
                                    title: Text(favoriteProducts[index]),
                                  );
                                },
                              ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Profile"),
                  onTap: () => Get.toNamed('/profile'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text("Logout"),
                  onTap: () => _logout(context),
                ),
              ],
            );
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isEmailVerified) _buildEmailVerificationCard(),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset("assets/images/Splash_View_image.jpg"),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Welcome to ShopEase 💜",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final isFavorite = favoriteProducts.contains(
                          product.name,
                        );

                        return GestureDetector(
                          onTap: () {
                            if (Get.currentRoute != '/product_details') {
                              Get.toNamed(
                                '/product_details',
                                arguments: {
                                  'name': product.name,
                                  'shortDesc': product.description,
                                  'price': product.price,
                                  'image': product.image,
                                },
                              );
                            }
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Colors.deepPurple.shade100,
                                width: 1.5,
                              ),
                            ),
                            elevation: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                        child: Image.asset(
                                          product.image,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.image_not_supported,
                                                  size: 50,
                                                );
                                              },
                                        ),
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: IconButton(
                                          icon: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFavorite
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
                                          onPressed: () =>
                                              _toggleFavorite(product.name),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "\$${product.price}",
                                        style: TextStyle(
                                          color: Colors.deepPurple,
                                          fontWeight: FontWeight.w600,
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailVerificationCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[100]!, Colors.orange[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.email, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                "Email verification required",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.currentUser!
                      .sendEmailVerification();
                } catch (e) {
                  debugPrint("Error");
                }
              },
              icon: Icon(Icons.send),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              label: Text("Send Verification Email"),
            ),
          ),
        ],
      ),
    );
  }
}

List<Product> products = [
  Product("Product 1", "Description 1", 19.99, "assets/images/product1.jpg"),
  Product("Product 2", "Description 2", 29.99, "assets/images/product2.jpg"),
  Product("Product 3", "Description 3", 39.99, "assets/images/product3.jpg"),
  Product("Product 4", "Description 4", 49.99, "assets/images/product4.jpg"),
];

class Product {
  final String name;
  final String description;
  final double price;
  final String image;

  Product(this.name, this.description, this.price, this.image);
}
