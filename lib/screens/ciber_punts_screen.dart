import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_nav_bar.dart';

class CiberPuntsScreen extends StatelessWidget {
  const CiberPuntsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tria una categoria'),
        backgroundColor: Colors.grey[200], // Color de fons gris clar
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCategoryCard(context, 'Gestió de Contrasenyes', 'assets/images/osi-trivial-ciberpunt-gestio-de-contrasenyes.jpg', '/ciber-punt/Contrasenyes'),
                  _buildCategoryCard(context, 'Compres en Línia', 'assets/images/osi-trivial-ciberpunt-compres-en-linia.jpg', '/ciber-punt/CompresEnLinia'),
                  _buildCategoryCard(context, 'Xarxes Socials i Missatgeria', 'assets/images/osi-trivial-ciberpunt-xarxes-socials-i-missatgeria-instantania.jpg', '/ciber-punt/XarxesSocials'),
                  _buildCategoryCard(context, 'Protecció de Dispositius', 'assets/images/osi-trivial-ciberpunt-proteccio-de-dispositius.jpg', '/ciber-punt/ProteccioDispositius'),
                  _buildCategoryCard(context, 'Navegació Segura', 'assets/images/osi-trivial-ciberpunt-navegacio-segura.jpg', '/ciber-punt/NavegacioSegura'),
                  _buildCategoryCard(context, 'Fraus en Línia', 'assets/images/osi-trivial-ciberpunt-fraus-en-linia.jpg', '/ciber-punt/FrausEnLinia'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/ciber-punt/global'),
              child: const Text('Pregunta Global'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String imagePath, String route) {
    return InkWell(
      onTap: () => context.go(route),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
