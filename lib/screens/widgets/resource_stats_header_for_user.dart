import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ResourceStatsHeaderForUser extends StatelessWidget {
  final int totalResources;

  const ResourceStatsHeaderForUser({
    Key? key,
    required this.totalResources,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: AppColors.primary.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Resources: $totalResources',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkMaroon,
            ),
          ),
        ],
      ),
    );
  }
}