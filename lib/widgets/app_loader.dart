import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final Color backgroundColor;

  const AppLoader({Key? key, this.backgroundColor = const Color(0x80000000)}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
} 