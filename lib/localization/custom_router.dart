import 'package:flutter/material.dart';
import 'package:quizard/main.dart';

const String welcomePageRoute = "welcome";
const String loadHomePageRoute = "load page";
class CustomRouter {
  static Route<dynamic> generatedRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcomePageRoute:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case loadHomePageRoute:
        return MaterialPageRoute(builder: (_) => const LoadHomePage());
      default:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
    }
  }
}
