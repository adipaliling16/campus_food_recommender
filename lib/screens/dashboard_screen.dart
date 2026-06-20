import 'package:flutter/material.dart';

import '../models/food_place.dart';
import '../services/place_service.dart';
import 'admin_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class _T {
  static const bg1 = Color(0xFF07111F);

  static const bg2 = Color(0xFF0B1628);

  static const bg3 = Color(0xFF12243D);

  static const surface = Color(0xFF152235);

  static const border = Color(0xFF223650);

  static const accent = Color(0xFF22C55E);

  static const accentDim = Color(0xFF163D28);

  static const white = Colors.white;

  static const white60 = Color(0x99FFFFFF);

  static const white30 = Color(0x4DFFFFFF);
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.role,
    required this.userName,
  });

  final UserRole role;
  final String userName;

  bool get isAdmin => role == UserRole.admin;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FoodPlace>>(
      stream: PlaceService.getPlaces(),
      builder: (context, snapshot) {
        final places = snapshot.data ?? [];

        final totalPlaces = places.length;

        final totalReviews = places.fold<int>(
          0,
          (sum, place) => sum + place.reviewCount,
        );

        final ratedPlaces = places
            .where(
              (place) => place.reviewCount > 0,
            )
            .toList();

        final averageRating = ratedPlaces.isEmpty
            ? 0.0
            : ratedPlaces
                    .map(
                      (e) => e.rating,
                    )
                    .reduce(
                      (a, b) => a + b,
                    ) /
                ratedPlaces.length;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _T.bg1,
                  _T.bg2,
                  _T.bg3,
                ],
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TITIK KUMPUL',
                            style: TextStyle(
                              color: _T.accent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            'Rekomendasi Cafe & Kuliner',
                            style: TextStyle(
                              color: _T.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: _T.surface,
                          borderRadius: BorderRadius.circular(
                            14,
                          ),
                          border: Border.all(
                            color: _T.border,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _T.surface,
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                      border: Border.all(
                        color: _T.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: _T.accentDim,
                          child: Icon(
                            isAdmin
                                ? Icons.admin_panel_settings_rounded
                                : Icons.person_rounded,
                            color: _T.accent,
                            size: 30,
                          ),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat datang',
                                style: TextStyle(
                                  color: _T.white60,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),
                  // RINGKASAN
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _T.surface,
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                      border: Border.all(
                        color: _T.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.storefront_rounded,
                          color: const Color(0xFF22C55E),
                          label: 'Total Tempat',
                          value: '$totalPlaces',
                        ),
                        Divider(
                          color: Colors.white.withOpacity(0.08),
                        ),
                        _InfoRow(
                          icon: Icons.reviews_rounded,
                          color: const Color(0xFFF59E0B),
                          label: 'Total Review',
                          value: '$totalReviews',
                        ),
                        Divider(
                          color: Colors.white.withOpacity(0.08),
                        ),
                        _InfoRow(
                          icon: Icons.star_rounded,
                          color: const Color(0xFFFFD700),
                          label: 'Rating Rata-rata',
                          value: averageRating.toStringAsFixed(1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  const _SectionLabel(
                    label: 'Cafe Populer',
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        final place = places[index];

                        return Container(
                          width: 280,
                          margin: const EdgeInsets.only(
                            right: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              22,
                            ),
                            border: Border.all(
                              color: _T.border,
                            ),
                            image: place.imageUrls.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(
                                      place.imageUrls.first,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  0.25,
                                ),
                                blurRadius: 18,
                                offset: const Offset(
                                  0,
                                  8,
                                ),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(
                              18,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                22,
                              ),
                              gradient: const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Color(
                                    0xDD000000,
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      30,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        place.rating.toStringAsFixed(
                                          1,
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  place.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  place.location,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  const _SectionLabel(
                    label: 'Menu',
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _MenuRow(
                    title: 'Cari Tempat',
                    subtitle: 'Temukan cafe dan tempat makan',
                    icon: Icons.travel_explore_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                      );
                    },
                  ),

                  if (isAdmin) ...[
                    const SizedBox(
                      height: 10,
                    ),
                    _MenuRow(
                      title: 'Admin Panel',
                      subtitle: 'Tambah dan edit tempat',
                      icon: Icons.admin_panel_settings_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminScreen(),
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 22,
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(
        18,
      ),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(
          18,
        ),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color: _T.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(
                10,
              ),
              decoration: BoxDecoration(
                color: _T.accentDim,
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: Icon(
                icon,
                color: _T.accent,
              ),
            ),
            const SizedBox(
              width: 14,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
