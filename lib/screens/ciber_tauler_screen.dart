import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/quiz_service.dart';
import '../config/board_setup.dart';
import '../widgets/bottom_nav_bar.dart';

class CiberTaulerScreen extends StatefulWidget {
  final int diceResult;
  const CiberTaulerScreen({super.key, required this.diceResult});

  @override
  CiberTaulerScreenState createState() => CiberTaulerScreenState();
}

class CiberTaulerScreenState extends State<CiberTaulerScreen> {
  int? _activePlayer;
  List<int> _possibleMoves = [];
  final GlobalKey _boardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final quizService = Provider.of<QuizService>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    await quizService.loadGameData(); 

    setState(() {
      _activePlayer = prefs.getInt('TornJoc') ?? 0;
      if (widget.diceResult > 0) {
        final currentPosition = quizService.fitxesPosicions[_activePlayer!];
        _possibleMoves = _calculatePossibleMoves(currentPosition, widget.diceResult);
      }
    });
  }

  List<int> _calculatePossibleMoves(int currentPosition, int diceResult) {
    Set<int> findDestinations(int startNode, int steps, [int? previousNode]) {
      if (steps == 0) return {startNode};
      if (!BoardSetup.boardConnections.containsKey(startNode)) return {};

      final neighbors = BoardSetup.boardConnections[startNode]!;
      final destinations = <int>{};

      for (final neighbor in neighbors) {
        if (neighbor != previousNode) {
          destinations.addAll(findDestinations(neighbor, steps - 1, startNode));
        }
      }
      return destinations;
    }
    return findDestinations(currentPosition, widget.diceResult).toList();
  }

 void _onSquareTapped(int square) {
    if (!_possibleMoves.contains(square)) return;

    final quizService = Provider.of<QuizService>(context, listen: false);
    quizService.moureFitxa(_activePlayer!, square);

    final category = BoardSetup.squareCategories[square]!;
    final isCheeseSquare = BoardSetup.cheeseSquares.contains(square);

    context.go('/ciber-punt/$category?isCheese=$isCheeseSquare');
  }

 @override
Widget build(BuildContext context) {
  final quizService = Provider.of<QuizService>(context);
  final playerColors = [Colors.green, Colors.red, Colors.orange, Colors.blue];

  return Scaffold(
    appBar: AppBar(
      title: const Text('Ciber Tauler'),
      automaticallyImplyLeading: false,
      actions: List.generate(4, (index) {
        final bool isCurrentPlayer = (_activePlayer == index);
        final hasWon = quizService.haGuanyatPartida(index);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Tooltip(
            message: 'Puntuació Jugador ${index + 1}',
            child: ElevatedButton(
              onPressed: () => context.push('/ciber-puntuacio/$index'),
              style: ElevatedButton.styleFrom(
                backgroundColor: playerColors[index],
                foregroundColor: Colors.white,
                shape: CircleBorder(
                  side: isCurrentPlayer 
                    ? const BorderSide(color: Colors.yellow, width: 3)
                    : BorderSide.none,
                ),
                padding: EdgeInsets.zero,
              ),
              child: hasWon ? const Icon(Icons.star, size: 24, color: Colors.amber) : Text('${index + 1}'),
            ),
          ),
        );
      }),
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        return Center(
          child: SizedBox(
            width: boardSize,
            height: boardSize,
            child: Stack(
              key: _boardKey,
              children: [
                Image.asset(
                  'assets/images/osi-trivial-tauler.jpg',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                ..._buildPawns(quizService, boardSize),
                if (widget.diceResult > 0) ..._buildPossibleMoveHighlights(boardSize),
              ],
            ),
          ),
        );
      },
    ),
    bottomNavigationBar: const BottomNavBar(),
  );
}


  List<Widget> _buildPawns(QuizService quizService, double boardSize) {
    final pawns = <Widget>[];
    final playerPawnAssets = [
      'assets/images/osi-trivial-ciberfitxa-verda.gif',
      'assets/images/osi-trivial-ciberfitxa-vermella.gif',
      'assets/images/osi-trivial-ciberfitxa-taronja.gif',
      'assets/images/osi-trivial-ciberfitxa-cel.gif',
    ];

    for (int i = 0; i < quizService.fitxesPosicions.length; i++) {
      pawns.add(_buildPawn(playerPawnAssets[i], quizService.fitxesPosicions[i], i, boardSize));
    }
    return pawns;
  }

  Widget _buildPawn(String imagePath, int position, int playerIndex, double boardSize) {
    final Offset relativeCoords = (position == 0)
        ? BoardSetup.initialPawnCoordinatesRelative[playerIndex]
        : BoardSetup.boardCoordinatesRelative[position];

    final pawnSize = boardSize * 0.07;

    return Positioned(
      left: relativeCoords.dx * boardSize - pawnSize / 2,
      top: relativeCoords.dy * boardSize - pawnSize / 2,
      width: pawnSize,
      height: pawnSize,
      child: Image.asset(imagePath, fit: BoxFit.contain),
    );
  }

  List<Widget> _buildPossibleMoveHighlights(double boardSize) {
    return _possibleMoves.map((move) {
      if (move >= BoardSetup.boardCoordinatesRelative.length) return const SizedBox.shrink();
      
      final relativeCoords = BoardSetup.boardCoordinatesRelative[move];
      final highlightSize = boardSize * 0.08;

      return Positioned(
        left: relativeCoords.dx * boardSize - highlightSize / 2,
        top: relativeCoords.dy * boardSize - highlightSize / 2,
        width: highlightSize,
        height: highlightSize,
        child: GestureDetector(
          onTap: () => _onSquareTapped(move),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow.withAlpha((255 * 0.6).round()), // Corrected opacity
              border: Border.all(color: Colors.yellow.shade800, width: 2),
            ),
          ),
        ),
      );
    }).toList();
  }
}
