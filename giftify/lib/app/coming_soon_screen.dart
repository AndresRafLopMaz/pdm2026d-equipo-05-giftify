import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Pantalla temporal para accesos que todavía no tienen implementación.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Próximamente'),
        backgroundColor: fondoPrincipal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: verdeClaro,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.hourglass_empty_rounded,
                  color: verdePrincipal,
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Próximamente',
                style: TextStyle(
                  color: textoPrincipal,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Estamos trabajando en esta sección de Giftify.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textoSecundario,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
