import 'package:flutter/material.dart';
class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        // height: 100,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(height: 10),
            Text(title.toUpperCase(),
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(
              value.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
