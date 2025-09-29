import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ResourceStatsHeader extends StatelessWidget {
  final int totalResources;
  final bool isMobile;

  const ResourceStatsHeader({
    Key? key,
    required this.totalResources,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Resources: $totalResources',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkMaroon,
            ),
          ),
          Icon(
            Icons.info_outline,
            size: isMobile ? 20 : 24,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}