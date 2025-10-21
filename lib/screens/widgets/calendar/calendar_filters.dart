// widgets/calendar/calendar_filters.dart

import 'package:flutter/material.dart';
import '../../../utils/calendar_constants.dart';

/// Smart filters widget with search and category filters
class CalendarFilters extends StatelessWidget {
  final String searchQuery;
  final Set<String> activeFilters;
  final Function(String) onSearchChanged;
  final Function(Set<String>) onFiltersChanged;
  final DeviceType deviceType;
  final List<String> availableFilters;

  const CalendarFilters({
    super.key,
    required this.searchQuery,
    required this.activeFilters,
    required this.onSearchChanged,
    required this.onFiltersChanged,
    required this.deviceType,
    this.availableFilters = const [
      'All',
      'Facility',
      'Room',
      'Vehicle',
      'Equipment',
    ],
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : isTablet ? 16 : 20,
        vertical: isMobile ? 8 : isTablet ? 12 : 16,
      ),
      child: Column(
        children: [
          // Search bar
          _buildSearchBar(isMobile, isTablet),
          SizedBox(height: isMobile ? 6 : 8),

          // Filter chips
          _buildFilterChips(isMobile),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile, bool isTablet) {
    return Container(
      height: isMobile ? 40 : isTablet ? 44 : 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 20 : 22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search resources, people, purpose...',
          prefixIcon: Icon(
            Icons.search,
            size: isMobile ? 18 : 20,
            color: Colors.grey[600],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: isMobile ? 10 : 12,
          ),
        ),
        onChanged: onSearchChanged,
        style: TextStyle(fontSize: isMobile ? 14 : 16),
      ),
    );
  }

  Widget _buildFilterChips(bool isMobile) {
    return SizedBox(
      height: isMobile ? 36 : 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: availableFilters.map((filter) {
          final isSelected = activeFilters.contains(filter);
          return _FilterChip(
            label: filter,
            isSelected: isSelected,
            onSelected: (selected) => _handleFilterToggle(filter, selected),
            deviceType: deviceType,
          );
        }).toList(),
      ),
    );
  }

  void _handleFilterToggle(String filter, bool selected) {
    final newFilters = Set<String>.from(activeFilters);

    if (filter == 'All') {
      newFilters.clear();
      newFilters.add('All');
    } else {
      newFilters.remove('All');
      if (selected) {
        newFilters.add(filter);
      } else {
        newFilters.remove(filter);
      }
      if (newFilters.isEmpty) {
        newFilters.add('All');
      }
    }

    onFiltersChanged(newFilters);
  }
}

/// Individual filter chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;
  final DeviceType deviceType;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Container(
      margin: EdgeInsets.only(right: isMobile ? 6 : 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 12 : isTablet ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: isSelected,
        onSelected: onSelected,
        backgroundColor: Colors.white,
        selectedColor: CalendarColors.primaryMaroon.withOpacity(0.15),
        checkmarkColor: CalendarColors.primaryMaroon,
        labelStyle: TextStyle(
          color: isSelected
              ? CalendarColors.primaryMaroon
              : Colors.grey[700],
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(
          color: isSelected
              ? CalendarColors.primaryMaroon
              : Colors.grey[300]!,
        ),
      ),
    );
  }
}

/// Status filter widget (alternative filter for status-based filtering)
class StatusFilters extends StatelessWidget {
  final Set<String> activeStatuses;
  final Function(Set<String>) onStatusesChanged;
  final DeviceType deviceType;

  const StatusFilters({
    super.key,
    required this.activeStatuses,
    required this.onStatusesChanged,
    required this.deviceType,
  });

  static const List<String> statusOptions = [
    'All',
    'Approved',
    'Pending',
    'Cancelled',
    'Rejected',
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;

    return SizedBox(
      height: isMobile ? 36 : 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: statusOptions.map((status) {
          final isSelected = activeStatuses.contains(status.toLowerCase()) ||
              (status == 'All' && activeStatuses.isEmpty);
          return _FilterChip(
            label: status,
            isSelected: isSelected,
            onSelected: (selected) => _handleStatusToggle(status, selected),
            deviceType: deviceType,
          );
        }).toList(),
      ),
    );
  }

  void _handleStatusToggle(String status, bool selected) {
    final newStatuses = Set<String>.from(activeStatuses);

    if (status == 'All') {
      newStatuses.clear();
    } else {
      final statusLower = status.toLowerCase();
      if (selected) {
        newStatuses.add(statusLower);
      } else {
        newStatuses.remove(statusLower);
      }
    }

    onStatusesChanged(newStatuses);
  }
}