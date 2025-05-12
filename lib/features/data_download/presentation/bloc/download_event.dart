import 'package:equatable/equatable.dart';

import '../../data/models/user_record.dart';

abstract class DownloadEvent extends Equatable {
  const DownloadEvent();

  @override
  List<Object?> get props => [];
}

class DownloadStartEvent extends DownloadEvent {
  final int recordCount;
  const DownloadStartEvent({
    this.recordCount = 5000,
  });

  @override
  List<Object?> get props => [recordCount];
}

class DownloadProgressEvent extends DownloadEvent {
  final double progress;
  final List<UserRecord> batch;

  const DownloadProgressEvent({
    required this.progress,
    required this.batch,
  });

  @override
  List<Object?> get props => [progress, batch];
}

class DownloadCompleteEvent extends DownloadEvent {
  const DownloadCompleteEvent();
}

class LoadRecordsEvent extends DownloadEvent {
  const LoadRecordsEvent();
}

class LoadMoreRecordsEvent extends DownloadEvent {
  const LoadMoreRecordsEvent();
}

class ClearRecordsEvent extends DownloadEvent {
  const ClearRecordsEvent();
}
