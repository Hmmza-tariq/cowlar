import 'package:equatable/equatable.dart';

/// Events for the MQTT Cubit
abstract class MqttEvent extends Equatable {
  const MqttEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize and connect to MQTT broker
class MqttConnectEvent extends MqttEvent {
  const MqttConnectEvent();
}

/// Event to disconnect from MQTT broker
class MqttDisconnectEvent extends MqttEvent {
  const MqttDisconnectEvent();
}

/// Event to subscribe to a topic
class MqttSubscribeEvent extends MqttEvent {
  final String topic;

  const MqttSubscribeEvent(this.topic);

  @override
  List<Object?> get props => [topic];
}

/// Event to unsubscribe from current topic
class MqttUnsubscribeEvent extends MqttEvent {
  const MqttUnsubscribeEvent();
}

/// Event to publish a message
class MqttPublishEvent extends MqttEvent {
  final String message;
  final String topic;

  const MqttPublishEvent({
    required this.message,
    required this.topic,
  });

  @override
  List<Object?> get props => [message, topic];
}

/// Event when a new message is received
class MqttMessageReceivedEvent extends MqttEvent {
  final String message;

  const MqttMessageReceivedEvent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Event to trigger data download on specific message
class MqttTriggerDownloadEvent extends MqttEvent {
  const MqttTriggerDownloadEvent();
}

/// Event to reset download trigger flag
class MqttResetDownloadTriggerEvent extends MqttEvent {
  const MqttResetDownloadTriggerEvent();
}
