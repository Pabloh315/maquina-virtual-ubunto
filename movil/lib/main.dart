import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/autocare_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF102C55),
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AutoCareApp());
}
