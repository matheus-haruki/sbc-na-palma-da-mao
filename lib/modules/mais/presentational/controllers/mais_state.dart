import 'package:flutter/material.dart';

sealed class MaisState {}

class MaisInitial extends MaisState {}

class MaisLoading extends MaisState {}

class MaisSuccess extends MaisState {
  final ThemeMode themeMode;

  MaisSuccess({required this.themeMode});
}
