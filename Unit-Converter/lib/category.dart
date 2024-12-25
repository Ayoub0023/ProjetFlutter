import 'package:flutter/material.dart';
import 'package:unit_converter/unit.dart';

class Category {
  final String? iconLocation; // Allow null with `?`
  final String? name; // Allow null with `?`
  final ColorSwatch color;
  final List<Unit>? units; // Allow null with `?`

  const Category({
    this.iconLocation,
    this.name,
    required this.color, // Mark as required to ensure it isn’t null
    this.units,
  });
}
