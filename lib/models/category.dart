import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final int iconCodePoint;
  final String? iconFontFamily;
  final int colorValue;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    this.iconFontFamily,
    required this.colorValue,
    this.createdAt,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: iconFontFamily);
  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'colorValue': colorValue,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconCodePoint: json['iconCodePoint'] ?? Icons.category.codePoint,
      iconFontFamily: json['iconFontFamily'] ?? Icons.category.fontFamily,
      colorValue: json['colorValue'] ?? Colors.grey.value,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Category copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    String? iconFontFamily,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, iconCodePoint: $iconCodePoint, colorValue: $colorValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}