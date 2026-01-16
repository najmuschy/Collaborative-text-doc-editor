// login_screen.dart - SIMPLIFIED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../widgets/sign_in_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInitialized = ref.watch(authInitializedProvider);

    // Ensure repository is created
    ref.watch(authRepositoryProvider);

    // Show errors only
    ref.listen<String?>(authErrorProvider, (previous, next) {
      if (next != null && previous != next) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: isInitialized
            ? const SignInButton()
            : const CircularProgressIndicator(),
      ),
    );
  }
}