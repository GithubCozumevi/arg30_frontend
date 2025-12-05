import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final role = prefs.getString("role");

    if (role == null) {
      emit(UnAuthenticated());
    } else if (role == "admin") {
      emit(AuthenticatedAdmin());
    } else {
      emit(AuthenticatedUser());
    }
  }
}
