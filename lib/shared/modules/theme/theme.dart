import 'package:fave/shared/modules/theme/i.theme.dart'
    show FColorTokens, FTextTokens, FLayoutTokens;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//TODO: write better contract for AppTheme
//TODO: write separate contract for colors, typography, adaptive-layout
abstract final class FAppTheme {
  static ThemeData light() {
    const colors = FColorTokens.light;
    final text = FTextTokens.create(colors);

    final baseTextTheme = GoogleFonts.onestTextTheme();
    final textTheme = baseTextTheme.copyWith(
      titleMedium: GoogleFonts.onest(
        fontSize: 17,
        height: 22 / 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: colors.primaryText,
      ),
      bodyMedium: GoogleFonts.onest(
        fontSize: 13,
        height: 19 / 13,
        fontWeight: FontWeight.w400,
        color: colors.primaryText,
      ),
      bodySmall: GoogleFonts.onest(
        fontSize: 12.5,
        height: 17 / 12.5,
        fontWeight: FontWeight.w400,
        color: colors.secondaryText,
      ),
      labelLarge: text.ctaLabel,
      labelMedium: text.chipLabel,
    );

    final colorScheme = ColorScheme.light(
      primary: colors.primaryCta,
      onPrimary: colors.primaryCtaText,
      secondary: colors.link,
      onSecondary: Colors.white,
      surface: colors.screenBackground,
      onSurface: colors.primaryText,
      error: colors.amountError,
      onError: Colors.white,
      outline: colors.chipBorder,
      outlineVariant: colors.fieldUnderline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.screenBackground,
      fontFamily: GoogleFonts.onest().fontFamily,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[
        colors,
        FLayoutTokens.standard,
        text,
      ],
      dividerTheme: DividerThemeData(
        color: colors.fieldUnderline,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        hintStyle: text.noteField.copyWith(color: colors.mutedText),
        errorStyle: text.amountError,
        contentPadding: EdgeInsets.zero,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE7DFD4), width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF5E6DFF), width: 1),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB8433C), width: 1),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB8433C), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(54)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 17, horizontal: 24),
          ),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          textStyle: WidgetStatePropertyAll(text.ctaLabel),
          foregroundColor: const WidgetStatePropertyAll(Color(0xFFFFFFFF)),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colors.invalidCta;
            }
            return colors.primaryCta;
          }),
          elevation: const WidgetStatePropertyAll(0),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.screenBackground,
        modalBackgroundColor: colors.screenBackground,
        modalBarrierColor: colors.sheetScrim,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: colors.sheetGrabber,
        dragHandleSize: const Size(36, 4),
        showDragHandle: true,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.chipFill,
        disabledColor: colors.chipFill,
        selectedColor: colors.chipFill,
        side: BorderSide(color: colors.chipBorder, width: 1),
        shape: const StadiumBorder(),
        labelStyle: text.chipLabel,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.link;
          return colors.chipBorder;
        }),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.screenBackground,
        foregroundColor: colors.primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleMedium,
      ),
    );
  }
}

/// Convenience accessors that keep widget code short and avoid repeated
/// `Theme.of(context).extension<T>()!` boilerplate.
extension FThemeContext on BuildContext {
  FColorTokens get colors => Theme.of(this).extension<FColorTokens>()!;
  FLayoutTokens get layout => Theme.of(this).extension<FLayoutTokens>()!;
  FTextTokens get text => Theme.of(this).extension<FTextTokens>()!;
}
