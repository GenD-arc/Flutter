import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/availability_checker_model.dart';

class ViewScheduleScreen extends StatelessWidget {
  final List<ScheduleItem> schedule;

  const ViewScheduleScreen({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  // Enhanced Color Palette
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color cardBackground = Color(0xFFFFFBFF);

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'approved':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case 'rejected':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return schedule.isEmpty
        ? Container(
            padding: EdgeInsets.all(isMobile ? 32 : 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: isMobile ? 64 : 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No Reservations',
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.w600,
                    color: darkMaroon,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This resource has no upcoming reservations',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            itemCount: schedule.length,
            itemBuilder: (context, index) {
              final item = schedule[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: primaryMaroon.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: isMobile ? 16 : 18, color: primaryMaroon),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.reservedBy,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              color: darkMaroon,
                            ),
                          ),
                        ),
                        _buildStatusBadge(item.status),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      item.purpose,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: darkMaroon,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: isMobile ? 16 : 18, color: Colors.grey[600]),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${DateFormat('MMM dd, yyyy HH:mm').format(item.dateFrom.toUtc().add(Duration(hours: 8)))} - ${DateFormat('MMM dd, yyyy HH:mm').format(item.dateTo.toUtc().add(Duration(hours: 8)))}',
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
  }
}