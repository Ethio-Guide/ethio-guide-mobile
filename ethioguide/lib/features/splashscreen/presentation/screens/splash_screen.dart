import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // THE FIX: Use the DI container to create the new SplashBloc
      // and immediately add the AppStarted event.
      create: (context) => GetIt.instance<SplashBloc>()..add(AppStarted()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          // THE FIX: Listen for the new, specific navigation states from the BLoC.
          if (state is NavigateToHome) {
            context.go('/home');
          } else if (state is NavigateToOnboarding) {
            context.go('/onboarding');
          } else if (state is NavigateToAuth) {
            context.go('/auth');
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  // Make sure your logo path is correct.
                  'assets/images/dark_logo.jpg', 
                  width: 300.0, 
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFa7b3b9)), // Hit Gray
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}