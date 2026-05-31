import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/quiz_service.dart';

class CiberPuntuacioScreen extends StatelessWidget {
  final int playerIndex;

  const CiberPuntuacioScreen({super.key, required this.playerIndex});

  @override
  Widget build(BuildContext context) {
    final quizService = Provider.of<QuizService>(context);

    final List<String> cheeseImages = [
      'assets/images/osi-trivial-formatge-compres-en-linia.png',       // 0
      'assets/images/osi-trivial-formatge-gestio-contrasenyes.png',    // 1
      'assets/images/osi-trivial-formatge-fraus-en-linia.png',          // 2
      'assets/images/osi-trivial-formatge-navegacio-segura.png',      // 3
      'assets/images/osi-trivial-formatge-proteccio-dispositius.png', // 4
      'assets/images/osi-trivial-formatge-xarxes-missatgeria.png',    // 5
    ];

    final List<String> categoryNames = [
      'Compres en Línia',
      'Contrasenyes',
      'Fraus en Línia',
      'Navegació Segura',
      'Protecció de Dispositius',
      'Xarxes Socials',
    ];

    final playerName = 'Jugador ${playerIndex + 1}';
    final playerColor = [Colors.green, Colors.red, Colors.orange, Colors.blue][playerIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Puntuació de $playerName'),
        backgroundColor: playerColor,
        leading: IconButton(
          icon: const Icon(Icons.close), 
          onPressed: () => context.go('/ciber-tauler/0'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Formatgets Guanyats',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Roda de Formatgets
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      [
                        'assets/images/osi-trivial-formatges-verda.png',
                        'assets/images/osi-trivial-formatges-vermella.png',
                        'assets/images/osi-trivial-formatges-taronja.png',
                        'assets/images/osi-trivial-formatges-cel.png',
                      ][playerIndex],
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    for (int i = 0; i < 6; i++)
                      if (quizService.formatgetsGuanyats[playerIndex][i])
                        _buildCheeseImage(i, cheeseImages[i]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Divider(thickness: 1.5),
            const SizedBox(height: 16),

            Text(
              'Resum de Puntuacions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Table(
              border: TableBorder.all(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: playerColor.withAlpha(51), // CORREGIT: 0.2 * 255 = 51
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  children: const [
                    Padding(padding: EdgeInsets.all(12.0), child: Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    Padding(padding: EdgeInsets.all(12.0), child: Center(child: Text('Correctes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
                    Padding(padding: EdgeInsets.all(12.0), child: Center(child: Text('Errors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
                  ],
                ),
                for (int i = 0; i < 6; i++)
                  TableRow(
                    decoration: BoxDecoration(
                      color: i % 2 == 0 ? Colors.grey.shade50 : Colors.transparent,
                    ),
                    children: [
                      Padding(padding: const EdgeInsets.all(10.0), child: Text(categoryNames[i], style: const TextStyle(fontSize: 15))),
                      Padding(padding: const EdgeInsets.all(10.0), child: Center(child: Text('${quizService.puntuacions[playerIndex][i][0]}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),))),
                      Padding(padding: const EdgeInsets.all(10.0), child: Center(child: Text('${quizService.puntuacions[playerIndex][i][1]}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),))),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Tornar al Tauler'),
              style: ElevatedButton.styleFrom(
                backgroundColor: playerColor, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () => context.go('/ciber-tauler/0'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheeseImage(int index, String imagePath) {
    // Posicions dels formatgets (index 0 a 5)
    const positions = [
      // Compres en Línia (a baix)
      Alignment(0.0, 0.5),
      // Contrasenyes (a dalt)
      Alignment(0.0, -0.5),
      // Fraus en Línia (dreta a baix)
      Alignment(0.5, 0.25),
      // Navegació Segura (esquerra a dalt)
      Alignment(-0.5, -0.25),
      // Protecció de Dispositius (esquerra a baix)
      Alignment(-0.5, 0.25),
      // Xarxes Socials (dreta a dalt)
      Alignment(0.5, -0.25),
    ];

    return Align(
      alignment: positions[index],
      child: Image.asset(
        imagePath,
        width: 125, // Reduïm la mida a la meitat
        height: 125,
      ),
    );
  }
}
