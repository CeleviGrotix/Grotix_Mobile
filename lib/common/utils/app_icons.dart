// lib/common/utils/app_icons.dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/widgets.dart';

class AppIcons {
  // --- Barra de Navegación Inferior (MainShell) ---
  static const IconData dashboard = FontAwesomeIcons.chartBar;         // outline
  static const IconData aiProcessing = FontAwesomeIcons.asterisk;     // más "IA" que una varita
  static const IconData zones = FontAwesomeIcons.seedling;             // no tiene outline
  static const IconData reports = FontAwesomeIcons.fileLines;          // ya es outline
  static const IconData profile = FontAwesomeIcons.user;

  // --- Barra de Aplicación & Alertas ---
  static const IconData notifications = FontAwesomeIcons.bell;         // outline
  static const IconData settings = FontAwesomeIcons.gear;              // no tiene outline
  static const IconData search = FontAwesomeIcons.magnifyingGlass;     // no tiene outline

  // --- Monitoreo de Campo & Métricas de Sensores ---
  static const IconData moisture = FontAwesomeIcons.droplet;           // no tiene outline
  static const IconData radiation = FontAwesomeIcons.sun;              // outline
  static const IconData temperature = FontAwesomeIcons.temperatureHalf;
  static const IconData sensorAlert = FontAwesomeIcons.triangleExclamation;
  static const IconData checkActive = FontAwesomeIcons.circleCheck;    // outline

  // --- Acciones del Sistema ---
  static const IconData add = FontAwesomeIcons.circlePlus;
  static const IconData filter = FontAwesomeIcons.sliders;
  static const IconData refresh = FontAwesomeIcons.rotateRight;
  static const IconData invite = FontAwesomeIcons.userPlus;
  static const IconData remove = FontAwesomeIcons.userMinus;
  static const IconData logout = FontAwesomeIcons.rightFromBracket;
  static const IconData edit = FontAwesomeIcons.penToSquare;           // outline
  static const IconData delete = FontAwesomeIcons.trash;               // outline
}