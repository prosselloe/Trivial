import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:math';
import '../models/question.dart';

class QuizService with ChangeNotifier {
  // --- ESTRUCTURES DE DADES PER A LA PUNTUACIÓ ---
  List<List<List<int>>> puntuacions = List.generate(4, (_) => List.generate(6, (_) => [0, 0]));
  List<List<bool>> formatgetsGuanyats = List.generate(4, (_) => List.generate(6, (_) => false));
  List<int> fitxesPosicions = [0, 0, 0, 0];

  // --- CLAUS PER A SHaredPreferences ---
  static const String _puntuacionsKey = 'PuntuacionsJoc';
  static const String _formatgetsKey = 'FormatgetsGuanyats';
  static const String _fitxesPosicionsKey = 'FitxesPosicions';
  static const String _winnerKey = 'winner';

  // --- MAPES DE CONFIGURACIÓ ---
  Map<String, List<Question>> questionsByCategory = {};
  final Map<String, int> categoryNameToIndex = {
    'CompresEnLinia': 0, 'Contrasenyes': 1, 'FrausEnLinia': 2,
    'NavegacioSegura': 3, 'ProteccioDispositius': 4, 'XarxesSocials': 5,
  };
  final Map<int, String> categoryIndexToName = {
    0: 'CompresEnLinia', 1: 'Contrasenyes', 2: 'FrausEnLinia',
    3: 'NavegacioSegura', 4: 'ProteccioDispositius', 5: 'XarxesSocials',
  };
  final Map<String, String> categoryToFile = {
    'CompresEnLinia': '11-preguntes-compres-en-linia.csv',
    'Contrasenyes': '01-preguntes-gestio-contrasenyes.csv',
    'FrausEnLinia': '51-preguntes-fraus-en-linia.csv',
    'NavegacioSegura': '41-preguntes-navegacio-segura.csv',
    'ProteccioDispositius': '31-preguntes-proteccio-dispositius.csv',
    'XarxesSocials': '21-preguntes-xarxes-missatgeria.csv',
    'global': '60-preguntes-global-final.csv',
  };

  // --- GESTIÓ DE L'ESTAT DEL JOC ---

  Future<void> inicialitzarJoc() async {
    puntuacions = List.generate(4, (_) => List.generate(6, (_) => [0, 0]));
    formatgetsGuanyats = List.generate(4, (_) => List.generate(6, (_) => false));
    fitxesPosicions = [0, 0, 0, 0];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_winnerKey); // Neteja el guanyador en reiniciar
    await _savePuntuacions();
    await _saveFormatgets();
    await saveFitxesPosicions();
    notifyListeners();
  }

  Future<void> loadGameData() async {
    await _loadPuntuacions();
    await _loadFormatgets();
    await loadFitxesPosicions();
  }

  Future<void> _loadPuntuacions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_puntuacionsKey);
    if (data != null) {
      try {
        puntuacions = (jsonDecode(data) as List).map<List<List<int>>>((player) => 
          (player as List).map<List<int>>((cat) => 
            (cat as List).map<int>((val) => val).toList()
          ).toList()
        ).toList();
      } catch (e) { await inicialitzarJoc(); }
    } else { await inicialitzarJoc(); }
    notifyListeners();
  }

  Future<void> _savePuntuacions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_puntuacionsKey, jsonEncode(puntuacions));
  }

  Future<void> _loadFormatgets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_formatgetsKey);
    if (data != null) {
      try {
        formatgetsGuanyats = (jsonDecode(data) as List).map<List<bool>>((player) => 
          (player as List).map<bool>((val) => val).toList()
        ).toList();
      } catch (e) { await inicialitzarJoc(); }
    } else { await inicialitzarJoc(); }
    notifyListeners();
  }

  Future<void> _saveFormatgets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_formatgetsKey, jsonEncode(formatgetsGuanyats));
  }

  Future<void> loadFitxesPosicions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? posicionsString = prefs.getStringList(_fitxesPosicionsKey);
    if (posicionsString != null && posicionsString.length == 4) {
      fitxesPosicions = posicionsString.map((e) => int.tryParse(e) ?? 0).toList();
    } else {
      fitxesPosicions = [0, 0, 0, 0];
    }
    notifyListeners();
  }

  Future<void> saveFitxesPosicions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_fitxesPosicionsKey, fitxesPosicions.map((e) => e.toString()).toList());
    notifyListeners();
  }

  // --- GESTIÓ DE PREGUNTES ---

  Future<void> loadQuestions() async {
    if (questionsByCategory.isNotEmpty) return;
    for (String category in categoryToFile.keys) {
      try {
        final String data = await rootBundle.loadString('assets/data/${categoryToFile[category]!}');
        final List<List<dynamic>> csvTable = const CsvToListConverter().convert(data, eol: '\n');
        questionsByCategory[category] = csvTable.sublist(1).where((row) => row.length > 5).map((row) => Question.fromCsv(row)).toList();
      } catch (e, s) {
        developer.log('Error loading questions for $category', name: 'quiz_service', error: e, stackTrace: s);
      }
    }
  }

  Question? getRandomQuestion(String category) {
    final categoryQuestions = questionsByCategory[category];
    if (categoryQuestions == null || categoryQuestions.isEmpty) return null;
    final question = categoryQuestions.removeAt(Random().nextInt(categoryQuestions.length));
    return question;
  }

  // --- ACCIONS DEL JOC ---

  void moureFitxa(int playerIndex, int newPosition) {
    if (playerIndex < 0 || playerIndex >= fitxesPosicions.length) return;
    fitxesPosicions[playerIndex] = newPosition;
    saveFitxesPosicions();
  }

  void actualitzarPuntuacio(int playerIndex, String category, bool isCorrect) {
    final categoryIndex = categoryNameToIndex[category];
    if (categoryIndex == null || playerIndex < 0 || playerIndex >= puntuacions.length) return;

    if (isCorrect) {
      puntuacions[playerIndex][categoryIndex][0]++;
    } else {
      puntuacions[playerIndex][categoryIndex][1]++;
    }
    _savePuntuacions();
    notifyListeners();
  }
  
  void guanyarFormatget(int playerIndex, String category) {
    final categoryIndex = categoryNameToIndex[category];
    if (categoryIndex == null || playerIndex < 0 || playerIndex >= formatgetsGuanyats.length) return;
    
    formatgetsGuanyats[playerIndex][categoryIndex] = true;
    _saveFormatgets();
    notifyListeners();
  }

  Future<void> setWinner(int playerIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_winnerKey, playerIndex);
    notifyListeners();
  }

  bool haGuanyatFormatget(int playerIndex, String category) {
    final categoryIndex = categoryNameToIndex[category];
    if (categoryIndex == null) return false;
    return formatgetsGuanyats[playerIndex][categoryIndex];
  }

  bool haGuanyatPartida(int playerIndex) {
    if (playerIndex < 0 || playerIndex >= formatgetsGuanyats.length) return false;
    return formatgetsGuanyats[playerIndex].every((formatget) => formatget == true);
  }
}
