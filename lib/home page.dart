import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2E9),
      body: Container(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Loomeé',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w400, color: Color(0xFF333333)),
              ),
              const Text(
                '“Click. Style. Conquer”',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _FeatureCard(
                      title: 'Fit-On',
                      subtitle: 'Try outfits on yourself',
                      onTap: () => _showMsg(context, 'Fit-On'),
                    ),
                    _FeatureCard(
                      title: 'Social Try-On',
                      subtitle: 'See looks styled by others',
                      onTap: () => _showMsg(context, 'Social Try-On'),
                    ),
                    _FeatureCard(
                      title: 'Wardrobe',
                      subtitle: 'All your outfits in one place',
                      onTap: () => _showMsg(context, 'Wardrobe'),
                    ),
                  ],
                ),
              ),

              _buildBottomNav(context),
              const SizedBox(height: 10), // Padding below the nav bar
            ],
          ),
        ),
      ),
    );
  }

  void _showMsg(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $name...'),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF5D5D5D), // Dark grey footer from your design
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(context, Icons.home_outlined, "Home"),
          _navIcon(context, Icons.explore_outlined, "Explore"),
          _navIcon(context, Icons.settings_outlined, "Settings"),
          _navIcon(context, Icons.person_outline, "Profile"),
        ],
      ),
    );
  }

  Widget _navIcon(BuildContext context, IconData icon, String label) {
    return IconButton(
      icon: Icon(icon, size: 30, color: Colors.white),
      onPressed: () => _showMsg(context, label),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({required this.title, required this.subtitle, required this.onTap});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.97),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white, // White cards as per design
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black87, width: 1.5), // Dark border
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4A5568))),
                    const SizedBox(height: 4),
                    Text(widget.subtitle, style: const TextStyle(fontSize: 16, color: Colors.black45)),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, color: Color(0xFF333333), size: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}