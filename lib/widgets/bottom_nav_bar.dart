import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200], // Color de fons gris clar
      elevation: 8.0, 
      child: SafeArea(
        top: false, 
        bottom: true, 
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          height: 56.0, 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton(onPressed: () => context.go('/'), child: const Text('Inici')),
              TextButton(onPressed: () => context.go('/ciber-dau'), child: const Text('Dau')),
              TextButton(onPressed: () => context.go('/ciber-tauler/0'), child: const Text('Tauler')),
              TextButton(onPressed: () => context.go('/ciber-punts'), child: const Text('Punts')),
            ],
          ),
        ),
      ),
    );
  }
}
