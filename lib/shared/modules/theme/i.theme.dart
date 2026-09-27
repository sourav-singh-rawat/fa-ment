import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class FaveAppTheme {
  static ThemeData light() {
    const colors = FaveColorTokens.light;
    final text = FaveTextTokens.create(colors);

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
        FaveLayoutTokens.standard,
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
extension FaveThemeContext on BuildContext {
  FaveColorTokens get faveColors =>
      Theme.of(this).extension<FaveColorTokens>()!;
  FaveLayoutTokens get faveLayout =>
      Theme.of(this).extension<FaveLayoutTokens>()!;
  FaveTextTokens get faveText => Theme.of(this).extension<FaveTextTokens>()!;
}

/// Colour tokens that do not map cleanly to Material's generic ColorScheme.
///
/// The app should use these semantic names rather than arbitrary hex values
/// inside individual widgets. This prevents visual drift between Pay,
/// Confirming, Success, Failed, history, and the two bottom sheets.
@immutable
class FaveColorTokens extends ThemeExtension<FaveColorTokens> {
  final Color screenBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;

  final Color recipientCard;
  final Color avatarAndWaitingRing;
  final Color countdownTrack;
  final Color countdownProgress;

  final Color primaryCta;
  final Color primaryCtaText;
  final Color invalidCta;
  final Color sendingCta;

  final Color failedBadge;
  final Color failedCross;
  final Color noticeBox;
  final Color link;

  final Color chipFill;
  final Color chipBorder;
  final Color sheetGrabber;
  final Color sheetScrim;

  final Color fieldUnderline;
  final Color focusedUnderline;
  final Color errorUnderline;
  final Color amountError;

  final Color recentBadgeBackground;
  final Color successNote;

  const FaveColorTokens({
    required this.screenBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.recipientCard,
    required this.avatarAndWaitingRing,
    required this.countdownTrack,
    required this.countdownProgress,
    required this.primaryCta,
    required this.primaryCtaText,
    required this.invalidCta,
    required this.sendingCta,
    required this.failedBadge,
    required this.failedCross,
    required this.noticeBox,
    required this.link,
    required this.chipFill,
    required this.chipBorder,
    required this.sheetGrabber,
    required this.sheetScrim,
    required this.fieldUnderline,
    required this.focusedUnderline,
    required this.errorUnderline,
    required this.amountError,
    required this.recentBadgeBackground,
    required this.successNote,
  });

  static const light = FaveColorTokens(
    screenBackground: Color(0xFFFFFBF6),
    primaryText: Color(0xFF232323),
    secondaryText: Color(0xFF7A7877),
    mutedText: Color(0xFFD3C8B8),
    recipientCard: Color(0xFFFFEDD9),
    avatarAndWaitingRing: Color(0xFFFFD9C2),
    countdownTrack: Color(0xFFFFEADF),
    countdownProgress: Color(0xFF0FBAB0),
    primaryCta: Color(0xFF0FBAB0),
    primaryCtaText: Color(0xFFFFFFFF),
    // The spec requires the primary teal at 40% opacity for invalid amount.
    invalidCta: Color(0x660FBAB0),
    // The spec requires the primary teal at 55% opacity while Sending.
    sendingCta: Color(0x8C0FBAB0),
    failedBadge: Color(0xFFFBEAE8),
    failedCross: Color(0xFFB8433C),
    noticeBox: Color(0xFFFFF3EE),
    link: Color(0xFF5E6DFF),
    chipFill: Color(0xFFF5EFE6),
    chipBorder: Color(0xFFD3C8B8),
    sheetGrabber: Color(0xFFD3C8B8),
    sheetScrim: Color(0x73231F30), // #231F30 at 45% alpha
    fieldUnderline: Color(0xFFE7DFD4),
    focusedUnderline: Color(0xFF5E6DFF),
    errorUnderline: Color(0xFFB8433C),
    amountError: Color(0xFFB8433C),
    recentBadgeBackground: Color(0xFFFFF3EE),
    successNote: Color(0xFF333333),
  );

  @override
  FaveColorTokens copyWith({
    Color? screenBackground,
    Color? primaryText,
    Color? secondaryText,
    Color? mutedText,
    Color? recipientCard,
    Color? avatarAndWaitingRing,
    Color? countdownTrack,
    Color? countdownProgress,
    Color? primaryCta,
    Color? primaryCtaText,
    Color? invalidCta,
    Color? sendingCta,
    Color? failedBadge,
    Color? failedCross,
    Color? noticeBox,
    Color? link,
    Color? chipFill,
    Color? chipBorder,
    Color? sheetGrabber,
    Color? sheetScrim,
    Color? fieldUnderline,
    Color? focusedUnderline,
    Color? errorUnderline,
    Color? amountError,
    Color? recentBadgeBackground,
    Color? successNote,
  }) {
    return FaveColorTokens(
      screenBackground: screenBackground ?? this.screenBackground,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      mutedText: mutedText ?? this.mutedText,
      recipientCard: recipientCard ?? this.recipientCard,
      avatarAndWaitingRing: avatarAndWaitingRing ?? this.avatarAndWaitingRing,
      countdownTrack: countdownTrack ?? this.countdownTrack,
      countdownProgress: countdownProgress ?? this.countdownProgress,
      primaryCta: primaryCta ?? this.primaryCta,
      primaryCtaText: primaryCtaText ?? this.primaryCtaText,
      invalidCta: invalidCta ?? this.invalidCta,
      sendingCta: sendingCta ?? this.sendingCta,
      failedBadge: failedBadge ?? this.failedBadge,
      failedCross: failedCross ?? this.failedCross,
      noticeBox: noticeBox ?? this.noticeBox,
      link: link ?? this.link,
      chipFill: chipFill ?? this.chipFill,
      chipBorder: chipBorder ?? this.chipBorder,
      sheetGrabber: sheetGrabber ?? this.sheetGrabber,
      sheetScrim: sheetScrim ?? this.sheetScrim,
      fieldUnderline: fieldUnderline ?? this.fieldUnderline,
      focusedUnderline: focusedUnderline ?? this.focusedUnderline,
      errorUnderline: errorUnderline ?? this.errorUnderline,
      amountError: amountError ?? this.amountError,
      recentBadgeBackground:
          recentBadgeBackground ?? this.recentBadgeBackground,
      successNote: successNote ?? this.successNote,
    );
  }

  @override
  FaveColorTokens lerp(FaveColorTokens? other, double t) {
    if (other is! FaveColorTokens) return this;
    return FaveColorTokens(
      screenBackground: Color.lerp(
        screenBackground,
        other.screenBackground,
        t,
      )!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      recipientCard: Color.lerp(recipientCard, other.recipientCard, t)!,
      avatarAndWaitingRing: Color.lerp(
        avatarAndWaitingRing,
        other.avatarAndWaitingRing,
        t,
      )!,
      countdownTrack: Color.lerp(countdownTrack, other.countdownTrack, t)!,
      countdownProgress: Color.lerp(
        countdownProgress,
        other.countdownProgress,
        t,
      )!,
      primaryCta: Color.lerp(primaryCta, other.primaryCta, t)!,
      primaryCtaText: Color.lerp(primaryCtaText, other.primaryCtaText, t)!,
      invalidCta: Color.lerp(invalidCta, other.invalidCta, t)!,
      sendingCta: Color.lerp(sendingCta, other.sendingCta, t)!,
      failedBadge: Color.lerp(failedBadge, other.failedBadge, t)!,
      failedCross: Color.lerp(failedCross, other.failedCross, t)!,
      noticeBox: Color.lerp(noticeBox, other.noticeBox, t)!,
      link: Color.lerp(link, other.link, t)!,
      chipFill: Color.lerp(chipFill, other.chipFill, t)!,
      chipBorder: Color.lerp(chipBorder, other.chipBorder, t)!,
      sheetGrabber: Color.lerp(sheetGrabber, other.sheetGrabber, t)!,
      sheetScrim: Color.lerp(sheetScrim, other.sheetScrim, t)!,
      fieldUnderline: Color.lerp(fieldUnderline, other.fieldUnderline, t)!,
      focusedUnderline: Color.lerp(
        focusedUnderline,
        other.focusedUnderline,
        t,
      )!,
      errorUnderline: Color.lerp(errorUnderline, other.errorUnderline, t)!,
      amountError: Color.lerp(amountError, other.amountError, t)!,
      recentBadgeBackground: Color.lerp(
        recentBadgeBackground,
        other.recentBadgeBackground,
        t,
      )!,
      successNote: Color.lerp(successNote, other.successNote, t)!,
    );
  }
}

/// Layout and geometry tokens from page 11.
///
/// These remain separate from ThemeData because Material does not have
/// semantic slots for a payment ring diameter, recipient-card padding, or
/// a backend-chip radius. Keeping them as a ThemeExtension means they are
/// still centralized, inherited, testable, and available from BuildContext.
@immutable
class FaveLayoutTokens extends ThemeExtension<FaveLayoutTokens> {
  final EdgeInsets screenPadding;
  final double payBlockGap;
  final double topBarGap;
  final double recipientCardRadius;
  final EdgeInsets recipientCardPadding;
  final double recipientAvatarSize;
  final double fieldLineWidth;
  final double recentListFirstRowGap;
  final EdgeInsets recentRowPadding;
  final double primaryCtaRadius;
  final EdgeInsets primaryCtaPadding;
  final double ringSize;
  final double ringStrokeWidth;
  final double badgeSize;
  final double sheetTopRadius;
  final EdgeInsets sheetPadding;
  final Size sheetGrabberSize;
  final double sheetGrabberRadius;
  final double noticeRadius;
  final EdgeInsets noticePadding;

  const FaveLayoutTokens({
    required this.screenPadding,
    required this.payBlockGap,
    required this.topBarGap,
    required this.recipientCardRadius,
    required this.recipientCardPadding,
    required this.recipientAvatarSize,
    required this.fieldLineWidth,
    required this.recentListFirstRowGap,
    required this.recentRowPadding,
    required this.primaryCtaRadius,
    required this.primaryCtaPadding,
    required this.ringSize,
    required this.ringStrokeWidth,
    required this.badgeSize,
    required this.sheetTopRadius,
    required this.sheetPadding,
    required this.sheetGrabberSize,
    required this.sheetGrabberRadius,
    required this.noticeRadius,
    required this.noticePadding,
  });

  static const standard = FaveLayoutTokens(
    screenPadding: EdgeInsets.only(top: 56, left: 32, right: 32, bottom: 32),
    payBlockGap: 24,
    topBarGap: 14,
    recipientCardRadius: 20,
    recipientCardPadding: EdgeInsets.all(18),
    recipientAvatarSize: 44,
    fieldLineWidth: 1,
    recentListFirstRowGap: 8,
    recentRowPadding: EdgeInsets.symmetric(vertical: 13),
    primaryCtaRadius: 100,
    primaryCtaPadding: EdgeInsets.symmetric(vertical: 17),
    ringSize: 120,
    ringStrokeWidth: 8,
    badgeSize: 88,
    sheetTopRadius: 24,
    sheetPadding: EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 32),
    sheetGrabberSize: Size(36, 4),
    sheetGrabberRadius: 2,
    noticeRadius: 14,
    noticePadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  );

  @override
  FaveLayoutTokens copyWith({
    EdgeInsets? screenPadding,
    double? payBlockGap,
    double? topBarGap,
    double? recipientCardRadius,
    EdgeInsets? recipientCardPadding,
    double? recipientAvatarSize,
    double? fieldLineWidth,
    double? recentListFirstRowGap,
    EdgeInsets? recentRowPadding,
    double? primaryCtaRadius,
    EdgeInsets? primaryCtaPadding,
    double? ringSize,
    double? ringStrokeWidth,
    double? badgeSize,
    double? sheetTopRadius,
    EdgeInsets? sheetPadding,
    Size? sheetGrabberSize,
    double? sheetGrabberRadius,
    double? noticeRadius,
    EdgeInsets? noticePadding,
  }) {
    return FaveLayoutTokens(
      screenPadding: screenPadding ?? this.screenPadding,
      payBlockGap: payBlockGap ?? this.payBlockGap,
      topBarGap: topBarGap ?? this.topBarGap,
      recipientCardRadius: recipientCardRadius ?? this.recipientCardRadius,
      recipientCardPadding: recipientCardPadding ?? this.recipientCardPadding,
      recipientAvatarSize: recipientAvatarSize ?? this.recipientAvatarSize,
      fieldLineWidth: fieldLineWidth ?? this.fieldLineWidth,
      recentListFirstRowGap:
          recentListFirstRowGap ?? this.recentListFirstRowGap,
      recentRowPadding: recentRowPadding ?? this.recentRowPadding,
      primaryCtaRadius: primaryCtaRadius ?? this.primaryCtaRadius,
      primaryCtaPadding: primaryCtaPadding ?? this.primaryCtaPadding,
      ringSize: ringSize ?? this.ringSize,
      ringStrokeWidth: ringStrokeWidth ?? this.ringStrokeWidth,
      badgeSize: badgeSize ?? this.badgeSize,
      sheetTopRadius: sheetTopRadius ?? this.sheetTopRadius,
      sheetPadding: sheetPadding ?? this.sheetPadding,
      sheetGrabberSize: sheetGrabberSize ?? this.sheetGrabberSize,
      sheetGrabberRadius: sheetGrabberRadius ?? this.sheetGrabberRadius,
      noticeRadius: noticeRadius ?? this.noticeRadius,
      noticePadding: noticePadding ?? this.noticePadding,
    );
  }

  @override
  FaveLayoutTokens lerp(FaveLayoutTokens? other, double t) {
    if (other is! FaveLayoutTokens) return this;
    return FaveLayoutTokens(
      screenPadding: EdgeInsets.lerp(screenPadding, other.screenPadding, t)!,
      payBlockGap: _lerpDouble(payBlockGap, other.payBlockGap, t),
      topBarGap: _lerpDouble(topBarGap, other.topBarGap, t),
      recipientCardRadius: _lerpDouble(
        recipientCardRadius,
        other.recipientCardRadius,
        t,
      ),
      recipientCardPadding: EdgeInsets.lerp(
        recipientCardPadding,
        other.recipientCardPadding,
        t,
      )!,
      recipientAvatarSize: _lerpDouble(
        recipientAvatarSize,
        other.recipientAvatarSize,
        t,
      ),
      fieldLineWidth: _lerpDouble(fieldLineWidth, other.fieldLineWidth, t),
      recentListFirstRowGap: _lerpDouble(
        recentListFirstRowGap,
        other.recentListFirstRowGap,
        t,
      ),
      recentRowPadding: EdgeInsets.lerp(
        recentRowPadding,
        other.recentRowPadding,
        t,
      )!,
      primaryCtaRadius: _lerpDouble(
        primaryCtaRadius,
        other.primaryCtaRadius,
        t,
      ),
      primaryCtaPadding: EdgeInsets.lerp(
        primaryCtaPadding,
        other.primaryCtaPadding,
        t,
      )!,
      ringSize: _lerpDouble(ringSize, other.ringSize, t),
      ringStrokeWidth: _lerpDouble(ringStrokeWidth, other.ringStrokeWidth, t),
      badgeSize: _lerpDouble(badgeSize, other.badgeSize, t),
      sheetTopRadius: _lerpDouble(sheetTopRadius, other.sheetTopRadius, t),
      sheetPadding: EdgeInsets.lerp(sheetPadding, other.sheetPadding, t)!,
      sheetGrabberSize: Size.lerp(sheetGrabberSize, other.sheetGrabberSize, t)!,
      sheetGrabberRadius: _lerpDouble(
        sheetGrabberRadius,
        other.sheetGrabberRadius,
        t,
      ),
      noticeRadius: _lerpDouble(noticeRadius, other.noticeRadius, t),
      noticePadding: EdgeInsets.lerp(noticePadding, other.noticePadding, t)!,
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Semantic typography tokens. TextTheme gives common Material roles a
/// sensible default; these named styles cover the Figma-specific roles that
/// Material has no stable equivalent for (ring seconds, amount field,
/// history badge, etc.).
@immutable
class FaveTextTokens extends ThemeExtension<FaveTextTokens> {
  final TextStyle amountField;
  final TextStyle amountError;
  final TextStyle sectionLabel;
  final TextStyle recipientName;
  final TextStyle noteField;
  final TextStyle successNote;
  final TextStyle recentPayee;
  final TextStyle recentStatus;
  final TextStyle recentAmount;
  final TextStyle recentBadge;
  final TextStyle chipLabel;
  final TextStyle ringSeconds;
  final TextStyle confirmingHeading;
  final TextStyle successHeading;
  final TextStyle statusHeading;
  final TextStyle ctaLabel;
  final TextStyle checkingLink;

  const FaveTextTokens({
    required this.amountField,
    required this.amountError,
    required this.sectionLabel,
    required this.recipientName,
    required this.noteField,
    required this.successNote,
    required this.recentPayee,
    required this.recentStatus,
    required this.recentAmount,
    required this.recentBadge,
    required this.chipLabel,
    required this.ringSeconds,
    required this.confirmingHeading,
    required this.successHeading,
    required this.statusHeading,
    required this.ctaLabel,
    required this.checkingLink,
  });

  static FaveTextTokens create(FaveColorTokens colors) {
    TextStyle style({
      required double fontSize,
      required double lineHeight,
      FontWeight? weight,
      double? letterSpacing,
      Color? color,
    }) {
      return GoogleFonts.onest(
        fontSize: fontSize,
        height: lineHeight / fontSize,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: color ?? colors.primaryText,
      );
    }

    return FaveTextTokens(
      amountField: style(
        fontSize: 40,
        lineHeight: 46,
        weight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      amountError: style(
        fontSize: 12.5,
        lineHeight: 17,
        weight: FontWeight.w500,
        color: colors.amountError,
      ),
      sectionLabel: style(
        fontSize: 11,
        lineHeight: 14,
        weight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
      recipientName: style(
        fontSize: 15,
        lineHeight: 20,
        weight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      noteField: style(fontSize: 13, lineHeight: 18, weight: FontWeight.w500),
      successNote: style(
        fontSize: 13,
        lineHeight: 18,
        weight: FontWeight.w400,
        color: colors.successNote,
      ),
      recentPayee: style(
        fontSize: 14,
        lineHeight: 18,
        weight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      recentStatus: style(
        fontSize: 12,
        lineHeight: 16,
        weight: FontWeight.w400,
        color: colors.secondaryText,
      ),
      recentAmount: style(
        fontSize: 15,
        lineHeight: 20,
        weight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      recentBadge: style(
        fontSize: 9.5,
        lineHeight: 12,
        weight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
      chipLabel: style(fontSize: 12, lineHeight: 16, weight: FontWeight.w500),
      ringSeconds: style(
        fontSize: 30,
        lineHeight: 36,
        weight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      confirmingHeading: style(
        fontSize: 19,
        lineHeight: 24,
        weight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      successHeading: style(
        fontSize: 28,
        lineHeight: 34,
        weight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      statusHeading: style(
        fontSize: 24,
        lineHeight: 30,
        weight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      ctaLabel: style(
        fontSize: 15,
        lineHeight: 20,
        weight: FontWeight.w700,
        color: colors.primaryCtaText,
      ),
      checkingLink: style(
        fontSize: 14,
        lineHeight: 18,
        weight: FontWeight.w500,
        color: colors.secondaryText,
      ),
    );
  }

  @override
  FaveTextTokens copyWith({
    TextStyle? amountField,
    TextStyle? amountError,
    TextStyle? sectionLabel,
    TextStyle? recipientName,
    TextStyle? noteField,
    TextStyle? successNote,
    TextStyle? recentPayee,
    TextStyle? recentStatus,
    TextStyle? recentAmount,
    TextStyle? recentBadge,
    TextStyle? chipLabel,
    TextStyle? ringSeconds,
    TextStyle? confirmingHeading,
    TextStyle? successHeading,
    TextStyle? statusHeading,
    TextStyle? ctaLabel,
    TextStyle? checkingLink,
  }) {
    return FaveTextTokens(
      amountField: amountField ?? this.amountField,
      amountError: amountError ?? this.amountError,
      sectionLabel: sectionLabel ?? this.sectionLabel,
      recipientName: recipientName ?? this.recipientName,
      noteField: noteField ?? this.noteField,
      successNote: successNote ?? this.successNote,
      recentPayee: recentPayee ?? this.recentPayee,
      recentStatus: recentStatus ?? this.recentStatus,
      recentAmount: recentAmount ?? this.recentAmount,
      recentBadge: recentBadge ?? this.recentBadge,
      chipLabel: chipLabel ?? this.chipLabel,
      ringSeconds: ringSeconds ?? this.ringSeconds,
      confirmingHeading: confirmingHeading ?? this.confirmingHeading,
      successHeading: successHeading ?? this.successHeading,
      statusHeading: statusHeading ?? this.statusHeading,
      ctaLabel: ctaLabel ?? this.ctaLabel,
      checkingLink: checkingLink ?? this.checkingLink,
    );
  }

  @override
  FaveTextTokens lerp(FaveTextTokens? other, double t) {
    if (other is! FaveTextTokens) return this;
    return FaveTextTokens(
      amountField: TextStyle.lerp(amountField, other.amountField, t)!,
      amountError: TextStyle.lerp(amountError, other.amountError, t)!,
      sectionLabel: TextStyle.lerp(sectionLabel, other.sectionLabel, t)!,
      recipientName: TextStyle.lerp(recipientName, other.recipientName, t)!,
      noteField: TextStyle.lerp(noteField, other.noteField, t)!,
      successNote: TextStyle.lerp(successNote, other.successNote, t)!,
      recentPayee: TextStyle.lerp(recentPayee, other.recentPayee, t)!,
      recentStatus: TextStyle.lerp(recentStatus, other.recentStatus, t)!,
      recentAmount: TextStyle.lerp(recentAmount, other.recentAmount, t)!,
      recentBadge: TextStyle.lerp(recentBadge, other.recentBadge, t)!,
      chipLabel: TextStyle.lerp(chipLabel, other.chipLabel, t)!,
      ringSeconds: TextStyle.lerp(ringSeconds, other.ringSeconds, t)!,
      confirmingHeading: TextStyle.lerp(
        confirmingHeading,
        other.confirmingHeading,
        t,
      )!,
      successHeading: TextStyle.lerp(successHeading, other.successHeading, t)!,
      statusHeading: TextStyle.lerp(statusHeading, other.statusHeading, t)!,
      ctaLabel: TextStyle.lerp(ctaLabel, other.ctaLabel, t)!,
      checkingLink: TextStyle.lerp(checkingLink, other.checkingLink, t)!,
    );
  }
}
