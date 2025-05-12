import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// MQTT connection states
enum MqttConnectionState {
  disconnected,
  connecting,
  connected,
}

/// MQTT Service to handle MQTT connections and message publishing/receiving
class MqttService {
  // Singleton pattern
  MqttService._();
  static final MqttService _instance = MqttService._();

  factory MqttService() => _instance;

  // MQTT Client
  MqttServerClient? _client;

  // Connection state
  MqttConnectionState _connectionState = MqttConnectionState.disconnected;
  MqttConnectionState get connectionState => _connectionState;

  String? _currentTopic;
  String? get currentTopic => _currentTopic;

  final List<String> _receivedMessages = [];
  List<String> get receivedMessages => List.unmodifiable(_receivedMessages);

  final List<Function(String)> _messageListeners = [];

  String get host => dotenv.env['MQTT_HOST'] ?? 'broker.emqx.io';
  int get port => int.tryParse(dotenv.env['MQTT_PORT'] ?? '1883') ?? 1883;

  void initialize() {
    final String randomId = 'flutter_mqtt_${Random().nextInt(10000)}';

    _client = MqttServerClient(host, randomId);
    _client!.port = port;
    _client!.keepAlivePeriod = 60;
    _client!.secure = false;
    _client!.logging(on: true);
    _client!.connectTimeoutPeriod = 3000;

    // Set callbacks
    _client!.onConnected = _onConnected;
    _client!.onDisconnected = _onDisconnected;
    _client!.onSubscribed = _onSubscribed;

    // Setup connection message
    final MqttConnectMessage connectMessage = MqttConnectMessage()
        .withClientIdentifier(randomId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce)
        .withWillRetain()
        .keepAliveFor(60); // Keep alive matches client setting

    _client!.connectionMessage = connectMessage;
  }

  /// Connect to MQTT broker
  Future<bool> connect() async {
    if (_client == null) {
      initialize();
    }

    _connectionState = MqttConnectionState.connecting;

    try {
      // Use a public test broker instead
      _client = MqttServerClient(
          'test.mosquitto.org', 'flutter_mqtt_${Random().nextInt(10000)}');
      _client!.port = 1883;
      _client!.keepAlivePeriod = 60;
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onSubscribed = _onSubscribed;

      final MqttConnectMessage connectMessage = MqttConnectMessage()
          .withClientIdentifier('flutter_mqtt_${Random().nextInt(10000)}')
          .startClean()
          .withWillQos(MqttQos.atMostOnce);

      _client!.connectionMessage = connectMessage;

      await _client!.connect();
      return true;
    } catch (e) {
      debugPrint('MQTT Connect Error: $e');
      disconnect();
      return false;
    }
  }

  /// Disconnect from MQTT broker
  void disconnect() {
    _connectionState = MqttConnectionState.disconnected;
    _currentTopic = null;
    if (_client != null &&
        _client!.connectionStatus!.state != MqttConnectionState.disconnected) {
      _client!.disconnect();
    }
  }

  /// Subscribe to a topic
  void subscribe(String topic) {
    if (_connectionState != MqttConnectionState.connected) {
      debugPrint('MQTT: Cannot subscribe, not connected');
      return;
    }

    _client!.subscribe(topic, MqttQos.atLeastOnce);
    _currentTopic = topic; // Listen for messages
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final MqttPublishMessage receivedMessage =
          messages[0].payload as MqttPublishMessage;
      final String message = MqttPublishPayload.bytesToStringAsString(
          receivedMessage.payload.message);

      // Debug message reception
      debugPrint('MQTT Message Received: "$message"');

      _receivedMessages.add(message);

      // Notify listeners
      for (var listener in _messageListeners) {
        debugPrint('Notifying MQTT listener about message: "$message"');
        listener(message);
      }
    });
  }

  /// Unsubscribe from the current topic
  void unsubscribe() {
    if (_connectionState != MqttConnectionState.connected ||
        _currentTopic == null) {
      return;
    }

    _client!.unsubscribe(_currentTopic!);
    _currentTopic = null;
  }

  /// Publish a message to a topic
  void publishMessage(String topic, String message) {
    if (_connectionState != MqttConnectionState.connected) {
      debugPrint('MQTT: Cannot publish, not connected');
      return;
    }

    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    _client!.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }

  /// Add a message listener
  void addMessageListener(Function(String) listener) {
    _messageListeners.add(listener);
  }

  /// Remove a message listener
  void removeMessageListener(Function(String) listener) {
    _messageListeners.remove(listener);
  }

  /// Clear received messages
  void clearMessages() {
    _receivedMessages.clear();
  }

  // Callback for when connection is established
  void _onConnected() {
    debugPrint('MQTT: Connected');
    _connectionState = MqttConnectionState.connected;
  }

  // Callback for when disconnected
  void _onDisconnected() {
    debugPrint('MQTT: Disconnected');
    _connectionState = MqttConnectionState.disconnected;
    _currentTopic = null;
  }

  // Callback for when subscription is confirmed
  void _onSubscribed(String topic) {
    debugPrint('MQTT: Subscribed to $topic');
  }
}
