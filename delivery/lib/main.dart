// ignore_for_file: prefer_const_constructors

import 'package:delivery/app.dart';
import 'package:delivery/simple_bloc_observer.dart';
import 'package:delivery/user/firebase_user.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Bloc.observer = SimpleBlocObserver();
  runApp(Main(FirebaseUserRepo()));
}
