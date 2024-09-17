// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  final String name;
  final IconData icon;
  const MyWidget({required this.name, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(3, 3),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: Color.fromRGBO(252, 185, 19, 1),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            )));
  }
}
