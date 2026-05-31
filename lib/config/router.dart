import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/ciber_tauler_screen.dart';
import '../screens/ciber_dau_screen.dart';
import '../screens/ciber_puntuacio_screen.dart';
import '../screens/ciber_punts_screen.dart';
import '../screens/ciber_punt_contrasenyes_screen.dart';
import '../screens/ciber_punt_xarxes_screen.dart';
import '../screens/ciber_punt_dispositius_screen.dart';
import '../screens/ciber_punt_fraus_screen.dart';
import '../screens/ciber_punt_navegacio_screen.dart';
import '../screens/ciber_punt_compres_screen.dart';
import '../screens/ciber_punt_global_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/ciber-tauler/:diceResult',
        builder: (context, state) {
          final diceResult = int.tryParse(state.pathParameters['diceResult'] ?? '0') ?? 0;
          return CiberTaulerScreen(diceResult: diceResult);
        },
      ),
      GoRoute(
        path: '/ciber-dau',
        builder: (context, state) => const CiberDauScreen(),
      ),
      GoRoute(
        path: '/ciber-puntuacio/:playerIndex',
        builder: (context, state) {
          final playerIndex = int.tryParse(state.pathParameters['playerIndex'] ?? '0') ?? 0;
          return CiberPuntuacioScreen(playerIndex: playerIndex);
        },
      ),
      GoRoute(
        path: '/ciber-punts',
        builder: (context, state) => const CiberPuntsScreen(),
      ),
      GoRoute(
        path: '/ciber-punt/:category',
        builder: (context, state) {
          final category = state.pathParameters['category'];
          final isCheese = state.uri.queryParameters['isCheese'] == 'true';

          switch (category) {
            case 'Contrasenyes':
              return CiberPuntContrasenyesScreen(isCheeseSquare: isCheese);
            case 'XarxesSocials':
              return CiberPuntXarxesScreen(isCheeseSquare: isCheese);
            case 'CompresEnLinia':
              return CiberPuntCompresScreen(isCheeseSquare: isCheese);
            case 'ProteccioDispositius':
              return CiberPuntDispositiusScreen(isCheeseSquare: isCheese);
            case 'NavegacioSegura':
              return CiberPuntNavegacioScreen(isCheeseSquare: isCheese);
            case 'FrausEnLinia':
              return CiberPuntFrausScreen(isCheeseSquare: isCheese);
            case 'global':
              return const CiberPuntGlobalScreen();
            default:
              return const HomeScreen(); 
          }
        },
      ),
    ],
  );
}
