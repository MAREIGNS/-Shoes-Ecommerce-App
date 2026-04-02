import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoescomm/core/validators.dart';
import 'package:shoescomm/widgets/app_snackbar.dart';
import '../service/ecommerce_service.dart';
import '../models/product_model.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();

  final EcommerceService _service = EcommerceService.instance;
  XFile? _image;

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
      appBar: AppBar(title: const Text('Add Product')),
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
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Product name',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, 'Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _desc,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Short description',
                  ),
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _price,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    hintText: 'e.g. 49.99',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: Validators.price,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stock,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    hintText: 'e.g. 10',
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  validator: Validators.stock,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final pickedImage = await _service.pickImage();
                    if (pickedImage != null) setState(() => _image = pickedImage);
                  },
                  child: const Text('Pick Image'),
                ),
                if (_image != null) ...[
                  const SizedBox(height: 10),
                  if (kIsWeb)
                    Image.network(_image!.path, height: 150, fit: BoxFit.cover)
                  else
                    Image.file(File(_image!.path), height: 150, fit: BoxFit.cover),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    String? imageUrl;
                    if (_image != null) {
                      imageUrl = await _service.uploadImage(_image!);
                      if (imageUrl == null && mounted) {
                        showAppSnackBar(context, message: 'Image upload failed', isError: true);
                        return;
                      }
                    }
                    final product = ProductModel(
                      id: '',
                      name: _name.text.trim(),
                      description: _desc.text.trim(),
                      price: double.parse(_price.text.trim()),
                      stock: int.parse(_stock.text.trim()),
                      imageUrl: imageUrl,
                      categoryId: null,
                    );
                    await _service.addProduct(product);
                    if (mounted) {
                      showAppSnackBar(context, message: 'Product added', isError: false);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
