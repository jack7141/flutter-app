import 'dart:async';

import 'package:celeb_voice/features/authentication/repos/authentication_repo.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class SocialAuthViewModel extends AsyncNotifier<void> {
  late final AuthenticationRepo _authRepo;

  @override
  FutureOr<void> build() {
    _authRepo = ref.read(authRepoProvider);
  }

  Future<void> googleSignIn() async {
    print("✅ [1/5] Google Sign-In process started.");
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("🚨 Google login cancelled by user.");
        throw Exception("Google login cancelled.");
      }

      print(
        "✅ [2/5] Google user info received: ${googleUser.displayName} (${googleUser.email})",
      );

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        print("🚨 Failed to get Google ID token.");
        throw Exception("Failed to get Google ID token.");
      }

      print(
        "✅ [3/5] Google ID token received successfully. Length: ${idToken.length}",
      );

      print("✅ [4/5] Sending ID token to our backend...");
      await _authRepo.googleSocialLogin(idToken);

      print("✅ [5/5] Backend communication successful.");
    });

    if (state.hasError) {
      print("❌ An error occurred during the process: ${state.error}");
    }
  }
}

final socialAuthProvider = AsyncNotifierProvider<SocialAuthViewModel, void>(
  () => SocialAuthViewModel(),
);
