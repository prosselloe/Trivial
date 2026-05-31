class Question {
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String correctAnswer;
  final String explanation;

  Question({
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.correctAnswer,
    required this.explanation,
  });

  factory Question.fromCsv(List<dynamic> csvRow) {
    // Funció de neteja robusta per a totes les cadenes de text.
    String cleanText(String text) {
      return text
          .replaceAll('\n', ' ') // Reemplaça el literal '\n'
          .trim();               // Elimina espais al principi/final
    }

    // Neteja de l'explicació.
    String explanationText = cleanText(csvRow[5].toString());
    if (explanationText.startsWith('Resposta:')) {
      explanationText = explanationText.substring('Resposta:'.length).trim();
    }

    // Neteja de la resposta correcta per obtenir la lletra.
    String fullAnswer = cleanText(csvRow[4].toString());
    String correctAnswerLetter = fullAnswer.isNotEmpty ? fullAnswer[0] : '';

    return Question(
      questionText: cleanText(csvRow[0].toString()),
      optionA: cleanText(csvRow[1].toString()),
      optionB: cleanText(csvRow[2].toString()),
      optionC: cleanText(csvRow[3].toString()),
      correctAnswer: correctAnswerLetter,
      explanation: explanationText,
    );
  }
}
