// widgets/calendar/calendar_legends.dart

import 'package:flutter/material.dart';
import '../../../utils/calendar_constants.dart';
import '../../../utils/calendar_helpers.dart';

/// Status legend widget
class StatusLegend extends StatelessWidget {
  final DeviceType deviceType;

  const StatusLegend({
    super.key,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : isTablet ? 16 : 20,
      ),
      padding: EdgeInsets.all(isMobile ? 14 : isTablet ? 16 : 18),
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
            'Status Legend',
            style: TextStyle(
              fontSize: isMobile ? 14 : isTablet ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: CalendarColors.darkMaroon,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: isMobile ? 10 : 14),
          Wrap(
            spacing: isMobile ? 12 : 18,
            runSpacing: isMobile ? 6 : 10,
            children: CalendarColors.statusColors.entries.map((entry) {
              return _LegendItem(
                label: CalendarText.getStatusDisplayText(entry.key),
                color: entry.value,
                isMobile: isMobile,
                isTablet: isTablet,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Resource type legend widget
class ResourceLegend extends StatelessWidget {
  final DeviceType deviceType;

  const ResourceLegend({
    super.key,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : isTablet ? 16 : 20,
      ),
      padding: EdgeInsets.all(isMobile ? 14 : isTablet ? 16 : 18),
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
            'Resource Types',
            style: TextStyle(
              fontSize: isMobile ? 14 : isTablet ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: CalendarColors.darkMaroon,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: isMobile ? 10 : 14),
          Wrap(
            spacing: isMobile ? 12 : 18,
            runSpacing: isMobile ? 6 : 10,
            children: CalendarColors.resourceColors.entries.map((entry) {
              return _LegendItem(
                label: entry.key,
                color: entry.value,
                isMobile: isMobile,
                isTablet: isTablet,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Availability legend with popup dialog
class AvailabilityLegend extends StatelessWidget {
  final DeviceType deviceType;

  const AvailabilityLegend({
    super.key,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      child: Row(
        children: [
          Text(
            'Availability:',
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          _AvailabilityLegendButton(deviceType: deviceType),
        ],
      ),
    );
  }
}

/// Button to show availability legend popup
class _AvailabilityLegendButton extends StatelessWidget {
  final DeviceType deviceType;

  const _AvailabilityLegendButton({required this.deviceType});

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showAvailabilityDialog(context),
        borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 12,
            vertical: isMobile ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: CalendarColors.primaryMaroon.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
            border: Border.all(
              color: CalendarColors.primaryMaroon.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isMobile ? 50 : 60,
                height: isMobile ? 3 : 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CalendarColors.availabilityLevelColors[0]!,
                      CalendarColors.availabilityLevelColors[2]!,
                      CalendarColors.availabilityLevelColors[4]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: isMobile ? 4 : 6),
              Icon(
                Icons.info_outline,
                size: isMobile ? 12 : 14,
                color: CalendarColors.primaryMaroon,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvailabilityDialog(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Availability Legend',
          style: TextStyle(
            fontSize: isMobile ? 16 : isTablet ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AvailabilityLegendItem(
              label: CalendarHelpers.getAvailabilityDescription(0),
              color: CalendarColors.availabilityLevelColors[0]!,
              opacity: 0.1,
              isMobile: isMobile,
            ),
            _AvailabilityLegendItem(
              label: CalendarHelpers.getAvailabilityDescription(1),
              color: CalendarColors.availabilityLevelColors[1]!,
              opacity: 0.3,
              isMobile: isMobile,
            ),
            _AvailabilityLegendItem(
              label: CalendarHelpers.getAvailabilityDescription(2),
              color: CalendarColors.availabilityLevelColors[2]!,
              opacity: 0.5,
              isMobile: isMobile,
            ),
            _AvailabilityLegendItem(
              label: CalendarHelpers.getAvailabilityDescription(3),
              color: CalendarColors.availabilityLevelColors[3]!,
              opacity: 0.7,
              isMobile: isMobile,
            ),
            _AvailabilityLegendItem(
              label: CalendarHelpers.getAvailabilityDescription(4),
              color: CalendarColors.availabilityLevelColors[4]!,
              opacity: 0.9,
              isMobile: isMobile,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual legend item
class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final bool isMobile;
  final bool isTablet;

  const _LegendItem({
    required this.label,
    required this.color,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isMobile ? 8 : 10,
          height: isMobile ? 8 : 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
        SizedBox(width: isMobile ? 6 : 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 11 : isTablet ? 12 : 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Availability legend item for dialog
class _AvailabilityLegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final double opacity;
  final bool isMobile;

  const _AvailabilityLegendItem({
    required this.label,
    required this.color,
    required this.opacity,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
      child: Row(
        children: [
          Container(
            width: isMobile ? 16 : 20,
            height: isMobile ? 3 : 4,
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }
}