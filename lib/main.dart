import 'package:arg30_frontend/firebase_options.dart';
import 'package:arg30_frontend/presentation/auth/pages/login_page.dart';
import 'package:arg30_frontend/presentation/auth/pages/register_page.dart';
import 'package:arg30_frontend/presentation/dashboard/admin/pages/admin_dashboard_page.dart';
import 'package:arg30_frontend/presentation/dashboard/user/pages/user_dashboard_page.dart';
import 'package:arg30_frontend/presentation/dashboard/user/viewmodel/analysis_viewmodel.dart';
import 'package:arg30_frontend/presentation/history/history_pages.dart';
import 'package:arg30_frontend/presentation/settings/settings_page.dart';
import 'package:arg30_frontend/presentation/splash/bloc/splash_cubit.dart';
import 'package:arg30_frontend/presentation/splash/pages/splash_page.dart';

import 'package:arg30_frontend/presentation/settings/language_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🌍 Dil yönetimi
        ChangeNotifierProvider(create: (_) => LanguageProvider()),

        // Splash cubit
        BlocProvider<SplashCubit>(create: (_) => SplashCubit()),

        // User dashboard analiz viewmodel
        ChangeNotifierProvider(create: (_) => AnalysisViewModel()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, langProv, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ARG30 - Doküman Sınıflandırma Sistemi',

            // 🌍 Uygulamanın aktif dili
            locale: Locale(langProv.lang),

            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
              fontFamily: "Roboto",
            ),

            // İlk açılan ekran (Splash)
            home: const SplashPage(),

            routes: {
              '/login': (_) => const LoginPage(),
              '/register': (_) => const RegisterPage(),
              '/admin': (_) => const AdminDashboardPage(),
              '/user': (_) => const UserDashboardPage(),
              '/settings': (_) => const SettingsPage(),
              '/history': (_) => const HistoryPage(),
            },
          );
        },
      ),
    );
  }
}
