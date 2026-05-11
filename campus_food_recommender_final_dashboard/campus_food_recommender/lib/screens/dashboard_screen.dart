import 'dart:ui';
import 'package:flutter/material.dart';

import '../data/food_repository.dart';
import 'admin_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.role,
    required this.userName,
  });

  final UserRole role;
  final String userName;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _repository = FoodRepository.instance;

  bool get _isAdmin => widget.role == UserRole.admin;

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _openAdmin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminScreen()),
    );
    setState(() {});
  }

  Future<void> _openRecommendation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
    setState(() {});
  }

  void _openMonitoring({
    required int totalPlaces,
    required int totalReviews,
    required double averageRating,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF102A2F).withOpacity(0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Monitoring Sistem',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 22),
              _statItem(
                  Icons.storefront_rounded, 'Total Tempat', '$totalPlaces'),
              _statItem(
                  Icons.rate_review_rounded, 'Total Review', '$totalReviews'),
              _statItem(
                Icons.star_rounded,
                'Rating Rata-rata',
                averageRating.toStringAsFixed(1),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFB2FF59)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final places = _repository.getAllPlaces();
    final totalReviews =
        places.fold<int>(0, (sum, place) => sum + place.reviews.length);
    final averageRating = places.isEmpty
        ? 0.0
        : places.map((place) => place.averageRating).reduce((a, b) => a + b) /
            places.length;

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      body: Stack(
        children: [
          const _LuxuryBackground(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _TopBar(isAdmin: _isAdmin, onLogout: _logout),
                  const SizedBox(height: 24),
                  _HeroCard(userName: widget.userName, isAdmin: _isAdmin),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _PremiumStatCard(
                          title: 'Tempat',
                          value: '${places.length}',
                          icon: Icons.storefront_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PremiumStatCard(
                          title: 'Review',
                          value: '$totalReviews',
                          icon: Icons.rate_review_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _WideStatCard(
                    title: 'Rating Rata-rata',
                    value: averageRating.toStringAsFixed(1),
                    subtitle: 'Berdasarkan semua tempat makan',
                    icon: Icons.star_rounded,
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Menu Utama',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LuxuryMenuTile(
                    icon: Icons.travel_explore_rounded,
                    title: 'Cari Rekomendasi',
                    subtitle: 'Temukan tempat makan dan cafe terbaik.',
                    gradient: const [Color(0xFF00C853), Color(0xFFB2FF59)],
                    onTap: _openRecommendation,
                  ),
                  if (_isAdmin) ...[
                    _LuxuryMenuTile(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Admin Panel',
                      subtitle: 'Tambah, edit, dan hapus data tempat.',
                      gradient: const [Color(0xFF448AFF), Color(0xFF40C4FF)],
                      onTap: _openAdmin,
                    ),
                    _LuxuryMenuTile(
                      icon: Icons.analytics_rounded,
                      title: 'Monitoring Sistem',
                      subtitle: 'Pantau statistik aplikasi secara ringkas.',
                      gradient: const [Color(0xFFFFD740), Color(0xFFFFAB40)],
                      onTap: () => _openMonitoring(
                        totalPlaces: places.length,
                        totalReviews: totalReviews,
                        averageRating: averageRating,
                      ),
                    ),
                  ] else ...[
                    _LuxuryMenuTile(
                      icon: Icons.reviews_rounded,
                      title: 'Beri Rating & Ulasan',
                      subtitle: 'Bagikan pengalamanmu setelah berkunjung.',
                      gradient: const [Color(0xFFFFD740), Color(0xFFFFAB40)],
                      onTap: _openRecommendation,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxuryBackground extends StatelessWidget {
  const _LuxuryBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF07111F), Color(0xFF0D2B36), Color(0xFF12343B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -70,
          child: _GlowCircle(
              size: 220, color: Colors.greenAccent.withOpacity(0.25)),
        ),
        Positioned(
          bottom: -90,
          left: -80,
          child: _GlowCircle(
              size: 260, color: Colors.lightBlueAccent.withOpacity(0.20)),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isAdmin, required this.onLogout});

  final bool isAdmin;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TITIK KUMPUL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Rekomendasi Restaurant dan Cafe',
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
        IconButton(
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.userName, required this.isAdmin});

  final String userName;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Row(
        children: [
          Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFB2FF59), Color(0xFF00C853)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.35),
                  blurRadius: 22,
                ),
              ],
            ),
            child: Icon(
              isAdmin
                  ? Icons.admin_panel_settings_rounded
                  : Icons.person_rounded,
              size: 34,
              color: const Color(0xFF07111F),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selamat datang,',
                    style: TextStyle(color: Colors.white70)),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAdmin ? 'ADMIN ACCESS' : 'USER ACCESS',
                    style: const TextStyle(
                      color: Color(0xFFB2FF59),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumStatCard extends StatelessWidget {
  const _PremiumStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFB2FF59), size: 30),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.white60)),
        ],
      ),
    );
  }
}

class _WideStatCard extends StatelessWidget {
  const _WideStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Row(
        children: [
          Icon(icon, color: Colors.amberAccent, size: 38),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxuryMenuTile extends StatelessWidget {
  const _LuxuryMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: _GlassCard(
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: const Color(0xFF07111F), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(color: Colors.white60)),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white54,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
