import 'package:flutter/material.dart';

// ============================================================
// COLORES PRINCIPALES
// ============================================================

const Color verdePrincipal = Color(0xFF18B870);
const Color verdeOscuro = Color(0xFF087A4A);
const Color verdeClaro = Color(0xFFE9F8F1);

const Color rosaPrincipal = Color(0xFFF05CB5);
const Color rosaClaro = Color(0xFFFFE9F6);

const Color amarilloPrincipal = Color(0xFFFFD56A);

const Color fondoPrincipal = Color(0xFFF8FAF9);
const Color textoPrincipal = Color(0xFF252A28);
const Color textoSecundario = Color(0xFF777D7A);

// ============================================================
// TEMA DE LA APLICACION
// ============================================================

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: fondoPrincipal,
  colorScheme: ColorScheme.fromSeed(seedColor: verdePrincipal),
);
