import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/download_cubit.dart';
import '../bloc/download_event.dart';
import '../../data/models/user_record.dart';

class RecordsList extends StatefulWidget {
  final List<UserRecord> records;
  final bool isLoading;
  final bool hasReachedMax;

  const RecordsList({
    super.key,
    required this.records,
    required this.isLoading,
    required this.hasReachedMax,
  });

  @override
  State<RecordsList> createState() => _RecordsListState();
}

class _RecordsListState extends State<RecordsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<DownloadCubit>().add(const LoadMoreRecordsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger when within 200 pixels of the bottom
    return currentScroll >= (maxScroll - 200);
  }

  // Format date for better readability
  String _formatDate(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy - HH:mm');
    return formatter.format(date);
  }

  // Helper method to build info rows in the expanded tile
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.blue.shade800),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) {
      return const Center(
        child: Text('No records available'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.records.length + (widget.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.records.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final record = widget.records[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: ExpansionTile(
            leading: record.profileImage != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(record.profileImage!),
                    onBackgroundImageError: (_, __) {
                      // Fallback for image loading errors
                    },
                  )
                : CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.blue.shade800,
                    child: Text(
                      (index + 1).toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
            title: Text(
              record.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(record.email),
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (record.phone != null)
                      _buildInfoRow(Icons.phone, 'Phone', record.phone!),
                    if (record.location != null)
                      _buildInfoRow(
                          Icons.location_on, 'Location', record.location!),
                    if (record.age != null)
                      _buildInfoRow(Icons.cake, 'Age', record.age.toString()),
                    if (record.gender != null)
                      _buildInfoRow(Icons.person, 'Gender', record.gender!),
                    if (record.nationality != null)
                      _buildInfoRow(
                          Icons.flag, 'Nationality', record.nationality!),
                    _buildInfoRow(Icons.calendar_today, 'Created',
                        _formatDate(record.createdAt)),
                    _buildInfoRow(Icons.numbers, 'User ID', record.userId),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
