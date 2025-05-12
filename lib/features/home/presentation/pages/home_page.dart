import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../mqtt_client/presentation/bloc/mqtt_cubit.dart';
import '../../../mqtt_client/presentation/bloc/mqtt_event.dart';
import '../../../mqtt_client/presentation/bloc/mqtt_state.dart';
import '../../../mqtt_client/presentation/pages/mqtt_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Demo Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sensors,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Simple MQTT Client',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'A demo app to demonstrate MQTT with BLoC',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            BlocBuilder<MqttCubit, MqttState>(
              builder: (context, state) {
                return ElevatedButton.icon(
                  onPressed: () {
                    if (!state.isConnected) {
                      context.read<MqttCubit>().add(const MqttConnectEvent());
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MqttPage()),
                    );
                  },
                  icon: const Icon(Icons.navigate_next),
                  label: const Text('Go to MQTT Client'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<MqttCubit, MqttState>(
              builder: (context, state) {
                return Text(
                  state.isConnected
                      ? 'Status: Connected'
                      : 'Status: Disconnected',
                  style: TextStyle(
                    color: state.isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
