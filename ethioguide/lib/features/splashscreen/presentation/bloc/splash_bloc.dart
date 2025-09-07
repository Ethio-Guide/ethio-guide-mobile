import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
// IMPORT THE NEW USE CASE from the authentication feature
import 'package:ethioguide/features/authentication/domain/usecases/check_auth_status.dart'; 
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  // THE FIX: It now depends on CheckAuthStatus.
  final CheckAuthStatus checkAuthStatus;

  SplashBloc({required this.checkAuthStatus}) : super(SplashInitial()) {
    // THE FIX: It now listens for the AppStarted event.
    on<AppStarted>(_onAppStarted);
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<SplashState> emit,
  ) async {
    // We add a small delay so the user can see your app's branding.
    await Future.delayed(const Duration(seconds: 2));

    // We call the use case to check if a token is stored on the device.
    final bool isLoggedIn = await checkAuthStatus();

    if (isLoggedIn) {
      // If a token exists, the user is logged in. Navigate them directly to home.
      emit(NavigateToHome());
    } else {
      // If no token exists, the user is logged out. The correct first-time
      // experience is to show them the onboarding screens.
      // We will add logic later to check if they've already completed onboarding.
      emit(NavigateToOnboarding());
    }
  }
}