import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CiberCreditsScreen extends StatelessWidget {
  const CiberCreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crèdits'),
        automaticallyImplyLeading: false, // Traiem la fletxa de tornar automàtica
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: Center(
                child: Text(
                  'Aquesta aplicació ha estat dissenyada per Ciberseguretat.cat per a l\'alumnat de 6è de Primària de l\'Escola XXXX.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0), // Marge inferior per separar el botó
              child: ElevatedButton(
                onPressed: () {
                  context.go('/'); // Tornem a la pantalla d'inici
                },
                child: const Text('Tornar a l\'inici'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
