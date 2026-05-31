import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class CiberDauScreen extends StatefulWidget {
  const CiberDauScreen({super.key});

  @override
  CiberDauScreenState createState() => CiberDauScreenState();
}

class CiberDauScreenState extends State<CiberDauScreen> {
  late SharedPreferences _prefs;
  int? _activePlayer;
  String? _activePlayerName;
  String? _activePlayerPawnAsset;
  int? _diceResult;
  bool _isRolling = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, String>> _playerInfo = [
    {'name': 'Verda', 'pawn': 'assets/images/osi-trivial-ciberfitxa-verda.gif'},
    {'name': 'Vermella', 'pawn': 'assets/images/osi-trivial-ciberfitxa-vermella.gif'},
    {'name': 'Taronja', 'pawn': 'assets/images/osi-trivial-ciberfitxa-taronja.gif'},
    {'name': 'Cel', 'pawn': 'assets/images/osi-trivial-ciberfitxa-cel.gif'},
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _updateAndRefresh();
  }
  
  void _updateAndRefresh() {
    setState(() {
      _activePlayer = _prefs.getInt('TornJoc') ?? 0;
      _activePlayerName = _playerInfo[_activePlayer!]['name'];
      _activePlayerPawnAsset = _playerInfo[_activePlayer!]['pawn'];
      _diceResult = null;
      _isRolling = false;
    });
  }

  void _rollDice() async {
    if (_isRolling) return;

    setState(() {
      _isRolling = true;
    });

    await _audioPlayer.play(AssetSource('audio/clock_ticking.mp3'));

    setState(() {
        _diceResult = Random().nextInt(6) + 1;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go('/ciber-tauler/$_diceResult');
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_activePlayer == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ciber Dau'),
          backgroundColor: Colors.grey[200], // Color de fons gris clar
          automaticallyImplyLeading: false,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/osi-trivial-tauler.jpg',
                    fit: BoxFit.contain,
                  ),
                  if (_diceResult != null)
                    _buildTurnAndResultDisplay()
                  else
                    _buildTurnDisplay(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: _buildDiceRollButton(),
            ),
            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTurnDisplay() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((255 * 0.9).round()),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Torn de la fitxa:',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Image.asset(_activePlayerPawnAsset!, height: 60),
          const SizedBox(height: 10),
          Text(
            _activePlayerName!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnAndResultDisplay() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((255 * 0.9).round()),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$_activePlayerName ha tret un:',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Image.asset(
            'assets/images/osi-trivial-dau-$_diceResult.jpg',
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildDiceRollButton() {
    return ElevatedButton.icon(
      onPressed: _isRolling ? null : _rollDice,
      icon: _isRolling
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3))
          : const Icon(Icons.casino),
      label: const Text('Tirar el Dau', style: TextStyle(fontSize: 20)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextButton(onPressed: () => context.go('/'), child: const Text('Inici')),
          TextButton(onPressed: () => context.push('/ciber-dau'), child: const Text('Dau')),
          TextButton(onPressed: () => context.push('/ciber-tauler/0'), child: const Text('Tauler')),
          TextButton(onPressed: () => context.push('/ciber-punts'), child: const Text('Punts')),
        ],
      ),
    );
  }
}
