import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/quiz_service.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    Provider.of<QuizService>(context, listen: false).loadGameData();
    Provider.of<QuizService>(context, listen: false).loadQuestions();
    _audioPlayer.play(AssetSource('audio/mystery.mp3'));
  }

  Future<void> _launchCreditsURL() async {
    final Uri url = Uri.parse('https://prosselloe.wordpress.com/?p=11787');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No s\'ha pogut obrir l\'enllaç')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trivial Ciberseguretat'),
        backgroundColor: Colors.grey[200], // Color de fons gris clar
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _mostrarDialegNovaPartida(context),
            tooltip: 'Nova Partida',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _launchCreditsURL, 
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/images/osi-trivial-ciberseguridad.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  void _mostrarDialegNovaPartida(BuildContext context) {
    final quizService = Provider.of<QuizService>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nova Partida'),
          content: const Text('Vols començar una nova partida? S\'esborrarà el progrés actual.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel·lar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Començar'),
              onPressed: () {
                quizService.inicialitzarJoc(); 
                Navigator.of(context).pop();
                context.go('/ciber-dau');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
