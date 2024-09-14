// ignore_for_file: prefer_const_constructors

import 'package:app/app.dart';
import 'package:app/simple_bloc_observer.dart';
import 'package:app/user/firebase_user.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Bloc.observer = SimpleBlocObserver();
  runApp(Main(FirebaseUserRepo()));
}
