import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/download_cubit.dart';
import '../bloc/download_event.dart';
import '../bloc/download_state.dart';
import '../widgets/download_progress_widget.dart';
import '../widgets/records_list.dart';

class DataDownloadPage extends StatefulWidget {
  const DataDownloadPage({super.key});

  @override
  State<DataDownloadPage> createState() => _DataDownloadPageState();
}

class _DataDownloadPageState extends State<DataDownloadPage> {
  @override
  void initState() {
    super.initState();
    // Check for existing records on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DownloadCubit>().add(const LoadRecordsEvent());
    });
  }
  // No helper methods needed for single data source

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Download'),
        actions: [
          BlocBuilder<DownloadCubit, DownloadState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.delete),
                onPressed: state.isDownloading
                    ? null
                    : () {
                        context
                            .read<DownloadCubit>()
                            .add(const ClearRecordsEvent());
                      },
                tooltip: 'Clear Records',
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<DownloadCubit, DownloadState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                if (!state.isDownloading && state.displayedRecords.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.cloud_download_outlined,
                              color: Colors.blue, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'No Data Downloaded Yet',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap the "Start Download" button below to fetch '
                            'a comprehensive dataset of 50,000+ user records.',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'The data includes rich user profiles with names, contacts, '
                            'locations, ages, and more. Perfect for testing pagination '
                            'and data visualization.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ), // Download Progress
                if (state.isDownloading)
                  Column(
                    children: [
                      Card(
                        color: const Color(0xFFE3F2FD), // Light blue color
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.cloud_download,
                                  color: Colors.blue),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 200,
                                child: Text(
                                  'Downloading from ${state.apiName}',
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DownloadProgressWidget(
                        progress: state.progress,
                        downloadedRecords: state.downloadedRecords,
                        totalRecords: state.totalRecords,
                      ),
                    ],
                  ),

                // Data Stats
                if (!state.isDownloading && state.displayedRecords.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Data Stats',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Data Source: ${state.apiName}',
                              style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text('Total Records: ${state.totalRecords}'),
                          Text(
                              'Displayed: ${state.displayedRecords.length} records'),
                          Text(
                              'Scroll down to load more (${DownloadCubit.pageSize} at a time)'),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Records List
                if (state.displayedRecords.isNotEmpty)
                  Expanded(
                    child: RecordsList(
                      records: state.displayedRecords,
                      isLoading: state.isLoading,
                      hasReachedMax: state.hasReachedMax,
                    ),
                  ), // API Selection and Download Button

                if (!state.isDownloading && state.displayedRecords.isEmpty)
                  Column(
                    children: [
                      // Single Data Source Card
                      const Text(
                        'Download Comprehensive Dataset:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.dataset,
                                size: 48,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Unified User Database',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '50,000+ unique user records with comprehensive profile data',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () {
                                  context.read<DownloadCubit>().add(
                                        const DownloadStartEvent(
                                          recordCount: 50000,
                                        ),
                                      );
                                },
                                icon: const Icon(Icons.cloud_download),
                                label: const Text('Start Download'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
