import 'dart:ui';
import 'package:app/bloc/authenticationBloc.dart';
import 'package:app/menus/autenticacao/bloc/LogInBloc.dart';
import 'package:app/menus/autenticacao/bloc/SignUpBloc.dart';
import 'package:app/menus/autenticacao/views/LogInScreen.dart';
import 'package:app/menus/autenticacao/views/SignUpScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Background image
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/background.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Column(
                  children: [
                    // Image at the top of the screen
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Image.asset(
                        "images/Logo.png",
                        height: 250,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 1.8,
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50.0),
                              child: TabBar(
                                controller: tabController,
                                unselectedLabelColor: Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.5),
                                labelColor: Colors.white,
                                indicatorColor:
                                    const Color.fromRGBO(252, 185, 19, 1),
                                tabs: const [
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text(
                                      'Log In',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: tabController,
                                children: [
                                  BlocProvider<SignInBloc>(
                                    create: (context) => SignInBloc(context
                                        .read<AuthenticationBloc>()
                                        .userRepository),
                                    child: const SignInScreen(),
                                  ),
                                  BlocProvider<SignUpBloc>(
                                    create: (context) => SignUpBloc(context
                                        .read<AuthenticationBloc>()
                                        .userRepository),
                                    child: const SignUpScreen(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
