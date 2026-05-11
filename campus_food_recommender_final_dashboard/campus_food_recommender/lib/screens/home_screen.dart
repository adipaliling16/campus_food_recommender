import 'package:flutter/material.dart';

import '../data/food_repository.dart';
import '../models/food_place.dart';
import '../widgets/place_card.dart';
import 'admin_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = FoodRepository.instance;
  final _searchController = TextEditingController();

  SortFilter _filter = SortFilter.recommended;
  String _priceCategory = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(FoodPlace place) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(placeId: place.id)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final places = _repository.searchPlaces(
      query: _searchController.text,
      filter: _filter,
      priceCategory: _priceCategory,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07111F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'TITIK KUMPUL',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Admin',
            icon: const Icon(Icons.admin_panel_settings_rounded),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminScreen()),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF12343B), Color(0xFF0D2B36)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temukan Tempat Favoritmu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rekomendasi tempat makan dan cafe terbaik di sekitar kamu.',
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.white60),
                  hintText: 'Cari nama, menu, lokasi...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DarkDropdown<SortFilter>(
                    label: 'Urutkan',
                    value: _filter,
                    items: const [
                      DropdownMenuItem(
                        value: SortFilter.recommended,
                        child: Text('Rekomendasi'),
                      ),
                      DropdownMenuItem(
                        value: SortFilter.highestRating,
                        child: Text('Rating tertinggi'),
                      ),
                      DropdownMenuItem(
                        value: SortFilter.cheapest,
                        child: Text('Termurah'),
                      ),
                      DropdownMenuItem(
                        value: SortFilter.expensive,
                        child: Text('Termahal'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filter = value ?? SortFilter.recommended;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DarkDropdown<String>(
                    label: 'Harga',
                    value: _priceCategory,
                    items: const ['Semua', 'Murah', 'Sedang', 'Mahal']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _priceCategory = value ?? 'Semua';
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (places.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'Tidak ada tempat makan yang sesuai.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              )
            else
              ...places.map(
                (place) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: PlaceCard(
                    place: place,
                    onTap: () => _openDetail(place),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DarkDropdown<T> extends StatelessWidget {
  const _DarkDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: const Color(0xFF102A2F),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white70,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFB2FF59)),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
