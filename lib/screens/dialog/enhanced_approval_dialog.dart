import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testing/models/reservation_history_model.dart';
import 'package:testing/services/reservation_approval_service.dart';
import 'package:testing/services/auth_service.dart';
import '../../models/reservation_approval_model.dart';
import '../../utils/approval_design_system.dart';

class EnhancedApprovalDialog extends StatefulWidget {
  final ReservationApproval reservation;
  final Function(String action, String? comment) onAction;
  final bool isMobile;

  const EnhancedApprovalDialog({
    super.key,
    required this.reservation,
    required this.onAction,
    required this.isMobile,
  });

  @override
  State<EnhancedApprovalDialog> createState() => _EnhancedApprovalDialogState();
}

class _EnhancedApprovalDialogState extends State<EnhancedApprovalDialog> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  bool _showComment = false;
  bool _scheduleExpanded = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: widget.isMobile ? double.infinity : 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, ApprovalDesignSystem.cardBackground],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: ApprovalDesignSystem.primaryMaroon.withOpacity(0.2),
              blurRadius: 30,
              offset: Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildTabBar(),
            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDetailsTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
            _buildActionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ApprovalDesignSystem.getCardPadding(widget.isMobile)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ApprovalDesignSystem.primaryMaroon, ApprovalDesignSystem.lightMaroon],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.event_available_rounded, color: Colors.white, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Reservation',
                  style: ApprovalDesignSystem.titleLarge(widget.isMobile).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getDisplayText(widget.reservation.facilityName, 'Unnamed Facility'),
                  style: ApprovalDesignSystem.bodySmall(widget.isMobile).copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: ApprovalDesignSystem.primaryMaroon,
        unselectedLabelColor: Colors.grey,
        indicatorColor: ApprovalDesignSystem.primaryMaroon,
        indicatorWeight: 3,
        tabs: [
          Tab(
            icon: Icon(Icons.info_outline_rounded),
            text: 'Details',
          ),
          Tab(
            icon: Icon(Icons.history_rounded),
            text: 'History',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ApprovalDesignSystem.getCardPadding(widget.isMobile)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailCard('Facility', _getDisplayText(widget.reservation.facilityName, 'Unnamed Facility'), Icons.meeting_room_rounded),
          _buildDetailCard('Purpose', _getDisplayText(widget.reservation.purpose, 'No purpose specified'), Icons.description_rounded),
          _buildScheduleSection(),
          _buildDetailCard('Requester', _getDisplayText(widget.reservation.requesterName, 'Unknown User'), Icons.person_rounded),
          _buildDetailCard('Approval Step', widget.reservation.stepOrder > 0 ? 'Step ${widget.reservation.stepOrder}' : 'Step N/A', Icons.approval_rounded),
          if (widget.reservation.reservationId.isNotEmpty)
            _buildDetailCard('Reservation ID', widget.reservation.reservationId, Icons.confirmation_number_rounded),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    if (widget.reservation.dailySlots.isEmpty) {
      return Column(
        children: [
          _buildDetailCard('Date Range', _getDisplayText(widget.reservation.dateRange, 'No date specified'), Icons.calendar_today_rounded),
          _buildDetailCard('Time Range', _getDisplayText(widget.reservation.timeRange, 'No time specified'), Icons.access_time_rounded),
        ],
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _scheduleExpanded = !_scheduleExpanded),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ApprovalDesignSystem.primaryMaroon.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.schedule_rounded, color: ApprovalDesignSystem.primaryMaroon, size: 18),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule',
                          style: ApprovalDesignSystem.bodySmall(widget.isMobile).copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${widget.reservation.dailySlots.length} day(s) • Tap to ${_scheduleExpanded ? 'collapse' : 'expand'}',
                          style: ApprovalDesignSystem.bodyLarge(widget.isMobile).copyWith(
                            color: ApprovalDesignSystem.darkMaroon,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _scheduleExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: ApprovalDesignSystem.primaryMaroon,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (_scheduleExpanded) ...[
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(
                  widget.reservation.dailySlots.length,
                  (index) => _buildDaySlot(index),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDaySlot(int index) {
    final slot = widget.reservation.dailySlots[index];
    final isLast = index == widget.reservation.dailySlots.length - 1;
    final dayLabel = widget.reservation.getDayLabel(index);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ApprovalDesignSystem.primaryMaroon.withOpacity(0.1),
                      ApprovalDesignSystem.lightMaroon.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ApprovalDesignSystem.primaryMaroon.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Text(
                  dayLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ApprovalDesignSystem.primaryMaroon,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.formatDatePh(slot.date),
                      style: TextStyle(
                        fontSize: widget.isMobile ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: ApprovalDesignSystem.darkMaroon,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          slot.formattedTime,
                          style: TextStyle(
                            fontSize: widget.isMobile ? 12 : 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.grey.shade200,
            height: 1,
            indent: 0,
            endIndent: 0,
          ),
      ],
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ApprovalDesignSystem.primaryMaroon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: ApprovalDesignSystem.primaryMaroon, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: ApprovalDesignSystem.bodySmall(widget.isMobile).copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: ApprovalDesignSystem.bodyLarge(widget.isMobile).copyWith(
                    color: ApprovalDesignSystem.darkMaroon,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Container(
      padding: EdgeInsets.all(ApprovalDesignSystem.getCardPadding(widget.isMobile)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.history_rounded, color: Colors.blue, size: 32),
                SizedBox(height: 12),
                Text(
                  'History Feature',
                  style: ApprovalDesignSystem.titleMedium(widget.isMobile).copyWith(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap here to view the complete activity history for this reservation request.',
                  textAlign: TextAlign.center,
                  style: ApprovalDesignSystem.bodySmall(widget.isMobile).copyWith(
                    color: Colors.blue.shade600,
                  ),
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _showHistoryBottomSheet(),
                  icon: Icon(Icons.timeline_rounded),
                  label: Text('View History'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Container(
      padding: EdgeInsets.all(ApprovalDesignSystem.getCardPadding(widget.isMobile)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Action Required',
            style: ApprovalDesignSystem.titleMedium(widget.isMobile).copyWith(
              fontWeight: FontWeight.bold,
              color: ApprovalDesignSystem.darkMaroon,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please review the reservation request and take appropriate action.',
            style: ApprovalDesignSystem.bodySmall(widget.isMobile).copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              Icon(Icons.comment_rounded, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Add Comment (Optional)',
                style: ApprovalDesignSystem.bodySmall(widget.isMobile).copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Spacer(),
              Switch(
                value: _showComment,
                onChanged: (value) => setState(() => _showComment = value),
                activeColor: ApprovalDesignSystem.primaryMaroon,
              ),
            ],
          ),
          
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _showComment ? null : 0,
            child: _showComment ? Column(
              children: [
                SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add your comment here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ApprovalDesignSystem.primaryMaroon),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ],
            ) : SizedBox.shrink(),
          ),
          
          SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleAction('rejected'),
                  icon: Icon(Icons.close_rounded),
                  label: Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: ApprovalDesignSystem.errorRed),
                    foregroundColor: ApprovalDesignSystem.errorRed,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleAction('approved'),
                  icon: Icon(Icons.check_rounded),
                  label: Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ApprovalDesignSystem.primaryMaroon,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleAction(String action) {
    final comment = _commentController.text.trim();
    widget.onAction(action, comment.isEmpty ? null : comment);
    Navigator.of(context).pop();
  }

  void _showHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReservationHistorySheet(
        reservationId: widget.reservation.reservationId,
        isMobile: widget.isMobile,
      ),
    );
  }

  String _getDisplayText(String? value, String fallback) {
    final trimmedValue = value?.trim();
    return trimmedValue?.isEmpty == true || trimmedValue == null 
        ? fallback 
        : trimmedValue;
  }
}

class ReservationHistorySheet extends StatefulWidget {
  final String reservationId;
  final bool isMobile;

  const ReservationHistorySheet({
    super.key,
    required this.reservationId,
    required this.isMobile,
  });

  @override
  State<ReservationHistorySheet> createState() => _ReservationHistorySheetState();
}

class _ReservationHistorySheetState extends State<ReservationHistorySheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.history_rounded, color: ApprovalDesignSystem.primaryMaroon),
                SizedBox(width: 12),
                Text(
                  'Reservation History',
                  style: ApprovalDesignSystem.titleLarge(widget.isMobile).copyWith(
                    color: ApprovalDesignSystem.darkMaroon,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          
          Divider(color: Colors.grey.shade200),
          
          Expanded(
            child: Consumer<ReservationApprovalService>(
              builder: (context, service, child) {
                if (service.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(ApprovalDesignSystem.primaryMaroon),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading history...',
                          style: ApprovalDesignSystem.bodyMedium(widget.isMobile),
                        ),
                      ],
                    ),
                  );
                }
                
                if (service.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Error loading history',
                          style: ApprovalDesignSystem.titleMedium(widget.isMobile).copyWith(
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          service.errorMessage!,
                          textAlign: TextAlign.center,
                          style: ApprovalDesignSystem.bodySmall(widget.isMobile).copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadHistory(),
                          child: Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ApprovalDesignSystem.primaryMaroon,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (service.currentHistory == null || service.currentHistory!.activities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No history available',
                          style: ApprovalDesignSystem.titleMedium(widget.isMobile).copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This reservation has no recorded activity yet.',
                          textAlign: TextAlign.center,
                          style: ApprovalDesignSystem.bodySmall(widget.isMobile).copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadHistory(),
                          child: Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ApprovalDesignSystem.primaryMaroon,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return _buildHistoryTimeline(service.currentHistory!);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _loadHistory() {
    if (widget.reservationId.isEmpty) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final approvalService = Provider.of<ReservationApprovalService>(context, listen: false);
    
    final token = authService.token;
    if (token == null || token.isEmpty) return;
    
    approvalService.fetchReservationHistory(widget.reservationId, token);
  }
  
  Widget _buildHistoryTimeline(ReservationHistory history) {
    if (history.activities.isEmpty) {
      return Center(
        child: Text(
          'No activities recorded',
          style: ApprovalDesignSystem.bodyLarge(widget.isMobile),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: history.activities.length,
      itemBuilder: (context, index) {
        final activity = history.activities[index];
        return _buildTimelineItem(activity, index == history.activities.length - 1);
      },
    );
  }
  
  Widget _buildTimelineItem(ActivityLog activity, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getActivityColor(activity.actionType),
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade200,
              ),
          ],
        ),
        
        SizedBox(width: 16),
        
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      activity.actionType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getActivityColor(activity.actionType),
                      ),
                    ),
                    if (activity.stepOrder != null) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ApprovalDesignSystem.primaryMaroon.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Step ${activity.stepOrder}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: ApprovalDesignSystem.primaryMaroon,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                SizedBox(height: 8),
                
                Text(
                  activity.description,
                  style: ApprovalDesignSystem.bodyMedium(widget.isMobile).copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                
                if (activity.statusChangeText.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    activity.statusChangeText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ApprovalDesignSystem.primaryMaroon,
                    ),
                  ),
                ],
                
                if (activity.hasComment) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.comment_rounded, size: 14, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              'Comment',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          activity.comment!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(Icons.person_rounded, size: 14, color: Colors.grey.shade600),
                    SizedBox(width: 4),
                    Text(
                      activity.actionByName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      ' • ${activity.formattedDate}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getActivityColor(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'approved':
        return ApprovalDesignSystem.successGreen;
      case 'rejected':
        return ApprovalDesignSystem.errorRed;
      case 'created':
        return Colors.blue;
      case 'commented':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}