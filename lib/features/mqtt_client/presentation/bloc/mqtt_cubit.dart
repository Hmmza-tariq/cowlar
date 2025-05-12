import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/mqtt_service.dart';
import 'mqtt_event.dart';
import 'mqtt_state.dart';

/// Cubit to manage MQTT connections and states
class MqttCubit extends Bloc<MqttEvent, MqttState> {
  final MqttService _mqttService;
  MqttCubit({required MqttService mqttService})
      : _mqttService = mqttService,
        super(MqttState.initial()) {
    // Register event handlers
    on<MqttConnectEvent>(_handleConnect);
    on<MqttDisconnectEvent>(_handleDisconnect);
    on<MqttSubscribeEvent>(_handleSubscribe);
    on<MqttUnsubscribeEvent>(_handleUnsubscribe);
    on<MqttPublishEvent>(_handlePublish);
    on<MqttMessageReceivedEvent>(_handleMessageReceived);
    on<MqttTriggerDownloadEvent>(_handleTriggerDownload);
    on<MqttResetDownloadTriggerEvent>(_handleResetDownloadTrigger);

    // Listen for messages
    _mqttService.addMessageListener(_onMessageReceived);

    // Initialize MQTT
    _mqttService.initialize();
  }

  /// Handle connection event
  Future<void> _handleConnect(
      MqttConnectEvent event, Emitter<MqttState> emit) async {
    try {
      emit(state.loading());
      final bool connected = await _mqttService.connect();

      if (connected) {
        emit(state.copyWith(
          isConnected: true,
          isLoading: false,
          error: null,
        ));
      } else {
        emit(state.withError('Failed to connect to MQTT broker'));
      }
    } catch (e) {
      emit(state.withError('Connection error: ${e.toString()}'));
    }
  }

  /// Handle disconnect event
  void _handleDisconnect(MqttDisconnectEvent event, Emitter<MqttState> emit) {
    _mqttService.disconnect();
    emit(MqttState.initial());
  }

  /// Handle subscribe to topic event
  void _handleSubscribe(MqttSubscribeEvent event, Emitter<MqttState> emit) {
    try {
      if (!state.isConnected) {
        emit(state.withError('Cannot subscribe: not connected'));
        return;
      }

      emit(state.loading());

      _mqttService.subscribe(event.topic);

      emit(state.copyWith(
        isSubscribed: true,
        topic: event.topic,
        isLoading: false,
        error: null,
        messages: [],
      ));
    } catch (e) {
      emit(state.withError('Subscription error: ${e.toString()}'));
    }
  }

  /// Handle unsubscribe event
  void _handleUnsubscribe(MqttUnsubscribeEvent event, Emitter<MqttState> emit) {
    if (!state.isSubscribed) return;

    _mqttService.unsubscribe();
    _mqttService.clearMessages();

    emit(state.copyWith(
      isSubscribed: false,
      topic: null,
      messages: [],
    ));
  }

  /// Handle publishing a message
  void _handlePublish(MqttPublishEvent event, Emitter<MqttState> emit) {
    try {
      if (!state.isConnected) {
        emit(state.withError('Cannot publish: not connected'));
        return;
      }

      _mqttService.publishMessage(event.topic, event.message);
    } catch (e) {
      emit(state.withError('Publish error: ${e.toString()}'));
    }
  }

  /// Handle message received event
  void _handleMessageReceived(
      MqttMessageReceivedEvent event, Emitter<MqttState> emit) {
    final List<String> updatedMessages = [...state.messages, event.message];

    // Debug: Print when download is detected
    print('Message received: "${event.message}"');

    // Check if message contains the download trigger phrase
    if (event.message.toLowerCase().contains('download')) {
      print('DOWNLOAD KEYWORD DETECTED - Setting shouldDownload directly');
      // Set the download flag directly instead of using another event
      emit(state.copyWith(
        messages: updatedMessages,
        shouldDownload: true,
      ));
    } else {
      emit(state.copyWith(messages: updatedMessages));
    }
  }

  /// Handle download trigger event
  void _handleTriggerDownload(
      MqttTriggerDownloadEvent event, Emitter<MqttState> emit) {
    print('_handleTriggerDownload called - setting shouldDownload to true');
    emit(state.copyWith(shouldDownload: true));
    print('State after update: shouldDownload = ${state.shouldDownload}');
  }

  /// Handle reset download trigger event
  void _handleResetDownloadTrigger(
      MqttResetDownloadTriggerEvent event, Emitter<MqttState> emit) {
    emit(state.copyWith(shouldDownload: false));
  }

  /// Callback for messages from the MQTT service
  void _onMessageReceived(String message) {
    print('MQTT Service callback: message received - "$message"');

    // Create a message received event
    add(MqttMessageReceivedEvent(message));

    // If message contains download, also trigger download event
    if (message.toLowerCase().contains('download')) {
      print(
          'MQTT Service callback: DOWNLOAD keyword detected - triggering download event');
      add(const MqttTriggerDownloadEvent());
    }
  }

  @override
  Future<void> close() {
    _mqttService.removeMessageListener(_onMessageReceived);
    _mqttService.disconnect();
    return super.close();
  }
}
