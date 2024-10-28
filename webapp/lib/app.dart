import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webapp/bloc/authenticationBloc.dart';
import 'package:webapp/user/firebase_user.dart';
import 'MainView.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => AuthenticationBloc(
        userRepository: FirebaseUserRepo(),
      ),
      child: const MainView(),
    );
  }
}
