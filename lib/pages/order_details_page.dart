import 'package:flutter/material.dart';
import 'package:shoescomm/service/ecommerce_service.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final EcommerceService _service = EcommerceService.instance;
  late Future _orderItems;

  @override
  void initState() {
    super.initState();

    _orderItems = _service.client
        .from('order_items')
        .select('''
          quantity,
          price,
          products (
            name,
            image_url
          )
        ''')
        .eq('order_id', widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: FutureBuilder(
        future: _orderItems,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data as List;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final product = item['products'];

              return ListTile(
                leading: product['image_url'] != null
                    ? Image.network(product['image_url'], width: 50)
                    : const Icon(Icons.image),
                title: Text(product['name']),
                subtitle: Text("Qty: ${item['quantity']}"),
                trailing: Text("Rs. ${item['price']}"),
              );
            },
          );
        },
      ),
    );
  }
}