import 'package:flutter/material.dart';
import 'features/mqtt_client/presentation/pages/mqtt_page.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a direct page instead of tabs
    return const MqttPage();
  }
}
