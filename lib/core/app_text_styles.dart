import 'package:flutter/material.dart';

class AppTextSizes {
  const AppTextSizes._();

  static const double title = 20;
  static const double body = 16;
}

class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle appBarTitle = TextStyle(
    color: Colors.white,
    fontSize: AppTextSizes.title,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle tileTitle = TextStyle(
    fontSize: AppTextSizes.body,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: AppTextSizes.body,
    fontWeight: FontWeight.w700,
  );
}
