import 'package:flutter/material.dart';

class AppTheme {
  // Cores principais - Happy Hues #6
  static const Color primaryColor = Color(0xFF6246EA); // Roxo principal
  static const Color secondaryColor = Color(0xFFD1D1E9); // Lavanda claro
  static const Color accentColor = Color(0xFFE45858); // Vermelho claro
  
  // Cores de texto
  static const Color textPrimary = Color(0xFF2B2C34); // Azul escuro/grafite
  static const Color textSecondary = Color(0xFF5F5F6E); // Cinza azulado
  static const Color textLight = Color(0xFFFFFFFF); // Branco puro
  
  // Cores de fundo
  static const Color backgroundLight = Color(0xFFFFFEFF); // Branco levemente acinzentado
  static const Color surfaceLight = Color(0xFFFFFFFF); // Branco puro
  
  // Cores de fundo modo escuro - Happy Hues #4
  static const Color backgroundDark = Color(0xFF16161A); // Preto azulado
  static const Color surfaceDark = Color(0xFF242629); // Cinza azulado mais claro
  
  // Cores de feedback
  static const Color successColor = Color(0xFF4CAF50); // Verde
  static const Color errorColor = Color(0xFFE53935); // Vermelho
  static const Color warningColor = Color(0xFFFFA000); // Âmbar
  static const Color infoColor = Color(0xFF2196F3); // Azul
  
  // Gradientes
  static LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Tema claro - Happy Hues #6
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor, // #6246EA
      primaryContainer: const Color(0xFF4D3AB8), // Tom mais escuro para elementos de destaque
      secondary: secondaryColor, // #D1D1E9
      secondaryContainer: const Color(0xFFB8B8D9), // Tom mais escuro para elementos secundários
      surface: surfaceLight, // #FFFFFF
      surfaceContainerHighest: backgroundLight, // #FFFFFE
      error: const Color(0xFFE45858), // Vermelho da paleta
      onPrimary: textLight, // #FFFFFF
      onSecondary: textPrimary, // #2B2C34
      onSurface: textPrimary, // #2B2C34
      onSurfaceVariant: textPrimary, // #2B2C34 - Substitui onBackground
      onError: textLight, // #FFFFFF
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor, // #6246EA
      foregroundColor: textLight, // #FFFFFF
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      color: surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      labelStyle: TextStyle(color: textPrimary.withOpacity(0.7)),
      hintStyle: TextStyle(color: textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: secondaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: secondaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor, // #6246EA
        foregroundColor: textLight, // #FFFFFF
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor, // #6246EA
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor, // #6246EA
        side: BorderSide(color: primaryColor), // #6246EA
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: textPrimary),
      displayMedium: TextStyle(color: textPrimary),
      displaySmall: TextStyle(color: textPrimary),
      headlineMedium: TextStyle(color: textPrimary),
      headlineSmall: TextStyle(color: textPrimary),
      titleLarge: TextStyle(color: textPrimary),
      titleMedium: TextStyle(color: textPrimary),
      titleSmall: TextStyle(color: textSecondary),
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textPrimary),
      bodySmall: TextStyle(color: textSecondary),
      labelLarge: TextStyle(color: textPrimary),
      labelMedium: TextStyle(color: textSecondary),
      labelSmall: TextStyle(color: textSecondary),
    ),
    iconTheme: IconThemeData(
      color: primaryColor, // #6246EA
    ),
    dividerColor: secondaryColor, // #D1D1E9
    cardColor: surfaceLight, // #FFFFFF
    dialogTheme: DialogTheme(
      backgroundColor: surfaceLight, // #FFFFFF
    )
  );
  
  // Tema escuro baseado na paleta Happy Hues #4
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF7f5af0), // Roxo dos botões
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF7f5af0), // Roxo
      primaryContainer: const Color(0xFF2cb67d), // Verde água para destaque
      secondary: const Color(0xFF2cb67d), // Verde água
      surface: const Color(0xFF242629), // Superfície mais clara
      surfaceContainerHighest: const Color(0xFF16161a), // Fundo principal
      error: const Color(0xFFef4565), // Vermelho para erros
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: const Color(0xFFfffffe), // Texto principal
      onSurfaceVariant: const Color(0xFFfffffe), // Texto principal - substitui onBackground
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF16161a), // Fundo principal
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF16161a), // Mesmo que o fundo
      foregroundColor: Color(0xFFfffffe), // Texto branco
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFFfffffe),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      color: const Color(0xFF242629), // Superfície de cartão
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF72757e)), // Cinza secundário
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF72757e)), // Cinza secundário
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF7f5af0), width: 2), // Roxo
      ),
      filled: true,
      fillColor: const Color(0xFF242629), // Cor de fundo do input
      hintStyle: const TextStyle(color: Color(0xFF94a1b2)), // Texto secundário
      labelStyle: const TextStyle(color: Color(0xFF94a1b2)), // Texto secundário
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7f5af0), // Roxo
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF7f5af0), // Roxo
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF7f5af0), // Roxo
        side: const BorderSide(color: Color(0xFF7f5af0)), // Roxo
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFFfffffe)),
      displayMedium: TextStyle(color: Color(0xFFfffffe)),
      displaySmall: TextStyle(color: Color(0xFFfffffe)),
      headlineMedium: TextStyle(color: Color(0xFFfffffe)),
      headlineSmall: TextStyle(color: Color(0xFFfffffe)),
      titleLarge: TextStyle(color: Color(0xFFfffffe)),
      titleMedium: TextStyle(color: Color(0xFFfffffe)),
      titleSmall: TextStyle(color: Color(0xFF94a1b2)),
      bodyLarge: TextStyle(color: Color(0xFFfffffe)),
      bodyMedium: TextStyle(color: Color(0xFF94a1b2)),
      bodySmall: TextStyle(color: Color(0xFF94a1b2)),
      labelLarge: TextStyle(color: Color(0xFFfffffe)),
      labelMedium: TextStyle(color: Color(0xFF94a1b2)),
      labelSmall: TextStyle(color: Color(0xFF94a1b2)),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF7f5af0), // Roxo para ícones
    ),
    dividerColor: const Color(0xFF2e2e32), // Divisórias escuras
    cardColor: const Color(0xFF242629), // Cor de fundo dos cards
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFF242629), // Cor de fundo dos diálogos
    )
  );
  
  // Estilos de texto
  static TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary, // #2B2C34
    letterSpacing: -0.5,
  );
  
  static TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary, // #2B2C34
    letterSpacing: -0.3,
  );

  static TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary, // #2B2C34
  );
  
  static TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textSecondary, // #5F5F6E
    height: 1.5,
  );
  
  static TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textLight, // #FFFFFF
    letterSpacing: 0.5,
  );
  
  // Estilos de texto para tema escuro
  static TextStyle darkHeadline1 = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: -0.5,
  );
  
  static TextStyle darkHeadline2 = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: -0.3,
  );
  
  static TextStyle darkSubtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.white.withOpacity(0.8),
    height: 1.5,
  );
  
  // Sombras
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF2B2C34).withOpacity(0.05),
      blurRadius: 10,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Bordas arredondadas
  static BorderRadius borderRadius = BorderRadius.circular(12);
  static BorderRadius borderRadiusSmall = BorderRadius.circular(8);
  static BorderRadius borderRadiusLarge = BorderRadius.circular(16);
  
  // Espaçamentos
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
}
