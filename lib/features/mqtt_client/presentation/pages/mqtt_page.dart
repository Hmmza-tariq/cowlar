import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data_download/presentation/pages/data_download_page.dart';
import '../../../data_download/presentation/bloc/download_cubit.dart';
import '../bloc/mqtt_cubit.dart';
import '../bloc/mqtt_event.dart';
import '../bloc/mqtt_state.dart';
import '../widgets/message_list.dart';

class MqttPage extends StatefulWidget {
  const MqttPage({super.key});

  @override
  State<MqttPage> createState() => _MqttPageState();
}

class _MqttPageState extends State<MqttPage> {
  final TextEditingController _topicController =
      TextEditingController(text: 'test/topic');
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Connect on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MqttCubit>().add(const MqttConnectEvent());
    });
  }

  @override
  void dispose() {
    _topicController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Client Demo'),
        actions: [
          // Download button when data is available
          FutureBuilder<int>(
              future: _checkRecordCount(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                final recordCount = snapshot.data ?? 0;
                if (recordCount > 0) {
                  return IconButton(
                    icon: const Icon(Icons.data_array),
                    tooltip: 'View Downloaded Data ($recordCount records)',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const DataDownloadPage()),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              }),
          // Connect/disconnect button
          BlocBuilder<MqttCubit, MqttState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(state.isConnected ? Icons.link : Icons.link_off),
                onPressed: () {
                  if (state.isConnected) {
                    context.read<MqttCubit>().add(const MqttDisconnectEvent());
                  } else {
                    context.read<MqttCubit>().add(const MqttConnectEvent());
                  }
                },
                tooltip: state.isConnected ? 'Disconnect' : 'Connect',
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<MqttCubit, MqttState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }

          // Debug listener for state changes
          print(
              'MqttState changed: isConnected=${state.isConnected}, isSubscribed=${state.isSubscribed}, shouldDownload=${state.shouldDownload}, messages=${state.messages.length}');
          if (state.shouldDownload) {
            print('STATE HAS shouldDownload=true!');
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App title and intro
                  const Text(
                    'MQTT Client',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect to an MQTT broker and subscribe to a topic to receive messages.',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Connection status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: state.isConnected
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: state.isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          state.isConnected ? Icons.wifi : Icons.wifi_off,
                          color: state.isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state.isConnected
                              ? 'Connected to broker'
                              : 'Disconnected',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                state.isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Topic input field (disabled if subscribed)
                  TextField(
                    controller: _topicController,
                    decoration: InputDecoration(
                      labelText: 'Topic',
                      hintText: 'Enter topic to subscribe',
                      prefixIcon: const Icon(Icons.tag),
                      enabled: !state.isSubscribed && state.isConnected,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Subscribe/Unsubscribe button
                  if (state.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton.icon(
                      onPressed: state.isConnected
                          ? () {
                              if (state.isSubscribed) {
                                // Unsubscribe
                                context
                                    .read<MqttCubit>()
                                    .add(const MqttUnsubscribeEvent());
                              } else {
                                // Subscribe
                                final String topic =
                                    _topicController.text.trim();
                                if (topic.isNotEmpty) {
                                  context
                                      .read<MqttCubit>()
                                      .add(MqttSubscribeEvent(topic));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Please enter a topic')),
                                  );
                                }
                              }
                            }
                          : null,
                      icon: Icon(state.isSubscribed
                          ? Icons.unsubscribe
                          : Icons.notifications),
                      label: Text(
                          state.isSubscribed ? 'Unsubscribe' : 'Subscribe'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Connection/Subscription status info
                  if (!state.isConnected)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue, size: 40),
                            SizedBox(height: 8),
                            Text(
                              'Connection Info',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'If you are having trouble connecting, please check:'
                              '\n• Your internet connection is working'
                              '\n• The MQTT broker address is correct'
                              '\n• The port is not blocked by a firewall',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ), // Messages section (only shown when subscribed)
                  if (state.isSubscribed) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Received Messages:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (state.shouldDownload)
                          Builder(builder: (context) {
                            // Debug print when download button is shown
                            print(
                                'Showing download button - shouldDownload is true');
                            return ElevatedButton.icon(
                              onPressed: () {
                                print(
                                    'Download button pressed - navigating to DataDownloadPage');
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const DataDownloadPage(),
                                  ),
                                );
                                // Reset download trigger after navigation
                                context
                                    .read<MqttCubit>()
                                    .add(const MqttResetDownloadTriggerEvent());
                              },
                              icon: const Icon(Icons.download),
                              label: const Text('Download Data'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                              ),
                            );
                          })
                        else
                          const Chip(
                            label: Icon(Icons.check_circle, size: 16),
                            backgroundColor: Colors.green,
                            labelStyle: TextStyle(color: Colors.white),
                            avatar: Icon(Icons.notifications_active,
                                color: Colors.white, size: 14),
                            labelPadding: EdgeInsets.symmetric(horizontal: 4),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      // Message list - with fixed height to prevent overflow                    SizedBox(
                      height: 200, // Fixed height for message list
                      child: Column(
                        children: [
                          if (state.shouldDownload)
                            Container(
                              color: Colors.amber,
                              padding: const EdgeInsets.all(8),
                              child: const Text(
                                'Download trigger active!',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          Expanded(
                            child: MessageList(messages: state.messages),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    SizedBox(
                      height: 200, // Fixed height prevents layout shift
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.topic_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text(
                              'Subscribe to a topic to see messages',
                              style: TextStyle(color: Colors.grey),
                            ),
                            if (state.isConnected) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Enter a topic in the field above and tap "Subscribe"',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                  // Message input field at the bottom of the page
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            labelText: 'Message',
                            hintText: 'Enter message to publish',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabled: state.isSubscribed && state.isConnected,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: (state.isSubscribed && state.isConnected)
                            ? () {
                                final String message =
                                    _messageController.text.trim();
                                if (message.isNotEmpty && state.topic != null) {
                                  context.read<MqttCubit>().add(
                                        MqttPublishEvent(
                                          message: message,
                                          topic: state.topic!,
                                        ),
                                      );
                                  _messageController.clear();
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Add the _checkRecordCount method to access IsarService through DownloadCubit
  Future<int> _checkRecordCount(BuildContext context) async {
    try {
      final downloadCubit = context.read<DownloadCubit>();
      // Use DownloadCubit to access IsarService and get record count
      return await downloadCubit.getRecordCount();
    } catch (e) {
      debugPrint('Error checking record count: $e');
      return 0;
    }
  }
}
