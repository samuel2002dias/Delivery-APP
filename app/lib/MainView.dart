// ignore_for_file: prefer_const_constructors

import 'package:app/bloc/authenticationBloc.dart';
import 'package:app/menus/autenticacao/views/WelcomeScreen.dart';
import 'package:app/menus/home/views/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Projeto",
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            return HomePage();
          } else {
            return WelcomeScreen();
          }
        },
      ),
    );
  }
}
