import 'package:first_project/widgets/HomeAppBar.dart' show HomeAppBar;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Get.offNamed('/login');
  }

  Future<String?> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ShopEase"),
        backgroundColor: Colors.deepPurple,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  accountEmail: const Text(""),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.deepPurple,
                    ),
                  ),
                  decoration: const BoxDecoration(color: Colors.deepPurple),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout"),
                  onTap: () => _logout(context),
                ),
              ],
            );
          },
        ),
      ),
      body: ListView(
        children: const [
          HomeAppBar(),
          SizedBox(height: 20),
          Center(
            child: Text(
              "Welcome to Home Page",
              style: TextStyle(fontSize: 20, fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }
}
