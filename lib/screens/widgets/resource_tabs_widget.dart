import 'package:flutter/material.dart';
import 'package:testing/utils/app_colors.dart';
import '../../services/resource_service.dart';

class ResourceTabsWidget extends StatelessWidget {
  final TabController tabController;
  final List<Resource> resources;

  const ResourceTabsWidget({
    Key? key,
    required this.tabController,
    required this.resources,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Facility'),
            Tab(text: 'Room'),
            Tab(text: 'Vehicle'),
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Container(
          height: 1,
          color: AppColors.primary.withOpacity(0.2),
        ),
      ],
    );
  }
}