import 'package:flutter/material.dart';
import 'package:flutter_setup/core/flavour.dart';

void main() {
  setupFlavor();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
