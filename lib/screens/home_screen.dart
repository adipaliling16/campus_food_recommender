import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/food_place.dart';
import '../services/place_service.dart';
import '../widgets/place_card.dart';
import 'admin_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  Position? _currentPosition;
  bool _loadingLocation = true;

  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _loadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _loadingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _loadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _loadingLocation = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(FoodPlace place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          placeId: place.id,
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String category,
  ) {
    final selected = _selectedCategory == category;

    return ChoiceChip(
      label: Text(category),
      selected: selected,
      selectedColor: Colors.green,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
      ),
      onSelected: (_) {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF07111F,
      ),
      appBar: AppBar(
        backgroundColor: const Color(
          0xFF07111F,
        ),
        foregroundColor: Colors.white,
        title: const Text(
          'TITIK KUMPUL',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.admin_panel_settings,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Cari nama, menu, lokasi...',
                hintStyle: const TextStyle(
                  color: Colors.white54,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white54,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(
                  0.08,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),

          /// FILTER HARGA
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'Semua',
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  _buildFilterChip(
                    'Murah',
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  _buildFilterChip(
                    'Sedang',
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  _buildFilterChip(
                    'Mahal',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: StreamBuilder<List<FoodPlace>>(
              stream: PlaceService.getPlaces(),
              builder: (
                context,
                snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error:\n${snapshot.error}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada data tempat.',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                List<FoodPlace> places = snapshot.data!;

                final keyword = _searchController.text.toLowerCase().trim();

                /// SEARCH
                if (keyword.isNotEmpty) {
                  places = places.where(
                    (place) {
                      return place.name.toLowerCase().contains(
                                keyword,
                              ) ||
                          place.location.toLowerCase().contains(
                                keyword,
                              ) ||
                          place.description.toLowerCase().contains(
                                keyword,
                              );
                    },
                  ).toList();
                }

                /// FILTER HARGA
                if (_selectedCategory != 'Semua') {
                  places = places.where(
                    (place) {
                      return place.priceCategory == _selectedCategory;
                    },
                  ).toList();
                }

                /// SORT JARAK
                if (_currentPosition != null) {
                  places.sort(
                    (a, b) {
                      final distanceA = Geolocator.distanceBetween(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                        a.latitude,
                        a.longitude,
                      );

                      final distanceB = Geolocator.distanceBetween(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                        b.latitude,
                        b.longitude,
                      );

                      return distanceA.compareTo(
                        distanceB,
                      );
                    },
                  );
                }

                if (places.isEmpty) {
                  return const Center(
                    child: Text(
                      'Data tidak ditemukan',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];

                    final distance = _currentPosition == null
                        ? null
                        : Geolocator.distanceBetween(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                            place.latitude,
                            place.longitude,
                          );

                    return PlaceCard(
                      place: place,
                      distance: distance,
                      onTap: () => _openDetail(
                        place,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
