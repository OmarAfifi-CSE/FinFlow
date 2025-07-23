import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

class AppTextStyles {
  static TextStyle primaryHeadlineStyle = TextStyle(
    color: AppColors.primaryColor,
    fontFamily: AppFonts.mainFontName,
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  static TextStyle subtitlesStyle = TextStyle(
    color: AppColors.secondaryColor,
    fontFamily: AppFonts.mainFontName,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle whiteTextStyle = TextStyle(
    color: AppColors.whiteColor,
    fontFamily: AppFonts.mainFontName,
    fontSize: 22,
    fontWeight: FontWeight.w500,
  );
}
