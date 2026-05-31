import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/quiz_service.dart';

class Scoreboard extends StatelessWidget {
  const Scoreboard({super.key});

  @override
  Widget build(BuildContext context) {
    final quizService = Provider.of<QuizService>(context);
    // CORREGIT: El nom correcte de la propietat és 'puntuacions'
    final puntuacio = quizService.puntuacions;

    // Noms de les categories i dels jugadors per a la taula
    final List<String> categories = [
      'Compres', 'Contras.', 'Fraus', 'Naveg.', 'Prot. Disp.', 'Xarxes Soc.'
    ];
    final List<String> jugadors = ['Jugador 1', 'Jugador 2', 'Jugador 3', 'Jugador 4'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Jugador')),
          ...categories.map((c) => DataColumn(label: Text(c))),
        ],
        rows: List.generate(jugadors.length, (playerIndex) {
          return DataRow(
            cells: [
              DataCell(Text(jugadors[playerIndex])),
              ...List.generate(categories.length, (catIndex) {
                final correctes = puntuacio[playerIndex][catIndex][0];
                final incorrectes = puntuacio[playerIndex][catIndex][1];
                return DataCell(Text('$correctes / $incorrectes'));
              }),
            ],
          );
        }),
      ),
    );
  }
}
