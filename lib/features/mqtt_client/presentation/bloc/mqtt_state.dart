import 'package:equatable/equatable.dart';

class MqttState extends Equatable {
  final bool isConnected;
  final bool isSubscribed;
  final String? topic;
  final List<String> messages;
  final bool isLoading;
  final String? error;

  const MqttState({
    this.isConnected = false,
    this.isSubscribed = false,
    this.topic,
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  MqttState copyWith({
    bool? isConnected,
    bool? isSubscribed,
    String? topic,
    List<String>? messages,
    bool? isLoading,
    String? error,
  }) {
    return MqttState(
      isConnected: isConnected ?? this.isConnected,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      topic: topic ?? this.topic,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  MqttState loading() {
    return copyWith(isLoading: true, error: null);
  }

  MqttState withError(String errorMessage) {
    return copyWith(error: errorMessage, isLoading: false);
  }

  factory MqttState.initial() => const MqttState();

  @override
  List<Object?> get props =>
      [isConnected, isSubscribed, topic, messages, isLoading, error];
}
