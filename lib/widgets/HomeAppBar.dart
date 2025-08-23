import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(255, 255, 255, 1),
      padding: EdgeInsets.all(25),
      child: Row(
        children: [
          Icon(Icons.sort, size: 30, color: Colors.deepPurple),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              "Home",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
