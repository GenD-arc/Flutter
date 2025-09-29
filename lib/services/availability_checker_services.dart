import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/availability_checker_model.dart';

class AvailabilityService {
  // Check availability method
  Future<Map<String, dynamic>> checkAvailability({
    required String resourceId,
    required DateTime? dateFrom,
    required DateTime? dateTo,
  }) async {
    if (dateFrom == null || dateTo == null) {
      throw Exception('Please select both start and end dates');
    }

    if (dateFrom.isAfter(dateTo)) {
      throw Exception('End date must be after start date');
    }

    if (dateFrom.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      throw Exception('Start date cannot be in the past');
    }

    try {
      final url = 'http://localhost:4000/api/resources/availability/$resourceId?date_from=${dateFrom.toIso8601String()}&date_to=${dateTo.toIso8601String()}';
      print('🌐 API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Decoded data: $data');
        print('🔍 Is available: ${data['is_available']}');
        print('⚠️ Conflicts array: ${data['conflicts']}');
        print('ℹ️ Inactive reservations: ${data['inactive_reservations']}');

        // Combine conflicts and inactive reservations for complete view
        final allReservations = <Conflict>[];
        
        // Add conflicts (approved/pending)
        if (data['conflicts'] != null) {
          allReservations.addAll((data['conflicts'] as List)
              .map((conflict) => Conflict.fromJson(conflict))
              .toList());
        }
        
        // Add inactive reservations (cancelled/rejected) for information
        if (data['inactive_reservations'] != null) {
          allReservations.addAll((data['inactive_reservations'] as List)
              .map((reservation) => Conflict.fromJson(reservation))
              .toList());
        }

        return {
          'isAvailable': data['is_available'] as bool,
          'conflicts': allReservations,
          'message': data['message'],
          'additionalInfo': data['additional_info'],
        };
      } else {
        final errorData = json.decode(response.body);
        print('❌ Error response: $errorData');
        throw Exception(errorData['error'] ?? 'Failed to check availability');
      }
    } catch (e) {
      print('💥 Exception caught: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Load schedule method
  Future<List<ScheduleItem>> loadSchedule(String resourceId) async {
    try {
      final url = 'http://localhost:4000/api/resources/availability/schedule/$resourceId';
      print('🌐 Schedule API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📡 Schedule response status: ${response.statusCode}');
      print('📄 Schedule raw response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Schedule decoded data: $data');
        
        final reservations = data['reservations'] as List?;
        if (reservations == null || reservations.isEmpty) {
          print('📅 No reservations found');
          return [];
        }
        
        print('📝 Reservations length: ${reservations.length}');
        final scheduleItems = <ScheduleItem>[];
        
        for (int i = 0; i < reservations.length; i++) {
          final reservationData = reservations[i];
          print('🔍 Reservation $i: $reservationData');
          try {
            final item = ScheduleItem.fromJson(reservationData);
            scheduleItems.add(item);
            print('✅ Created ScheduleItem: ${item.purpose}, ${item.dateFrom} to ${item.dateTo}, status: ${item.status}');
          } catch (e) {
            print('❌ Error creating ScheduleItem at index $i: $e');
            continue;
          }
        }
        
        print('✅ Created ${scheduleItems.length} valid ScheduleItems');
        return scheduleItems;
      } else {
        final errorData = json.decode(response.body);
        print('❌ Schedule error response: $errorData');
        throw Exception(errorData['error'] ?? 'Failed to load schedule');
      }
    } catch (e) {
      print('💥 Schedule exception: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // NEW: Load calendar data for a specific month
  Future<Map<String, List<ScheduleItem>>> loadCalendarData(String resourceId, String month) async {
    try {
      final url = 'http://localhost:4000/api/resources/availability/calendar/$resourceId?month=$month';
      print('🌐 Calendar API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📡 Calendar response status: ${response.statusCode}');
      print('📄 Calendar raw response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Calendar decoded data: $data');
        
        final calendarData = data['calendar_data'] as Map<String, dynamic>?;
        if (calendarData == null || calendarData.isEmpty) {
          print('📅 No calendar data found for month: $month');
          return {};
        }
        
        final processedCalendarData = <String, List<ScheduleItem>>{};
        
        calendarData.forEach((dateKey, reservationsList) {
          final scheduleItems = <ScheduleItem>[];
          
          if (reservationsList is List) {
            for (final reservationData in reservationsList) {
              try {
                final item = ScheduleItem.fromJson(reservationData);
                scheduleItems.add(item);
                print('✅ Added calendar item for $dateKey: ${item.purpose}, status: ${item.status}');
              } catch (e) {
                print('❌ Error creating calendar ScheduleItem for $dateKey: $e');
                continue;
              }
            }
          }
          
          if (scheduleItems.isNotEmpty) {
            processedCalendarData[dateKey] = scheduleItems;
          }
        });
        
        print('✅ Processed calendar data for ${processedCalendarData.length} dates');
        return processedCalendarData;
      } else {
        final errorData = json.decode(response.body);
        print('❌ Calendar error response: $errorData');
        throw Exception(errorData['error'] ?? 'Failed to load calendar data');
      }
    } catch (e) {
      print('💥 Calendar exception: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // NEW: Load schedule for a specific month (optimized for calendar view)
  Future<List<ScheduleItem>> loadScheduleForMonth(String resourceId, String month) async {
    try {
      final url = 'http://localhost:4000/api/resources/availability/schedule/$resourceId?month=$month';
      print('🌐 Monthly Schedule API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📡 Monthly schedule response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reservations = data['reservations'] as List?;
        
        if (reservations == null || reservations.isEmpty) {
          print('📅 No reservations found for month: $month');
          return [];
        }
        
        final scheduleItems = <ScheduleItem>[];
        for (final reservationData in reservations) {
          try {
            final item = ScheduleItem.fromJson(reservationData);
            scheduleItems.add(item);
          } catch (e) {
            print('❌ Error creating monthly ScheduleItem: $e');
            continue;
          }
        }
        
        print('✅ Loaded ${scheduleItems.length} items for month: $month');
        return scheduleItems;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load monthly schedule');
      }
    } catch (e) {
      print('💥 Monthly schedule exception: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }
}