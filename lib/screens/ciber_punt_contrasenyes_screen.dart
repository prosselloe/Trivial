import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/question.dart';
import '../services/quiz_service.dart';
import '../widgets/bottom_nav_bar.dart';

class CiberPuntContrasenyesScreen extends StatefulWidget {
  final bool isCheeseSquare;
  const CiberPuntContrasenyesScreen({super.key, this.isCheeseSquare = false});

  @override
  State<CiberPuntContrasenyesScreen> createState() => _CiberPuntContrasenyesScreenState();
}

class _CiberPuntContrasenyesScreenState extends State<CiberPuntContrasenyesScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _activePlayer;
  Question? _currentQuestion;
  bool _answered = false;
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final quizService = Provider.of<QuizService>(context, listen: false);
    final activePlayer = prefs.getInt('TornJoc') ?? 0;
    
    setState(() {
      _activePlayer = activePlayer;
      _currentQuestion = quizService.getRandomQuestion('Contrasenyes');
    });
  }

  Future<void> _playSound(bool isCorrect) async {
    final sound = isCorrect ? 'audio/cheer.mp3' : 'audio/boom_cloud.mp3';
    await _audioPlayer.play(AssetSource(sound));
  }

  void _handleAnswer(String selectedOption) {
    if (_answered || _activePlayer == null) return;

    final quizService = Provider.of<QuizService>(context, listen: false);
    const category = 'Contrasenyes';
    final isCorrect = selectedOption == _currentQuestion!.correctAnswer;

    _playSound(isCorrect);

    setState(() {
      _answered = true;
      _selectedOption = selectedOption;
    });

    quizService.actualitzarPuntuacio(_activePlayer!, category, isCorrect);

    if (isCorrect && widget.isCheeseSquare) {
      quizService.guanyarFormatget(_activePlayer!, category);
    }

    _moveToNextTurn(isCorrect);
  }

  void _moveToNextTurn(bool isCorrect) async {
    if (!isCorrect) {
      final prefs = await SharedPreferences.getInstance();
      int nextPlayer = ((_activePlayer ?? 0) + 1) % 4;
      await prefs.setInt('TornJoc', nextPlayer);
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/ciber-dau');
      }
    });
  }

 @override
  Widget build(BuildContext context) {
    if (_currentQuestion == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Punt: Contrasenyes')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No queden preguntes en aquesta categoria.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/ciber-dau'),
                child: const Text('Tornar al Dau'),
              )
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBar(),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Punt: Contrasenyes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('assets/images/osi-trivial-ciberpunt-gestio-de-contrasenyes.jpg'),
            const SizedBox(height: 20),
            Text(
              _currentQuestion!.questionText,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ..._buildOptions(),
            if (_answered) _buildExplanation(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  List<Widget> _buildOptions() {
    final options = {
      'a': _currentQuestion!.optionA,
      'b': _currentQuestion!.optionB,
      'c': _currentQuestion!.optionC,
    };

    return options.entries.map((entry) {
      final optionLetter = entry.key;
      final optionText = entry.value;
      Color? buttonColor;

      if (_answered) {
        if (optionLetter == _currentQuestion!.correctAnswer) {
          buttonColor = Colors.green.shade700;
        } else if (optionLetter == _selectedOption) {
          buttonColor = Colors.red.shade700;
        }
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ElevatedButton(
          onPressed: () => _handleAnswer(optionLetter),
          style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
          child: Text(optionText, textAlign: TextAlign.center),
        ),
      );
    }).toList();
  }

  Widget _buildExplanation() {
    final isCorrect = _selectedOption == _currentQuestion!.correctAnswer;
    return Card(
      color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
      margin: const EdgeInsets.only(top: 20.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              isCorrect ? 'CORRECTE!' : 'INCORRECTE!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isCorrect ? Colors.green.shade900 : Colors.red.shade900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _currentQuestion!.explanation,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
