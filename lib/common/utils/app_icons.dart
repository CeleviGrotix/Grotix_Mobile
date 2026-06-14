// lib/common/utils/app_icons.dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/widgets.dart';

class AppIcons {
  // --- Barra de Navegación Inferior (MainShell) ---
  static const FaIconData dashboard = FontAwesomeIcons.chartBar;         // outline
  static const FaIconData aiProcessing = FontAwesomeIcons.asterisk;     // más "IA" que una varita
  static const FaIconData zones = FontAwesomeIcons.seedling;             // no tiene outline
  static const FaIconData reports = FontAwesomeIcons.fileLines;          // ya es outline
  static const FaIconData profile = FontAwesomeIcons.user;

  // --- Barra de Aplicación & Alertas ---
  static const FaIconData notifications = FontAwesomeIcons.bell;         // outline
  static const FaIconData settings = FontAwesomeIcons.gear;              // no tiene outline
  static const FaIconData search = FontAwesomeIcons.magnifyingGlass;     // no tiene outline

  // --- Monitoreo de Campo & Métricas de Sensores ---
  static const FaIconData moisture = FontAwesomeIcons.droplet;           // no tiene outline
  static const FaIconData radiation = FontAwesomeIcons.sun;              // outline
  static const FaIconData temperature = FontAwesomeIcons.temperatureHalf;
  static const FaIconData sensorAlert = FontAwesomeIcons.triangleExclamation;
  static const FaIconData checkActive = FontAwesomeIcons.circleCheck;    // outline

  // --- Acciones del Sistema ---
  static const FaIconData add = FontAwesomeIcons.circlePlus;
  static const FaIconData filter = FontAwesomeIcons.sliders;
  static const FaIconData refresh = FontAwesomeIcons.rotateRight;
  static const FaIconData invite = FontAwesomeIcons.userPlus;
  static const FaIconData remove = FontAwesomeIcons.userMinus;
  static const FaIconData logout = FontAwesomeIcons.rightFromBracket;
  static const FaIconData edit = FontAwesomeIcons.penToSquare;           // outline
  static const FaIconData delete = FontAwesomeIcons.trash;               // outline
}