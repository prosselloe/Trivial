
import 'dart:math';
import 'package:flutter/painting.dart';

// Aquest fitxer defineix l'estructura lògica i de coordenades del tauler del joc.
// S'ha reescrit completament per reflectir la topologia correcta: un nucli central,
// branques radials i un cercle exterior que connecta les caselles de formatget.

class BoardSetup {
  // --- Constants de l'Estructura del Tauler ---
  static const int numSpokes = 6;
  // Longitud de la branca des del centre FINS a la casella de formatget (exclosa).
  static const int spokeInnerLength = 3;
  // Caselles a l'anell exterior ENTRE dues caselles de formatget.
  static const int outerRingSegmentLength = 3;

  // --- Propietats Calculades ---
  static final Map<int, List<int>> boardConnections = _generateConnections();
  static final List<Offset> boardCoordinatesRelative = _generateVisualCoordinates();
  static final Map<int, String> squareCategories = _generateHardcodedCategories();
  
  // Les caselles de formatget són les primeres de cada segment de 7.
  static final List<int> cheeseSquares = List.generate(numSpokes, (i) => i * (spokeInnerLength + 1 + outerRingSegmentLength) + 1);

  /// Genera el mapa de categories per a les 43 caselles segons l'especificació.
  static Map<int, String> _generateHardcodedCategories() {
    final categories = <int, String>{};
    categories[0] = 'Centre'; // Casella central

    // Definim la correspondència entre els números donats i els noms de les categories.
    const categoryNames = {
      0: 'CompresEnLinia',
      1: 'Contrasenyes',
      2: 'FrausEnLinia',
      3: 'NavegacioSegura',
      4: 'ProteccioDispositius',
      5: 'XarxesSocials',
    };

    // Dades de l'usuari per a les categories (sentit horari, començant per dalt)
    const outerRingCats = [
      [5, 4, 3, 2], // Dalt
      [1, 5, 1, 3], // Dalt-dreta
      [2, 1, 0, 4], // Baix-dreta
      [3, 2, 0, 5], // Baix
      [4, 0, 3, 5], // Baix-esquerra
      [0, 4, 1, 2], // Dalt-esquerra
    ];
    const spokeCats = [
      [5, 2, 5, 2], // Dalt
      [1, 4, 1, 3], // Dalt-dreta
      [2, 0, 2, 5], // Baix-dreta
      [3, 5, 3, 5], // Baix
      [4, 1, 4, 5], // Baix-esquerra
      [0, 2, 3, 4], // Dalt-esquerra
    ];
    
    // CORRECCIÓ: Mapa per alinear l'ordre de generació del codi amb l'ordre de les dades de l'usuari.
    // L'índex del mapa és l'índex 'i' del bucle de generació.
    // El valor és l'índex corresponent a les llistes 'outerRingCats' i 'spokeCats'.
    // i=0 (baix-dreta) -> dades[2]
    // i=1 (baix) -> dades[3]
    // i=2 (baix-esquerra) -> dades[4]
    // i=3 (dalt-esquerra) -> dades[5]
    // i=4 (dalt) -> dades[0]
    // i=5 (dalt-dreta) -> dades[1]
    const indexMap = [2, 3, 4, 5, 0, 1];

    const totalSegmentLength = spokeInnerLength + 1 + outerRingSegmentLength; // 7

    for (int i = 0; i < numSpokes; i++) {
      final userDataIndex = indexMap[i]; // Utilitza el mapa per obtenir l'índex correcte

      // --- Defineix els índexs per al segment actual ---
      final cheeseSquare = i * totalSegmentLength + 1;
      final spokeOuter = cheeseSquare + 1;
      final spokeMiddle = cheeseSquare + 2;
      final spokeInner = cheeseSquare + 3;
      
      final outer1 = cheeseSquare + 4;
      final outer2 = cheeseSquare + 5;
      final outer3 = cheeseSquare + 6;

      // --- Assigna les categories basant-se en les dades i el mapa d'índexs ---
      categories[cheeseSquare] = categoryNames[spokeCats[userDataIndex][0]]!;
      categories[spokeOuter] = categoryNames[spokeCats[userDataIndex][1]]!;
      categories[spokeMiddle] = categoryNames[spokeCats[userDataIndex][2]]!;
      categories[spokeInner] = categoryNames[spokeCats[userDataIndex][3]]!;
      
      categories[outer1] = categoryNames[outerRingCats[userDataIndex][1]]!;
      categories[outer2] = categoryNames[outerRingCats[userDataIndex][2]]!;
      categories[outer3] = categoryNames[outerRingCats[userDataIndex][3]]!;
    }

    return categories;
  }

  /// Genera el graf de connexions per a les 43 caselles (versió corregida i robusta).
  static Map<int, List<int>> _generateConnections() {
    final connections = <int, List<int>>{};
    const totalSquares = 1 + numSpokes * (spokeInnerLength + 1 + outerRingSegmentLength);
    const totalSegmentLength = spokeInnerLength + 1 + outerRingSegmentLength; // 7

    // 1. Inicialitza tots els nodes del graf.
    for (int i = 0; i < totalSquares; i++) {
      connections[i] = [];
    }

    // 2. Crea les connexions per a cada un dels 6 segments.
    for (int i = 0; i < numSpokes; i++) {
      // Defineix els índexs per al segment actual per a més claredat.
      final cheeseSquare = i * totalSegmentLength + 1;
      final spoke1 = cheeseSquare + 1; // Casella del braç més externa
      final spoke2 = cheeseSquare + 2;
      final spoke3 = cheeseSquare + 3; // Casella del braç més interna
      
      final outer1 = cheeseSquare + 4; // Primera casella de l'anell exterior
      final outer2 = cheeseSquare + 5;
      final outer3 = cheeseSquare + 6; // Darrera casella de l'anell exterior

      // --- CONNEXIONS DELS BRAÇOS ---
      // Braç intern <-> Centre
      connections[spoke3]!.add(0);
      connections[0]!.add(spoke3);

      // Connexions lineals del braç
      connections[spoke2]!.add(spoke3);
      connections[spoke3]!.add(spoke2);
      connections[spoke1]!.add(spoke2);
      connections[spoke2]!.add(spoke1);
      connections[cheeseSquare]!.add(spoke1);
      connections[spoke1]!.add(cheeseSquare);

      // --- CONNEXIONS DE L'ANELL EXTERIOR ---
      // Connexions lineals de la secció de l'anell
      connections[cheeseSquare]!.add(outer1);
      connections[outer1]!.add(cheeseSquare);
      connections[outer1]!.add(outer2);
      connections[outer2]!.add(outer1);
      connections[outer2]!.add(outer3);
      connections[outer3]!.add(outer2);
      
      // Connecta el final d'aquesta secció de l'anell amb la casella de formatget SEGÜENT.
      final nextI = (i + 1) % numSpokes;
      final nextCheeseSquare = nextI * totalSegmentLength + 1;
      connections[outer3]!.add(nextCheeseSquare);
      connections[nextCheeseSquare]!.add(outer3);
    }
    
    return connections;
  }

  /// Genera coordenades relatives visuals per a les 43 caselles.
  static List<Offset> _generateVisualCoordinates() {
    final coordinates = List<Offset>.filled(43, Offset.zero);
    const verticalShift = -0.04;
    const center = Offset(0.5, 0.5 + verticalShift);

    const contractionFactor = 0.02; 
    const outerRingRadius = 0.44 - contractionFactor;
    const innerSpokeStartRadius = 0.15 - contractionFactor;
    const innerSpokeEndRadius = 0.35 - contractionFactor;
    const innerSpokeRadiusRange = innerSpokeEndRadius - innerSpokeStartRadius;

    coordinates[0] = center; // Coordenada per a la casella 0 (centre)

    const totalSegmentLength = spokeInnerLength + 1 + outerRingSegmentLength; // 7

    for (int i = 0; i < numSpokes; i++) {
      // Angle per al braç. Aquesta és la font del desajust.
      // i=0 -> 30º (baix-dreta), i=1 -> 90º (baix), i=2 -> 150º (baix-esquerra)
      // i=3 -> 210º (dalt-esquerra), i=4 -> 270º (dalt), i=5 -> 330º (dalt-dreta)
      final spokeAngle = (2 * pi * i / numSpokes) + (pi / 6);
      
      // Defineix els índexs per al segment actual
      final cheeseIndex = i * totalSegmentLength + 1;
      final spokeIndices = List.generate(spokeInnerLength, (j) => cheeseIndex + 1 + j);
      final outerRingIndices = List.generate(outerRingSegmentLength, (j) => cheeseIndex + 4 + j);

      // 1. Coordenades de la casella de formatget
      coordinates[cheeseIndex] = Offset(
        center.dx + outerRingRadius * cos(spokeAngle),
        center.dy + outerRingRadius * sin(spokeAngle),
      );

      // 2. Coordenades de la branca interior 
      for (int j = 0; j < spokeInnerLength; j++) {
        final radius = innerSpokeEndRadius - (j / (spokeInnerLength-1)) * innerSpokeRadiusRange;
        coordinates[spokeIndices[j]] = Offset(
          center.dx + radius * cos(spokeAngle),
          center.dy + radius * sin(spokeAngle),
        );
      }

      // 3. Coordenades de l'anell exterior
      final nextSpokeAngle = (2 * pi * ((i + 1) % numSpokes) / numSpokes) + (pi / 6);
      for (int j = 0; j < outerRingSegmentLength; j++) {
        // Interpola l'angle entre el braç actual i el següent
        final angle = spokeAngle + (j + 1) * (nextSpokeAngle - spokeAngle) / (outerRingSegmentLength + 1);
        coordinates[outerRingIndices[j]] = Offset(
          center.dx + outerRingRadius * cos(angle),
          center.dy + outerRingRadius * sin(angle),
        );
      }
    }
    return coordinates;
  }

  // Coordenades relatives per a les fitxes a la posició inicial.
  static const List<Offset> initialPawnCoordinatesRelative = [
    Offset(0.5, 0.5 + 0.08 - 0.04),
    Offset(0.5, 0.5 - 0.08 - 0.04),
    Offset(0.5 + 0.08, 0.5 - 0.04),
    Offset(0.5 - 0.08, 0.5 - 0.04),
  ];
}
