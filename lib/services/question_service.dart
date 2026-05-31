import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/question.dart';

class QuestionService {
  Future<List<Question>> loadQuestions(String filePath) async {
    final rawData = await rootBundle.loadString(filePath);
    final List<List<dynamic>> listData = const CsvToListConverter().convert(rawData, fieldDelimiter: ',');

    final List<Question> questions = [];
    for (var row in listData) {
        // Expected format: 0) Pregunta, a) OpcioA, b) OpcioB, c) OpcioC, RespostaCorrecta, Explicacio
        if (row.length >= 6) {
            questions.add(
                Question(
                    questionText: row[0].toString(),
                    optionA: row[1].toString(),
                    optionB: row[2].toString(),
                    optionC: row[3].toString(),
                    correctAnswer: row[4].toString(),
                    explanation: row[5].toString(),
                ),
            );
        }
    }
    return questions;
  }
}
