// ignore_for_file: unused_import

import 'package:delivery/MainView.dart';
import 'package:delivery/bloc/authenticationBloc.dart';
import 'package:delivery/user/userClass.dart';
import 'package:flutter/foundation.dart';
import 'package:delivery/simple_bloc_observer.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Main extends StatelessWidget {
  final UserRepository userRepository;
  const Main(this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthenticationBloc>(
      create: (context) => AuthenticationBloc(userRepository: userRepository),
      child: const MainView(),
    );
  }
}
