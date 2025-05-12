import 'dart:async';
import 'dart:isolate';

import 'package:dio/dio.dart';

import '../models/user_record.dart';

/// Enum for different API sources
enum ApiSource { jsonPlaceholder, randomUser, reqres }

/// Isolate function to fetch and process real data from an API
Future<void> _fetchAndProcessData(Map<String, dynamic> params) async {
  final SendPort sendPort = params['sendPort'];
  final int targetCount = params['total'];
  final int batchSize = params['batchSize'];
  final ApiSource apiSource = params['apiSource'] ?? ApiSource.jsonPlaceholder;

  final dio = Dio();
  int processed = 0;
  int page = 1;

  try {
    // Fetch initial data based on selected API
    List<dynamic> initialUsers = [];

    switch (apiSource) {
      case ApiSource.jsonPlaceholder:
        final response =
            await dio.get('https://jsonplaceholder.typicode.com/users');
        initialUsers = response.data;
        break;

      case ApiSource.randomUser:
        // Random User API returns users per request
        final response = await dio.get('https://randomuser.me/api/?results=20');
        initialUsers = response.data['results'];
        break;

      case ApiSource.reqres:
        final response =
            await dio.get('https://reqres.in/api/users?per_page=12');
        initialUsers = response.data['data'];
        break;
    }

    if (initialUsers.isEmpty) {
      throw Exception('No data received from API');
    }

    // Process users to reach the target count
    while (processed < targetCount) {
      final int currentBatchSize = (processed + batchSize > targetCount)
          ? (targetCount - processed)
          : batchSize;

      // Create a batch of records based on real API data
      List<UserRecord> batch = [];

      for (int i = 0; i < currentBatchSize; i++) {
        // Get user from the initial data, cycling through them
        final user = initialUsers[(processed + i) % initialUsers.length];

        // Create a record with real data from API based on the API source
        final UserRecord record = UserRecord()
          ..userId = 'user_${processed + i}'
          ..createdAt = DateTime.now();

        switch (apiSource) {
          case ApiSource.jsonPlaceholder:
            record.name = user['name'];
            record.email = user['email'];
            break;

          case ApiSource.randomUser:
            final name = user['name'];
            record.name = '${name['first']} ${name['last']}';
            record.email = user['email'];
            break;

          case ApiSource.reqres:
            record.name = '${user['first_name']} ${user['last_name']}';
            record.email = user['email'];
            break;
        }

        batch.add(record);
      }

      // Send progress and batch data back to main isolate
      processed += currentBatchSize;
      sendPort.send({
        'progress': processed / targetCount,
        'batch': batch,
      });

      // Add a small delay to simulate network latency for large datasets
      await Future.delayed(const Duration(milliseconds: 100));
      page++;

      // Fetch more data if needed for variety
      if (page > 5 && page % 5 == 0 && apiSource == ApiSource.randomUser) {
        try {
          final response =
              await dio.get('https://randomuser.me/api/?results=20');
          final newUsers = response.data['results'];
          if (newUsers.isNotEmpty) {
            initialUsers = [...initialUsers, ...newUsers];
          }
        } catch (_) {
          // Continue with existing users if additional fetch fails
        }
      }
    }
  } catch (e) {
    // Send error information back to main isolate
    sendPort.send({'error': e.toString()});
  }
}

class DataDownloadService {
  Future<Stream<Map<String, dynamic>>> downloadLargeDataset({
    required int totalRecords,
    int batchSize = 500,
    ApiSource apiSource = ApiSource.jsonPlaceholder,
  }) async {
    final controller = StreamController<Map<String, dynamic>>();
    final receivePort = ReceivePort();

    // Start isolate with real data fetching
    await Isolate.spawn(
      _fetchAndProcessData,
      {
        'sendPort': receivePort.sendPort,
        'total': totalRecords,
        'batchSize': batchSize,
        'apiSource': apiSource,
      },
    ); // Listen to messages from isolate
    receivePort.listen(
      (dynamic data) {
        if (data is Map<String, dynamic>) {
          // Check for errors first
          if (data.containsKey('error')) {
            controller.addError(data['error']);
            receivePort.close();
            controller.close();
            return;
          }

          // Add data to stream
          controller.add(data);

          // Close the stream when download is complete
          if (data['progress'] >= 1.0) {
            receivePort.close();
            controller.close();
          }
        }
      },
      onError: (error) {
        controller.addError('Isolate error: $error');
        receivePort.close();
        controller.close();
      },
      onDone: () {
        if (!controller.isClosed) {
          controller.close();
        }
      },
    );

    return controller.stream;
  }

  /// Test connection to specified API
  Future<bool> testApiConnection(
      {ApiSource source = ApiSource.jsonPlaceholder}) async {
    try {
      final dio = Dio();
      String url = '';

      switch (source) {
        case ApiSource.jsonPlaceholder:
          url = 'https://jsonplaceholder.typicode.com/users';
          break;
        case ApiSource.randomUser:
          url = 'https://randomuser.me/api/?results=1';
          break;
        case ApiSource.reqres:
          url = 'https://reqres.in/api/users?per_page=1';
          break;
      }

      final response = await dio.get(url);
      return response.statusCode == 200;
    } catch (e) {
      print('API test connection error: $e');
      return false;
    }
  }

  /// Test all APIs and return their status
  Future<Map<ApiSource, bool>> testAllApis() async {
    final Map<ApiSource, bool> results = {};

    for (final source in ApiSource.values) {
      results[source] = await testApiConnection(source: source);
    }

    return results;
  }

  /// Get the API name for display
  String getApiName(ApiSource source) {
    switch (source) {
      case ApiSource.jsonPlaceholder:
        return 'JSONPlaceholder';
      case ApiSource.randomUser:
        return 'Random User API';
      case ApiSource.reqres:
        return 'Reqres API';
    }
  }
}
