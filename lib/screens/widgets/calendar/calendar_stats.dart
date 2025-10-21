// widgets/calendar/calendar_stats.dart

import 'package:flutter/material.dart';
import '../../../models/availability_checker_model.dart';
import '../../../utils/calendar_constants.dart';
import '../../../utils/calendar_helpers.dart';

/// Monthly statistics widget
class MonthlyStatsWidget extends StatelessWidget {
  final Map<String, List<ScheduleItem>> monthData;
  final DeviceType deviceType;
  final bool showResourceBreakdown;

  const MonthlyStatsWidget({
    super.key,
    required this.monthData,
    required this.deviceType,
    this.showResourceBreakdown = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    if (monthData.isEmpty) return Container();

    final stats = CalendarHelpers.calculateMonthlyStats(monthData);

    return Container(
      margin: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
      padding: EdgeInsets.all(isMobile ? 16 : isTablet ? 18 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: CalendarColors.primaryMaroon.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Statistics',
            style: TextStyle(
              fontSize: isMobile ? 14 : isTablet ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: CalendarColors.darkMaroon,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // Main stat cards
          Row(
            children: [
              _StatCard(
                label: 'Total\nReservations',
                value: stats['totalReservations'].toString(),
                color: CalendarColors.primaryMaroon,
                deviceType: deviceType,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              _StatCard(
                label: 'Busy\nDays',
                value: stats['busyDays'].toString(),
                color: Colors.orange,
                deviceType: deviceType,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              _StatCard(
                label: showResourceBreakdown ? 'Resource\nTypes' : 'Unique\nStatuses',
                value: showResourceBreakdown
                    ? stats['uniqueResources'].toString()
                    : stats['uniqueStatuses'].toString(),
                color: Colors.purple,
                deviceType: deviceType,
              ),
            ],
          ),

          // Status breakdown (including completed)
          if (stats['statusCounts'].isNotEmpty) ...[
            SizedBox(height: isMobile ? 14 : 18),
            _StatusBreakdown(
              statusCounts: stats['statusCounts'],
              totalReservations: stats['totalReservations'],
              deviceType: deviceType,
            ),
          ],

          // Resource breakdown (if enabled)
          if (showResourceBreakdown && stats['resourceCounts'].isNotEmpty) ...[
            SizedBox(height: isMobile ? 14 : 18),
            _ResourceBreakdown(
              resourceCounts: stats['resourceCounts'],
              totalReservations: stats['totalReservations'],
              deviceType: deviceType,
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual stat card
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final DeviceType deviceType;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 10 : 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.12), color.withOpacity(0.06)],
          ),
          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 18 : isTablet ? 20 : 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: isMobile ? 4 : 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 10 : 11,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status breakdown section (including completed)
class _StatusBreakdown extends StatelessWidget {
  final Map<String, int> statusCounts;
  final int totalReservations;
  final DeviceType deviceType;

  const _StatusBreakdown({
    required this.statusCounts,
    required this.totalReservations,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Breakdown',
          style: TextStyle(
            fontSize: isMobile ? 13 : isTablet ? 14 : 15,
            fontWeight: FontWeight.bold,
            color: CalendarColors.darkMaroon,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 10),
        Wrap(
          spacing: isMobile ? 8 : 10,
          runSpacing: isMobile ? 6 : 8,
          children: statusCounts.entries.map((entry) {
            final percentage = (entry.value / totalReservations * 100).round();
            final color = CalendarColors.getStatusColor(entry.key);
            return _BreakdownChip(
              label: '${CalendarText.getStatusDisplayText(entry.key)}: ${entry.value} ($percentage%)',
              color: color,
              deviceType: deviceType,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Resource breakdown section
class _ResourceBreakdown extends StatelessWidget {
  final Map<String, int> resourceCounts;
  final int totalReservations;
  final DeviceType deviceType;

  const _ResourceBreakdown({
    required this.resourceCounts,
    required this.totalReservations,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resource Usage',
          style: TextStyle(
            fontSize: isMobile ? 13 : isTablet ? 14 : 15,
            fontWeight: FontWeight.bold,
            color: CalendarColors.darkMaroon,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 10),
        Wrap(
          spacing: isMobile ? 8 : 10,
          runSpacing: isMobile ? 6 : 8,
          children: resourceCounts.entries.map((entry) {
            final percentage = (entry.value / totalReservations * 100).round();
            final color = CalendarColors.getResourceColor(entry.key);
            return _BreakdownChip(
              label: '${entry.key}: ${entry.value} ($percentage%)',
              color: color,
              deviceType: deviceType,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Breakdown chip for displaying counts
class _BreakdownChip extends StatelessWidget {
  final String label;
  final Color color;
  final DeviceType deviceType;

  const _BreakdownChip({
    required this.label,
    required this.color,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 12,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isMobile ? 10 : isTablet ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}