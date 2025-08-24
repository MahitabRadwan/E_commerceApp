import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  final List<Map<String, dynamic>> orders = const [
    {
      'id': 'ORD001',
      'date': '2025-08-20',
      'total': 120.50,
      'status': 'Delivered',
    },
    {'id': 'ORD002', 'date': '2025-08-18', 'total': 75.00, 'status': 'Shipped'},
    {
      'id': 'ORD003',
      'date': '2025-08-15',
      'total': 220.00,
      'status': 'Processing',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Orders"), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const Divider(thickness: 1),
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              child: const Icon(Icons.receipt_long, color: Colors.deepPurple),
            ),
            title: Text(
              "Order #${order['id']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Date: ${order['date']} • Status: ${order['status']}",
            ),
            trailing: Text(
              "\$${order['total']}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Opening details for Order ${order['id']}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
