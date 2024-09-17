// ignore_for_file: prefer_const_constructors

import 'package:delivery/bloc/authenticationBloc.dart';
import 'package:delivery/menus/autenticacao/bloc/LogInBloc.dart';
import 'package:delivery/menus/autenticacao/views/WelcomeScreen.dart';
import 'package:delivery/menus/home/views/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Projeto",
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            return BlocProvider(
              create: (context) =>
                  SignInBloc(context.read<AuthenticationBloc>().userRepository),
              child: const HomePage(),
            );
          } else {
            return WelcomeScreen();
          }
        },
      ),
    );
  }
}
