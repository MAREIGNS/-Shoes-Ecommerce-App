import 'package:flutter/material.dart';
import 'package:shoescomm/core/validators.dart';
import 'package:shoescomm/service/ecommerce_service.dart';
import '../models/product_model.dart';

class EditProductPage extends StatefulWidget {
  final ProductModel product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final EcommerceService _service = EcommerceService.instance;

  late TextEditingController _name;
  late TextEditingController _desc;
  late TextEditingController _price;
  late TextEditingController _stock;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.product.name);
    _desc = TextEditingController(text: widget.product.description);
    _price = TextEditingController(text: widget.product.price.toString());
    _stock = TextEditingController(text: widget.product.stock.toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, 'Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _desc,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _price,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: Validators.price,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stock,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  validator: Validators.stock,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    await _service.client.from('products').update({
                      'name': _name.text.trim(),
                      'description': _desc.text.trim(),
                      'price': double.parse(_price.text.trim()),
                      'stock': int.parse(_stock.text.trim()),
                    }).eq('id', widget.product.id);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
