import 'package:flutter/material.dart';

import '../data/food_repository.dart';
import '../models/food_place.dart';
import '../models/menu_item.dart';
import '../models/review.dart';

class PlaceFormScreen extends StatefulWidget {
  const PlaceFormScreen({super.key, required this.place});

  final FoodPlace? place;

  @override
  State<PlaceFormScreen> createState() => _PlaceFormScreenState();
}

class _PlaceFormScreenState extends State<PlaceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceRangeController = TextEditingController();
  final _menuController = TextEditingController();
  final _facilitiesController = TextEditingController();
  String _priceCategory = 'Murah';

  @override
  void initState() {
    super.initState();
    final place = widget.place;
    if (place != null) {
      _nameController.text = place.name;
      _descriptionController.text = place.description;
      _locationController.text = place.location;
      _priceRangeController.text = place.priceRange;
      _priceCategory = place.priceCategory;
      _menuController.text = place.menuItems
          .map((item) => '${item.name}:${item.price}')
          .join(', ');
      _facilitiesController.text = place.facilities.join(', ');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceRangeController.dispose();
    _menuController.dispose();
    _facilitiesController.dispose();
    super.dispose();
  }

  List<MenuItem> _parseMenu() {
    return _menuController.text
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .map((entry) {
      final parts = entry.split(':');
      return MenuItem(
          name: parts.first.trim(),
          price: int.tryParse(parts.length > 1 ? parts[1].trim() : '0') ?? 0);
    }).toList();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.place;
    final place = FoodPlace(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      priceCategory: _priceCategory,
      priceRange: _priceRangeController.text.trim(),
      imageUrls: const ['foto', 'menu', 'suasana'],
      menuItems: _parseMenu().isEmpty
          ? const [MenuItem(name: 'Menu utama', price: 10000)]
          : _parseMenu(),
      facilities: _facilitiesController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      reviews: existing?.reviews ??
          [
            Review(
                userName: 'Admin',
                comment: 'Tempat berhasil ditambahkan.',
                rating: 4)
          ],
    );

    if (existing == null ||
        FoodRepository.instance
            .getAllPlaces()
            .every((item) => item.id != place.id)) {
      FoodRepository.instance.addPlace(place);
    } else {
      FoodRepository.instance.updatePlace(place);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.place == null ? 'Tambah Tempat' : 'Edit Tempat')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama tempat'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Wajib diisi'
                    : null),
            const SizedBox(height: 12),
            TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Wajib diisi'
                    : null),
            const SizedBox(height: 12),
            TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Wajib diisi'
                    : null),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _priceCategory,
              decoration: const InputDecoration(labelText: 'Kategori harga'),
              items: const ['Murah', 'Sedang', 'Mahal']
                  .map((value) =>
                      DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _priceCategory = value ?? 'Murah'),
            ),
            const SizedBox(height: 12),
            TextFormField(
                controller: _priceRangeController,
                decoration: const InputDecoration(
                    labelText: 'Kisaran harga, contoh Rp10.000 - Rp30.000'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Wajib diisi'
                    : null),
            const SizedBox(height: 12),
            TextFormField(
                controller: _menuController,
                decoration: const InputDecoration(
                    labelText: 'Menu, format: Nama:Harga, Nama:Harga'),
                maxLines: 2),
            const SizedBox(height: 12),
            TextFormField(
                controller: _facilitiesController,
                decoration: const InputDecoration(
                    labelText: 'Fasilitas, pisahkan koma'),
                maxLines: 2),
            const SizedBox(height: 18),
            FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
