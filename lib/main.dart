import 'package:arg30_frontend/firebase_options.dart';
import 'package:arg30_frontend/presentation/auth/pages/login_page.dart';
import 'package:arg30_frontend/presentation/auth/pages/register_page.dart';
import 'package:arg30_frontend/presentation/dashboard/admin/pages/admin_dashboard_page.dart';
import 'package:arg30_frontend/presentation/dashboard/user/pages/user_dashboard_page.dart';
import 'package:arg30_frontend/presentation/dashboard/user/viewmodel/analysis_viewmodel.dart';
import 'package:arg30_frontend/presentation/splash/bloc/splash_cubit.dart';
import 'package:arg30_frontend/presentation/splash/pages/splash_page.dart';
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
        // Splash cubit
        BlocProvider<SplashCubit>(create: (_) => SplashCubit()),

        // User Dashboard → analiz sonuçlarını yöneten ViewModel
        ChangeNotifierProvider(create: (_) => AnalysisViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ARG30 - Doküman Sınıflandırma Sistemi',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),

        // İlk açılış ekranı
        home: const SplashPage(),

        // Named routes
        routes: {
          '/login': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
          '/admin': (_) => const AdminDashboardPage(),
          '/user': (_) => const UserDashboardPage(),
        },
      ),
    );
  }
}
