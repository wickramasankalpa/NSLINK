import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:library_booking_app/backend/models/booking.dart';

void main() {
  group('Booking Model Tests', () {
    final DateTime now = DateTime.now();
    final DateTime date = DateTime(now.year, now.month, now.day);

    test('should create Booking instance with valid data', () {
      final booking = Booking(
          id: '123',
          roomId: 'room1',
          studentId: 'student1',
          date: date,
          startTime: DateTime(now.year, now.month, now.day, 10, 0),
          endTime: DateTime(now.year, now.month, now.day, 11, 0),
          status: 'pending');

      expect(booking.id, '123');
      expect(booking.roomId, 'room1');
      expect(booking.studentId, 'student1');
      expect(booking.status, 'pending');
    });

    test('should convert Booking to Map correctly', () {
      final startTime = DateTime(now.year, now.month, now.day, 10, 0);
      final endTime = DateTime(now.year, now.month, now.day, 11, 0);

      final booking = Booking(
          id: '123',
          roomId: 'room1',
          studentId: 'student1',
          date: date,
          startTime: startTime,
          endTime: endTime,
          status: 'pending');

      final map = booking.toMap();

      expect(map['id'], '123');
      expect(map['roomId'], 'room1');
      expect(map['studentId'], 'student1');
      expect(map['status'], 'pending');
      expect(map['date'] is Timestamp, true);
      expect(map['startTime'] is Timestamp, true);
      expect(map['endTime'] is Timestamp, true);
    });

    test('should create Booking from Map correctly', () {
      final startTime = DateTime(now.year, now.month, now.day, 10, 0);
      final endTime = DateTime(now.year, now.month, now.day, 11, 0);

      final map = {
        'id': '123',
        'roomId': 'room1',
        'studentId': 'student1',
        'date': Timestamp.fromDate(date),
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'status': 'pending'
      };

      final booking = Booking.fromMap(map);

      expect(booking.id, '123');
      expect(booking.roomId, 'room1');
      expect(booking.studentId, 'student1');
      expect(booking.date.year, date.year);
      expect(booking.date.month, date.month);
      expect(booking.date.day, date.day);
      expect(booking.startTime.hour, 10);
      expect(booking.endTime.hour, 11);
      expect(booking.status, 'pending');
    });

    test('should detect overlapping bookings correctly', () {
      final booking1 = Booking(
          id: '123',
          roomId: 'room1',
          studentId: 'student1',
          date: date,
          startTime: DateTime(now.year, now.month, now.day, 10, 0),
          endTime: DateTime(now.year, now.month, now.day, 12, 0),
          status: 'pending');

      final booking2 = Booking(
          id: '124',
          roomId: 'room1',
          studentId: 'student2',
          date: date,
          startTime: DateTime(now.year, now.month, now.day, 11, 0),
          endTime: DateTime(now.year, now.month, now.day, 13, 0),
          status: 'pending');

      final booking3 = Booking(
          id: '125',
          roomId: 'room1',
          studentId: 'student3',
          date: date,
          startTime: DateTime(now.year, now.month, now.day, 13, 0),
          endTime: DateTime(now.year, now.month, now.day, 14, 0),
          status: 'pending');

      expect(booking1.overlaps(booking2), true);
      expect(booking1.overlaps(booking3), false);
      expect(booking2.overlaps(booking3), false);
    });

    test('should not detect overlap for different rooms', () {
      final booking1 = Booking(
          id: '123',
          roomId: 'room1',
          studentId: 'student1',
          date: date,
          startTime: DateTime(now.year, now.month, now.day, 10, 0),
          endTime: DateTime(now.year, now.month, now.day, 12, 0),
          status: 'pending');

      final booking2 = Booking(
          id: '124',
          roomId: 'room2',
          studentId: 'student2',
          date: date,
          startTime: DateTime(now.year, now.month, now.day, 11, 0),
          endTime: DateTime(now.year, now.month, now.day, 13, 0),
          status: 'pending');

      expect(booking1.overlaps(booking2), false);
    });

    test('should generate correct string representation', () {
      final booking = Booking(
          id: '123',
          roomId: 'room1',
          studentId: 'student1',
          date: date,
          startTime: DateTime(now.year, now.month, now.day, 10, 0),
          endTime: DateTime(now.year, now.month, now.day, 11, 0),
          status: 'pending');

      final expectedDateStr = date.toString().split(' ')[0];
      expect(booking.toString(),
          'Booking: Room room1, Date: $expectedDateStr, Time: 10:0-11:0');
    });
  });
}
