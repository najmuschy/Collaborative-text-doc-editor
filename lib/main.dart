import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_doc/models/response_model.dart';
import 'package:google_doc/models/user_model.dart';
import 'package:google_doc/repositories/auth_repository.dart';
import 'package:google_doc/routes.dart';
import 'package:google_doc/screens/LoginSceen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_doc/screens/home_screen.dart';
import 'package:pretty_logger/pretty_logger.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}


class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }
  Future<void> getUserData() async {
    ResponseModel? responseModel = await ref.read(authRepositoryProvider).getUserData();
    if(responseModel != null && responseModel.data!=null){
      ref.read(userProvider.notifier).update((state)=>responseModel.data);
    }
  }
  @override
  Widget build(BuildContext context) {
    return  MaterialApp.router(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      routerDelegate: RoutemasterDelegate(routesBuilder: (context){
        final user = ref.watch(userProvider);
        if(user==null){
          return loggedOutRoute ;
        }
        return loggedInRoute ;
      }),
      routeInformationParser: const RoutemasterParser(),

    );
  }
}
