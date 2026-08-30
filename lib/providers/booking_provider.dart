import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class BookingState {
  const BookingState({this.date, this.time});

  final DateTime? date;
  final TimeOfDay? time;

  DateTime? get scheduledFor {
    if (date == null || time == null) return null;
    return DateTime(
      date!.year,
      date!.month,
      date!.day,
      time!.hour,
      time!.minute,
    );
  }

  bool get isValid =>
      scheduledFor != null && scheduledFor!.isAfter(DateTime.now());

  BookingState copyWith({DateTime? date, TimeOfDay? time, bool clear = false}) {
    if (clear) return const BookingState();
    return BookingState(date: date ?? this.date, time: time ?? this.time);
  }
}

class BookingNotifier extends Notifier<BookingState> {
  @override
  BookingState build() => const BookingState();

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setTime(TimeOfDay time) {
    state = state.copyWith(time: time);
  }

  void reset() {
    state = const BookingState();
  }
}

final bookingProvider = NotifierProvider<BookingNotifier, BookingState>(
  BookingNotifier.new,
);
