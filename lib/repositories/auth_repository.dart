// auth_repository.dart - FIXED VERSION
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_doc/models/response_model.dart';
import 'package:google_doc/models/user_model.dart';
import 'package:google_doc/urls.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

import 'package:http/http.dart';
import 'package:pretty_logger/pretty_logger.dart';

import 'local_storage_repository.dart';

final Provider<AuthRepository> authRepositoryProvider =
Provider<AuthRepository>(
      (ref) => AuthRepository(
    localStorageRepository: LocalStorageRepository(),
    googleSignIn: GoogleSignIn.instance,
    client: Client(),
    ref: ref,
  ),
);

final authResponseProvider = StateProvider<ResponseModel?>((ref) => null);
final userProvider = StateProvider<UserModel?>((ref) => null);
final authLoadingProvider = StateProvider<bool>((ref) => false);
final authErrorProvider = StateProvider<String?>((ref) => null);
final authInitializedProvider = StateProvider<bool>((ref) => false);

class AuthRepository {
  final LocalStorageRepository _localStorageRepository;
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final Ref _ref;
  GoogleSignInAccount? _currentUser;
  final _authStateController = StreamController<GoogleSignInAccount?>.broadcast();

  AuthRepository({
    required LocalStorageRepository localStorageRepository,
    required GoogleSignIn googleSignIn,
    required Client client,
    required Ref ref,
  })  : _client = client,
        _localStorageRepository = localStorageRepository,
        _googleSignIn = googleSignIn,
        _ref = ref {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Initialize Google Sign-In
    await _googleSignIn.initialize(
      clientId: kIsWeb
          ? '265152790106-u75pe0dtajvlm1ldoaa3525bdcr3m3jb.apps.googleusercontent.com'
          : null,
      serverClientId: !kIsWeb
          ? "265152790106-u75pe0dtajvlm1ldoaa3525bdcr3m3jb.apps.googleusercontent.com"
          : null,
    );

    _ref.read(authInitializedProvider.notifier).state = true;

    // Listen to authentication events
    _googleSignIn.authenticationEvents.listen((event) async {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        _currentUser = event.user;
        _authStateController.add(event.user);
        print('User signed in: ${event.user.email}');

        if (kIsWeb) {
          _ref.read(authErrorProvider.notifier).state = null;

          final response = await sendDataToBackend(event.user);

          _ref.read(authResponseProvider.notifier).state = response;

          if (response.errorMessage != null) {
            _ref.read(authErrorProvider.notifier).state = response.errorMessage;
            print('Web backend error: ${response.errorMessage}');
          } else if (response.data != null) {
            _ref.read(userProvider.notifier).state = response.data as UserModel;
            _ref.read(authErrorProvider.notifier).state = null;
            print('Web user saved: ${response.data}');
          }
        }
      } else if (event is GoogleSignInAuthenticationEventSignOut) {
        _currentUser = null;
        _authStateController.add(null);
        _ref.read(userProvider.notifier).state = null;
        print('User signed out');
      }
    });

    // For web, attempt silent sign-in on initialization
    if (kIsWeb) {
      try {
        print('🔄 Attempting to restore session...');
        await _googleSignIn.attemptLightweightAuthentication();
        print('✅ Session restored!');
      } catch (e) {
        print('❌ No session to restore: $e');
      }
    }
  }

  Future<ResponseModel> sendDataToBackend(GoogleSignInAccount user) async {
    ResponseModel responseModel = ResponseModel(errorMessage: null, data: null);

    try {
      final userAcc = UserModel(
        name: user.displayName ?? 'Unknown',
        email: user.email,
        profilePic: user.photoUrl ?? '',
        uid: '',
        token: '',
      );

      final Uri uri = Uri.parse(Urls.signUpUrl);
      PLog.info('📤 Sending signup request to: $uri');

      final res = await _client.post(
        uri,
        body: jsonEncode(userAcc.toMap()),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      PLog.info('📥 Response status: ${res.statusCode}');
      PLog.info('📥 Response body: ${res.body}');

      switch (res.statusCode) {
        case 200:
          final responseBody = jsonDecode(res.body);
          final newUser = userAcc.copyWith(
            uid: responseBody['user']['_id'],
            token: responseBody['token'],
          );

          // Save token to local storage
          await _localStorageRepository.setToken(newUser.token!);
          PLog.success('✅ Token saved successfully');

          responseModel = ResponseModel(errorMessage: null, data: newUser);
          break;

        default:
          responseModel = ResponseModel(
            errorMessage: 'Server error: ${res.statusCode} - ${res.body}',
            data: null,
          );
          PLog.error('❌ Server error: ${res.statusCode}');
      }
    } catch (e) {
      PLog.error('❌ Error in sendDataToBackend: $e');
      responseModel = ResponseModel(
        errorMessage: 'Network error: $e',
        data: null,
      );
    }

    return responseModel;
  }

  Future<ResponseModel?> signInGoogle() async {
    ResponseModel responseModel = ResponseModel(errorMessage: null, data: null);
    try {
      if (_googleSignIn.supportsAuthenticate()) {
        // Android: use authenticate()
        final GoogleSignInAccount user = await _googleSignIn.authenticate();
        _currentUser = user;

        responseModel = await sendDataToBackend(user);
      } else {
        // Web: trigger authentication with user interaction
        return null;
      }
    } catch (e) {
      responseModel = ResponseModel(errorMessage: e.toString(), data: null);
    }
    return responseModel;
  }

  // ⚠️ FIXED: This is the main issue!
  Future<ResponseModel?> getUserData() async {
    ResponseModel responseModel = ResponseModel(errorMessage: null, data: null);

    try {
      // FIX 1: Properly await the token retrieval
      final token = await _localStorageRepository.getToken();

      PLog.info('🔑 Retrieved token: $token');

      // FIX 2: Check if token is null or empty
      if (token == null || token.isEmpty) {
        PLog.warning('⚠️ No token found in storage');
        return null;
      }

      final Uri uri = Uri.parse(Urls.getUserData);
      PLog.info('📤 Fetching user data from: $uri');

      final res = await _client.get(
        uri,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      PLog.info('📥 Response status: ${res.statusCode}');
      PLog.info('📥 Response body: ${res.body}');

      switch (res.statusCode) {
        case 200:
          final responseBody = jsonDecode(res.body);

          // FIX 3: Match your backend response structure { user, token }
          final userData = responseBody['user'];
          final tokenFromBackend = responseBody['token'];

          final user = UserModel.fromMap(userData).copyWith(token: tokenFromBackend ?? token);

          responseModel = ResponseModel(errorMessage: null, data: user);
          _ref.read(userProvider.notifier).state = user;

          PLog.success('✅ User data loaded successfully');
          break;

        case 401:
        // Token expired or invalid
          PLog.warning('⚠️ Token invalid or expired');
          await _localStorageRepository.clearToken();
          break;

        default:
          PLog.error('❌ Server error: ${res.statusCode}');
          responseModel = ResponseModel(
            errorMessage: 'Server error: ${res.statusCode}',
            data: null,
          );
      }
    } catch (e) {
      PLog.error('❌ Error in getUserData: $e');
      responseModel = ResponseModel(errorMessage: e.toString(), data: null);
    }

    return responseModel;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut() ;
      await _localStorageRepository.clearToken(); // ✅ Clear token on sign out
      _currentUser = null;
      _authStateController.add(null);
      _ref.read(userProvider.notifier).state = null;
      PLog.info('✅ User signed out successfully');
    } catch (e) {
      PLog.error('❌ Sign out failed: $e');
    }
  }

  GoogleSignInAccount? get currentUser => _currentUser;
  Stream<GoogleSignInAccount?> get authStateChanges => _authStateController.stream;

  void dispose() {
    _authStateController.close();
  }
}