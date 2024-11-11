// ignore_for_file: body_might_complete_normally_nullable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webapp/bloc/authenticationBloc.dart';
import 'package:webapp/menus/autenticacao/bloc/LogInBloc.dart';
import 'package:webapp/menus/autenticacao/views/LogInPage.dart';
import 'package:webapp/menus/base/views/BasePage.dart';
import 'package:webapp/menus/create_bloc/create_bloc.dart';
import 'package:webapp/menus/home/views/AddProduct.dart';
import 'package:webapp/menus/home/views/EditProduct.dart';
import 'package:webapp/menus/home/views/HomePage.dart';
import 'package:webapp/menus/splash/views/SplashPage.dart';
import 'package:webapp/product/src/firebase_product.dart';
import 'package:webapp/menus/upload_bloc/upload_bloc.dart';
import 'package:webapp/menus/home/views/UserStatus.dart';
import 'package:webapp/menus/home/views/AddImage.dart'; // Import FeedbackGiven page

final _navKey = GlobalKey<NavigatorState>();
final _shellNavKey = GlobalKey<NavigatorState>();

GoRouter router(AuthenticationBloc authBloc) {
  return GoRouter(
    navigatorKey: _navKey,
    initialLocation: '/',
    redirect: (context, state) {
      if (authBloc.state.status == AuthenticationStatus.unknown) {
        return '/';
      }
    },
    routes: [
      ShellRoute(
          navigatorKey: _shellNavKey,
          builder: (context, state, child) {
            if (state.fullPath == '/login' || state.fullPath == '/') {
              return child;
            } else {
              return BlocProvider<SignInBloc>(
                  create: (context) => SignInBloc(
                      context.read<AuthenticationBloc>().userRepository),
                  child: BasePage(child));
            }
          },
          routes: [
            GoRoute(
                path: '/',
                builder: (context, state) =>
                    BlocProvider<AuthenticationBloc>.value(
                      value: BlocProvider.of<AuthenticationBloc>(context),
                      child: const SplashPage(),
                    )),
            GoRoute(
                path: '/login',
                builder: (context, state) =>
                    BlocProvider<AuthenticationBloc>.value(
                      value: BlocProvider.of<AuthenticationBloc>(context),
                      child: BlocProvider<SignInBloc>(
                        create: (context) => SignInBloc(
                            context.read<AuthenticationBloc>().userRepository),
                        child: const SignInScreen(),
                      ),
                    )),
            GoRoute(
                path: '/home',
                builder: (context, state) =>
                    BlocProvider<AuthenticationBloc>.value(
                      value: BlocProvider.of<AuthenticationBloc>(context),
                      child: HomePage(),
                    )),
            GoRoute(
              path: '/add-product',
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider<UploadPictureBloc>(
                    create: (context) => UploadPictureBloc(FirebaseProduct()),
                  ),
                  BlocProvider<CreateProductBloc>(
                    create: (context) => CreateProductBloc(FirebaseProduct()),
                  ),
                ],
                child: const AddProduct(),
              ),
            ),
            GoRoute(
              path: '/edit-product/:productID',
              builder: (context, state) {
                final productID = state.pathParameters['productID']!;
                return BlocProvider(
                  create: (context) => UploadPictureBloc(FirebaseProduct()),
                  child: EditProductPage(productID: productID),
                );
              },
            ),
            GoRoute(
              path: '/user-status/:userId',
              builder: (context, state) {
                final userID = state.pathParameters['userId']!;
                return FeedbacksGiven(userID: userID);
              },
            ),
            GoRoute(
              path: '/addImage',
              builder: (context, state) {
                return BlocProvider<UploadPictureBloc>(
                    create: (context) => UploadPictureBloc(FirebaseProduct()),
                    child: AddImage());
              },
            ),
          ]),
    ],
  );
}
