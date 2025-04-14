import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LastUpdateWidget extends StatefulWidget {
  final String userId;

  const LastUpdateWidget({super.key, required this.userId});

  @override
  _LastUpdateWidgetState createState() => _LastUpdateWidgetState();
}

class _LastUpdateWidgetState extends State<LastUpdateWidget> {
  late Future<Map<String, dynamic>> _lastUpdateFuture;

  @override
  void initState() {
    super.initState();
    _lastUpdateFuture = _getLastUpdate();
  }

  Future<Map<String, dynamic>> _getLastUpdate() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (!userDoc.exists) {
      return {'status': 'no_data', 'message': 'No user data found'};
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    final lastUpdated = userData['lastUpdated'];

    // Check healthRecords subcollection
    final healthRecordsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('healthRecords')
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    // Check medications subcollection
    final medicationsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('medications')
        .orderBy('lastUpdated', descending: true)
        .limit(1)
        .get();

    DateTime? latestDate;
    String latestCollection = 'personal';
    Map<String, dynamic> latestData = userData;

    // Parse user lastUpdated if exists
    if (lastUpdated != null) {
      latestDate = (lastUpdated as Timestamp).toDate();
    }

    // Check healthRecords
    if (healthRecordsSnapshot.docs.isNotEmpty) {
      final record = healthRecordsSnapshot.docs.first;
      final recordDate = (record.data()['date'] as Timestamp).toDate();
      if (latestDate == null || recordDate.isAfter(latestDate)) {
        latestDate = recordDate;
        latestCollection = 'healthRecords';
        latestData = record.data();
      }
    }

    // Check medications
    if (medicationsSnapshot.docs.isNotEmpty) {
      final medication = medicationsSnapshot.docs.first;
      final medDate = (medication.data()['lastUpdated'] as Timestamp).toDate();
      if (latestDate == null || medDate.isAfter(latestDate)) {
        latestDate = medDate;
        latestCollection = 'medications';
        latestData = medication.data();
      }
    }

    if (latestDate == null) {
      return {'status': 'no_data', 'message': 'Add data'};
    }

    return {
      'status': 'has_data',
      'date': latestDate,
      'collection': latestCollection,
      'data': latestData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _lastUpdateFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final data = snapshot.data!;

        if (data['status'] == 'no_data') {
          return Text(
            data['message'],
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          );
        }

        final date = data['date'] as DateTime;
        final collection = data['collection'] as String;
        final formattedDate = DateFormat('MMM d, y - h:mm a').format(date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: $formattedDate',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              '(${collection == 'personal' ? 'Profile' : collection})',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }
}