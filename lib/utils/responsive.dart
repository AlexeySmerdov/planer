import 'package:flutter/material.dart';

class Responsive {
  // Breakpoints
  static const double mobileMaxWidth = 768;
  static const double tabletMaxWidth = 1024;
  static const double desktopMinWidth = 1025;

  // Check if current screen is mobile
  static bool isMobile(BuildContext context) => 
      MediaQuery.of(context).size.width < mobileMaxWidth;

  // Check if current screen is tablet
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= mobileMaxWidth &&
      MediaQuery.of(context).size.width < desktopMinWidth;

  // Check if current screen is desktop
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width >= desktopMinWidth;

  // Get appropriate value based on screen size
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  // Get max content width for desktop layout
  static double getContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1400; // Max width for desktop content
    } else if (isTablet(context)) {
      return 800;  // Max width for tablet content
    } else {
      return MediaQuery.of(context).size.width; // Full width for mobile
    }
  }

  // Get sidebar width
  static double getSidebarWidth(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 0,
      tablet: 0,
      desktop: 300,
    );
  }

  // Get app padding
  static EdgeInsetsGeometry getAppPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: responsiveValue(
        context,
        mobile: 8.0,
        tablet: 16.0,
        desktop: 24.0,
      ),
      vertical: responsiveValue(
        context,
        mobile: 8.0,
        tablet: 12.0,
        desktop: 16.0,
      ),
    );
  }

  // Get card margin
  static EdgeInsetsGeometry getCardMargin(BuildContext context) {
    return EdgeInsets.all(
      responsiveValue(
        context,
        mobile: 8.0,
        tablet: 12.0,
        desktop: 16.0,
      ),
    );
  }

  // Get grid columns count
  static int getGridColumns(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );
  }
} 