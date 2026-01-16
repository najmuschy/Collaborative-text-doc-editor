
import 'package:flutter/material.dart';
import 'package:google_doc/screens/LoginSceen.dart';
import 'package:google_doc/screens/document_screen.dart';
import 'package:google_doc/screens/home_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (route)=> MaterialPage(child: const LoginScreen())
});

final loggedInRoute = RouteMap(routes: {
  '/': (route) => MaterialPage(child: const HomeScreen()),
  '/doc/:id' : (route) => MaterialPage(child: DocumentScreen(id: route.pathParameters['id'] ?? ''))
});