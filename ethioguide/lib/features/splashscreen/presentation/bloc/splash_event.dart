import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();
  @override
  List<Object> get props => [];
}

// An event to tell the BLoC that the app has started and it should
// begin the initialization and authentication check.
class AppStarted extends SplashEvent {}