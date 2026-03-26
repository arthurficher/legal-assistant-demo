import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/api/themes/my_theme.dart';
import 'package:flutter_gemini/helpers/dependency_injection.dart';
import 'package:flutter_gemini/providers/chat_provider.dart';
import 'package:flutter_gemini/providers/dart_provider.dart';
import 'package:flutter_gemini/screens/home_screen.dart';
import 'package:flutter_gemini/screens/login.dart';
import 'package:flutter_gemini/screens/register.dart';
import 'package:flutter_gemini/screens/registrer_home.dart';
import 'package:flutter_gemini/screens/screen_start.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await ChatProvider.initHive();
  DependencyInjection.initialized();
  runApp(MultiProvider(
     providers: [
      ChangeNotifierProvider(create: (context) => ChatProvider()),
      ChangeNotifierProvider(create: (context) => SettingsProvider()),
    ],
    child: const MyApp(),
    ));
    
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    setTheme();
    super.initState();
  }

  void setTheme(){
    final settingsProvider = context.read<SettingsProvider>();
    settingsProvider.getSavedSettings();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    return MaterialApp(
      title: 'Legal Assistant',
      theme: context.watch<SettingsProvider>().isDarkMode
              ? darkTheme
              : lighTheme,
      debugShowCheckedModeBanner: false,
      home: ScreenStart(),
      routes: {
        Register.routname: (_)=>Register(),
        Login.routeName: (_)=>Login(),
        HomeScreen.routeName: (_)=>HomeScreen(),
      },
    );
  }
}




