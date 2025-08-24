import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:first_project/features/Splash/presentation/splash_view.dart';
import 'package:first_project/pages/register_screen.dart';
import 'package:first_project/pages/login_screen.dart';
import 'package:first_project/pages/HomePage.dart';
import 'package:first_project/pages/product.dart';
import 'package:first_project/pages/productsDetails.dart';
import 'package:first_project/pages/cart.dart';
import 'package:first_project/pages/orders.dart';
import 'package:first_project/pages/profile.dart';

void main() => runApp(const ShopEase());

class ShopEase extends StatelessWidget {
  const ShopEase({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/Splash_View',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      getPages: [
        GetPage(name: '/Splash_View', page: () => const SplashView()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/products', page: () => const ProductsScreen()),
        GetPage(
          name: '/product_details',
          page: () => const ProductDetailsPage(product: null),
        ),
        GetPage(name: '/cart', page: () => const CartScreen()),
        GetPage(name: '/orders', page: () => const OrdersScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
      ],
    );
  }
}

class Product {
  final String name;
  final String description;
  final double price;
  final String image;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });
}

List<Product> products = [
  Product(
    name: "Leather Handbag",
    description: "Elegant genuine leather handbag with spacious design.",
    price: 120.0,
    image: "assets/icons/images/handbag.jpg",
  ),
  Product(
    name: "Stylish Heels",
    description: "Comfortable and fashionable heels for special occasions.",
    price: 85.0,
    image: "assets/icons/images/heels.jpg",
  ),
  Product(
    name: "Gold Necklace",
    description: "18K gold plated necklace, perfect for evening wear.",
    price: 150.0,
    image: "assets/icons/images/necklace.jpg",
  ),
  Product(
    name: "Summer Dress",
    description: "Lightweight and trendy dress ideal for summer outings.",
    price: 95.0,
    image: "assets/icons/images/dress.jpg",
  ),
  Product(
    name: "Smart Watch",
    description: "Fashionable smartwatch with fitness tracking features.",
    price: 199.0,
    image: "assets/icons/images/smartwatch.jpg",
  ),
  Product(
    name: "Designer Sunglasses",
    description: "Trendy UV-protected sunglasses for all-day comfort.",
    price: 75.0,
    image: "assets/icons/images/sunglasses.jpg",
  ),
  Product(
    name: "Perfume Set",
    description: "Luxury fragrance set with long-lasting scent.",
    price: 110.0,
    image: "assets/icons/images/perfume.jpg",
  ),
];
