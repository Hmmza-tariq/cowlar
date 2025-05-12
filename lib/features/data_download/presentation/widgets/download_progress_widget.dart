import 'package:flutter/material.dart';

class DownloadProgressWidget extends StatelessWidget {
  final double progress;
  final int downloadedRecords;
  final int totalRecords;

  const DownloadProgressWidget({
    super.key,
    required this.progress,
    required this.downloadedRecords,
    required this.totalRecords,
  });
  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();
    final isCompleted = percentage >= 100;

    // Calculate download speed and estimated time - just for show
    final recordsPerSecond = downloadedRecords > 0
        ? (downloadedRecords / (percentage / 10)).round()
        : 0;
    final remainingSeconds = recordsPerSecond > 0
        ? (totalRecords - downloadedRecords) / recordsPerSecond
        : 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.downloading,
                      color: isCompleted ? Colors.green : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCompleted ? 'Download Complete' : 'Downloading Data...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green : Colors.blue,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: isCompleted ? Colors.green : Colors.blue,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$downloadedRecords of $totalRecords records',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (!isCompleted && percentage > 0)
                  Text(
                    'Est. ${remainingSeconds.round()} seconds left',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
