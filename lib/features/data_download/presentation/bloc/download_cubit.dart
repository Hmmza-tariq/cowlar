import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_record.dart';
import '../../data/services/data_download_service.dart';
import '../../data/services/isar_service.dart';
import 'download_event.dart';
import 'download_state.dart';

class DownloadCubit extends Bloc<DownloadEvent, DownloadState> {
  final DataDownloadService _downloadService;
  final IsarService _isarService;
  static const int pageSize = 50;

  DownloadCubit({
    required DataDownloadService downloadService,
    required IsarService isarService,
  })  : _downloadService = downloadService,
        _isarService = isarService,
        super(DownloadState.initial()) {
    on<DownloadStartEvent>(_handleDownloadStart);
    on<DownloadProgressEvent>(_handleDownloadProgress);
    on<DownloadCompleteEvent>(_handleDownloadComplete);
    on<LoadRecordsEvent>(_handleLoadRecords);
    on<LoadMoreRecordsEvent>(_handleLoadMoreRecords);
    on<ClearRecordsEvent>(_handleClearRecords);
  }

  Future<int> getRecordCount() async {
    return await _isarService.getRecordCount();
  }

  Future<void> _handleDownloadStart(
      DownloadStartEvent event, Emitter<DownloadState> emit) async {
    if (state.isDownloading) return;

    emit(state.copyWith(
      isDownloading: true,
      progress: 0.0,
      totalRecords: event.recordCount,
      downloadedRecords: 0,
    ));

    try {
      final stream = await _downloadService.downloadLargeDataset(
        totalRecords: event.recordCount,
      );

      await for (final data in stream) {
        final double progress = data['progress'];
        final List<UserRecord> batch = data['batch'];

        // Save batch to database
        await _isarService.saveRecords(batch);

        add(DownloadProgressEvent(
          progress: progress,
          batch: batch,
        ));
      }

      add(const DownloadCompleteEvent());
    } catch (e) {
      emit(state.withError('Download error: ${e.toString()}'));
    }
  }

  void _handleDownloadProgress(
      DownloadProgressEvent event, Emitter<DownloadState> emit) {
    emit(state.copyWith(
      progress: event.progress,
      downloadedRecords: state.downloadedRecords + event.batch.length,
    ));
  }

  Future<void> _handleDownloadComplete(
      DownloadCompleteEvent event, Emitter<DownloadState> emit) async {
    emit(state.copyWith(
      isDownloading: false,
      progress: 1.0,
    ));

    // Load initial records
    add(const LoadRecordsEvent());
  }

  Future<void> _handleLoadRecords(
      LoadRecordsEvent event, Emitter<DownloadState> emit) async {
    emit(state.loading());

    try {
      final records = await _isarService.getRecords(limit: pageSize);
      final count = await _isarService.getRecordCount();

      emit(state.copyWith(
        displayedRecords: records,
        totalRecords: count,
        isLoading: false,
        hasReachedMax: records.length < pageSize,
      ));
    } catch (e) {
      emit(state.withError('Error loading records: ${e.toString()}'));
    }
  }

  Future<void> _handleLoadMoreRecords(
      LoadMoreRecordsEvent event, Emitter<DownloadState> emit) async {
    if (state.isLoading || state.hasReachedMax) return;

    emit(state.copyWith(isLoading: true));

    try {
      final currentRecords = state.displayedRecords;
      final moreRecords = await _isarService.getRecords(
        offset: currentRecords.length,
        limit: pageSize,
      );

      if (moreRecords.isEmpty) {
        emit(state.copyWith(isLoading: false, hasReachedMax: true));
      } else {
        emit(state.copyWith(
          displayedRecords: [...currentRecords, ...moreRecords],
          isLoading: false,
          hasReachedMax: moreRecords.length < pageSize,
        ));
      }
    } catch (e) {
      emit(state.withError('Error loading more records: ${e.toString()}'));
    }
  }

  Future<void> _handleClearRecords(
      ClearRecordsEvent event, Emitter<DownloadState> emit) async {
    emit(state.loading());

    try {
      await _isarService.clearRecords();
      emit(DownloadState.initial());
    } catch (e) {
      emit(state.withError('Error clearing records: ${e.toString()}'));
    }
  }
}
