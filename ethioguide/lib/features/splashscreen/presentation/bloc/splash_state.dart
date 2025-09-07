import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();
  @override
  List<Object> get props => [];
}

// The state when the splash screen first appears and is checking the auth status.
class SplashInitial extends SplashState {}

// A state to tell the UI to navigate to the Home screen because the user is logged in.
class NavigateToHome extends SplashState {}

// A state to tell the UI to navigate to the Onboarding screen.
class NavigateToOnboarding extends SplashState {}

// A state to tell the UI to navigate to the Authentication screen.
class NavigateToAuth extends SplashState {}