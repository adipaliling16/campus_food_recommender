import 'package:flutter/material.dart';

import '../data/food_repository.dart';
import '../models/food_place.dart';
import '../models/menu_item.dart';
import '../models/review.dart';
import 'place_form_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _repository = FoodRepository.instance;

  void _openForm([FoodPlace? place]) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceFormScreen(place: place)));
    setState(() {});
  }

  FoodPlace _makeSamplePlace() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return FoodPlace(
      id: id,
      name: 'Tempat Baru $id',
      description: 'Deskripsi tempat makan baru di sekitar kampus.',
      location: 'Sekitar Kampus',
      priceCategory: 'Murah',
      priceRange: 'Rp10.000 - Rp30.000',
      imageUrls: const ['baru', 'menu', 'kampus'],
      menuItems: const [MenuItem(name: 'Menu Andalan', price: 15000)],
      facilities: const ['WiFi', 'Parkir'],
      reviews: [Review(userName: 'Admin', comment: 'Data awal dari admin.', rating: 4)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final places = _repository.getAllPlaces();

    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Data Tempat')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(_makeSamplePlace()),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return Card(
            child: ListTile(
              title: Text(place.name),
              subtitle: Text('${place.location}\n${place.priceRange}'),
              isThreeLine: true,
              leading: const CircleAvatar(child: Icon(Icons.restaurant_menu_rounded)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () => _openForm(place)),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded),
                    onPressed: () {
                      _repository.deletePlace(place.id);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
