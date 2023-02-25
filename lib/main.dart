import 'package:alert_web/page/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'page/login_screen.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

ColorScheme defaultColorScheme = const ColorScheme(
  primary: Color(0xffBB86FC),
  secondary: Color(0xff03DAC6),
  surface: Color(0xff181818),
  background: Color(0xff121212),
  error: Color(0xffCF6679),
  onPrimary: Color(0xff000000),
  onSecondary: Color(0xff000000),
  onSurface: Color(0xffffffff),
  onBackground: Color(0xffffffff),
  onError: Color(0xff000000),
  brightness: Brightness.dark,
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    return MaterialApp(
        title: 'Emergency Accident Alert',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: defaultColorScheme,
          primarySwatch: Colors.blue,
        ),
        home: ((box.read('email') != '' || box.read('email') != null)
            ? const LoginPage(title: 'Login UI')
            : const HomePage(title: 'HomePage UI')));
  }
}
