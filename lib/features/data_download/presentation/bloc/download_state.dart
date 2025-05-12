import 'package:equatable/equatable.dart';

import '../../data/models/user_record.dart';

class DownloadState extends Equatable {
  final bool isDownloading;
  final double progress;
  final int totalRecords;
  final int downloadedRecords;
  final List<UserRecord> displayedRecords;
  final bool isLoading;
  final bool hasReachedMax;
  final String? error;
  final String apiName;

  const DownloadState({
    this.isDownloading = false,
    this.progress = 0.0,
    this.totalRecords = 0,
    this.downloadedRecords = 0,
    this.displayedRecords = const [],
    this.isLoading = false,
    this.hasReachedMax = false,
    this.error,
    this.apiName = 'JSONPlaceholder',
  });
  DownloadState copyWith({
    bool? isDownloading,
    double? progress,
    int? totalRecords,
    int? downloadedRecords,
    List<UserRecord>? displayedRecords,
    bool? isLoading,
    bool? hasReachedMax,
    String? error,
    String? apiName,
  }) {
    return DownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
      totalRecords: totalRecords ?? this.totalRecords,
      downloadedRecords: downloadedRecords ?? this.downloadedRecords,
      displayedRecords: displayedRecords ?? this.displayedRecords,
      isLoading: isLoading ?? this.isLoading,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      error: error,
      apiName: apiName ?? this.apiName,
    );
  }

  factory DownloadState.initial() => const DownloadState();

  DownloadState loading() {
    return copyWith(isLoading: true, error: null);
  }

  DownloadState withError(String errorMessage) {
    return copyWith(
        error: errorMessage, isLoading: false, isDownloading: false);
  }

  @override
  List<Object?> get props => [
        isDownloading,
        progress,
        totalRecords,
        downloadedRecords,
        displayedRecords,
        isLoading,
        hasReachedMax,
        error,
        apiName,
      ];
}
