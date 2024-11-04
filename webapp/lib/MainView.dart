import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webapp/bloc/authenticationBloc.dart';
import 'package:webapp/routes/routes.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Restaurant WebApp",
      debugShowCheckedModeBanner: false,
      routerConfig: router(context.read<AuthenticationBloc>()),
    );
  }
}
