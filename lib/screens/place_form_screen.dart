import 'package:flutter/material.dart';

import '../models/food_place.dart';
import '../models/menu_item.dart';
import '../services/place_service.dart';

class PlaceFormScreen extends StatefulWidget {
  const PlaceFormScreen({
    super.key,
    required this.place,
  });

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
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _facilityController = TextEditingController();
  final _menuController = TextEditingController();

  String _priceCategory = 'Murah';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final place = widget.place;

    if (place != null) {
      _nameController.text = place.name;
      _descriptionController.text = place.description;
      _locationController.text = place.location;
      _priceRangeController.text = place.priceRange;
      _latitudeController.text = place.latitude.toString();
      _longitudeController.text = place.longitude.toString();

      _facilityController.text = place.facilities.join(', ');

      _menuController.text = place.menuItems
          .map(
            (e) => '${e.name}:${e.price}',
          )
          .join(',');

      if (place.imageUrls.isNotEmpty) {
        _imageUrlController.text = place.imageUrls.first;
      }

      _priceCategory = place.priceCategory;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceRangeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _imageUrlController.dispose();
    _facilityController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final menuItems = _menuController.text
          .split(',')
          .where(
            (e) => e.trim().isNotEmpty,
          )
          .map(
        (e) {
          final parts = e.split(':');

          return MenuItem(
            name: parts[0].trim(),
            price: parts.length > 1
                ? int.tryParse(
                      parts[1].trim(),
                    ) ??
                    0
                : 0,
          );
        },
      ).toList();

      final place = FoodPlace(
        id: widget.place?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        latitude: double.tryParse(
              _latitudeController.text,
            ) ??
            0,
        longitude: double.tryParse(
              _longitudeController.text,
            ) ??
            0,
        priceCategory: _priceCategory,
        priceRange: _priceRangeController.text.trim(),
        imageUrls: _imageUrlController.text.trim().isEmpty
            ? []
            : [
                _imageUrlController.text.trim(),
              ],
        facilities: _facilityController.text
            .split(',')
            .map(
              (e) => e.trim(),
            )
            .where(
              (e) => e.isNotEmpty,
            )
            .toList(),
        menuItems: menuItems,
        reviews: widget.place?.reviews ?? [],
        rating: widget.place?.rating ?? 0,
        reviewCount: widget.place?.reviewCount ?? 0,
      );

      if (widget.place == null) {
        await PlaceService.addPlace(place);
      } else {
        await PlaceService.updatePlace(
          widget.place!.id,
          place,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Data berhasil disimpan',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan data\n$e',
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _gap() => const SizedBox(
        height: 16,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.place == null ? 'Tambah Tempat' : 'Edit Tempat',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Tempat',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama tempat wajib diisi';
                }
                return null;
              },
            ),
            _gap(),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Lokasi',
                border: OutlineInputBorder(),
              ),
            ),
            _gap(),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
            ),
            _gap(),
            DropdownButtonFormField<String>(
              value: _priceCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori Harga',
                border: OutlineInputBorder(),
              ),
              items: const [
                'Murah',
                'Sedang',
                'Mahal',
              ]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _priceCategory = value ?? 'Murah';
                });
              },
            ),
            _gap(),
            TextFormField(
              controller: _priceRangeController,
              decoration: const InputDecoration(
                labelText: 'Kisaran Harga',
                border: OutlineInputBorder(),
              ),
            ),
            _gap(),
            TextFormField(
              controller: _latitudeController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(),
              ),
            ),
            _gap(),
            TextFormField(
              controller: _longitudeController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
              ),
            ),
            _gap(),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Gambar',
                hintText: 'https://....jpg',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
            _gap(),
            if (_imageUrlController.text.trim().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  12,
                ),
                child: Image.network(
                  _imageUrlController.text,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            _gap(),
            TextFormField(
              controller: _facilityController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Fasilitas',
                hintText: 'WiFi, Parkir, AC',
                border: OutlineInputBorder(),
              ),
            ),
            _gap(),
            TextFormField(
              controller: _menuController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Menu Makanan & Minuman',
                hintText: 'Americano:18000,Cappuccino:25000,French Fries:20000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(
                Icons.save,
              ),
              label: Text(
                _isSaving ? 'Menyimpan...' : 'Simpan',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
