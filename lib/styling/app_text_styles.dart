import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

class AppTextStyles {
  static const TextStyle primaryHeadlineStyle = TextStyle(
    color: AppColors.primaryColor,
    fontFamily: AppFonts.mainFontName,
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitlesStyle = TextStyle(
    color: AppColors.secondaryColor,
    fontFamily: AppFonts.mainFontName,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle cardPrimaryTextStyle = TextStyle(
    color: AppColors.whiteColor,
    fontFamily: AppFonts.mainFontName,
    fontSize: 30,
    fontWeight: FontWeight.w600,
  );

  static TextStyle cardSubtitlesStyle = TextStyle(
    color: AppColors.whiteColor.withAlpha(200),
    fontFamily: AppFonts.mainFontName,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle whiteTextStyle = TextStyle(
    color: AppColors.whiteColor,
    fontFamily: AppFonts.mainFontName,
    fontSize: 22,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle blackTextStyle = TextStyle(
    color: AppColors.blackColor,
    fontFamily: AppFonts.mainFontName,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  // for themes
  static const TextStyle whiteTitleMediumTextStyle = TextStyle(
    color: AppColors.whiteColor,
    fontFamily: AppFonts.mainFontName,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle blackTitleMediumTextStyle = TextStyle(
    color: AppColors.blackColor,
    fontFamily: AppFonts.mainFontName,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}
