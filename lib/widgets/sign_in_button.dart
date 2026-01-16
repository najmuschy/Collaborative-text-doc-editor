import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:routemaster/routemaster.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

// Web-only import
import '../screens/home_screen.dart';
import 'web_sign_in_button.dart'
    if (dart.library.io) 'mobile_sign_in_button.dart';

class SignInButton extends ConsumerWidget {
  const SignInButton({super.key});
  Future<void> signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final snackbar = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    final responseModel = await ref.read(authRepositoryProvider).signInGoogle();
    print('Response Model: $responseModel');
    if (responseModel != null) {
      if (responseModel.errorMessage == null && responseModel.data != null) {
        ref.read(userProvider.notifier).state = responseModel.data as UserModel;
        navigator.push('/');
      } else {
        print(responseModel.errorMessage!);
        snackbar.showSnackBar(
          SnackBar(content: Text(responseModel.errorMessage!)),
        );
      }
    }

  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (GoogleSignIn.instance.supportsAuthenticate()) {
      return ElevatedButton(
        onPressed: () => signInWithGoogle(ref, context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/g-logo-2.png', height: 20),
            const SizedBox(width: 8),
            const Text('Sign in with Google'),
          ],
        ),
      );
    } else if (kIsWeb) {
      // Web - use Google's renderButton
      return const WebSignInButton();
    } else {
      return const Text('Sign-in not supported on this platform');
    }
  }
}
