import 'package:flutter/material.dart';

class Responsive {
  static bool isWide(BuildContext context) => MediaQuery.of(context).size.width > 700;
  static int gridColumns(BuildContext context) => isWide(context) ? 4 : 2;
}