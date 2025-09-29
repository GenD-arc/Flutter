import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/reservation_service.dart';
import '../models/reservation_model.dart';
import '../utils/reservation_design_system.dart';
import 'widgets/reservation_components.dart';
import 'dialog/reservation_dialogs.dart';

class ReservationHistoryScreen extends StatefulWidget {
  final String userId;

  const ReservationHistoryScreen({super.key, required this.userId});

  @override
  State<ReservationHistoryScreen> createState() => _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState extends State<ReservationHistoryScreen> {
  late ReservationService _reservationService;
  List<Reservation> _reservations = [];
  List<Reservation> _filteredReservations = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _reservationService = ReservationService(Provider.of<AuthService>(context, listen: false));
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final reservations = await _reservationService.getUserReservations(widget.userId);
      setState(() {
        _reservations = reservations;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Reservation> filtered = _reservations;

    if (_selectedFilter != 'All') {
      filtered = filtered.where((r) => r.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) => 
        r.facilityName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        r.purpose.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        r.facilityId.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    setState(() {
      _filteredReservations = filtered;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final ds = ReservationDesignSystem;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Reservation History', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF8B0000),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadReservations,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isLoading && _errorMessage.isEmpty) ...[
            ReservationStatsCard(
              total: _reservations.length,
              pending: _reservations.where((r) => r.status.toLowerCase() == 'pending').length,
              approved: _reservations.where((r) => r.status.toLowerCase() == 'approved').length,
              isMobile: isMobile,
            ),
            _buildFilterSection(isMobile),
          ],
          Expanded(child: _buildContent(isMobile)),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ReservationDesignSystem.getSectionPadding(isMobile)),
      child: Column(
        children: [
          _buildSearchBar(isMobile),
          SizedBox(height: ReservationDesignSystem.getElementSpacing(isMobile)),
          _buildFilterChips(isMobile),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        onChanged: (value) => setState(() {
          _searchQuery = value;
          _applyFilters();
        }),
        decoration: InputDecoration(
          hintText: 'Search reservations...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: _searchQuery.isNotEmpty ? IconButton(
            icon: Icon(Icons.clear, color: Colors.grey[500]),
            onPressed: () => setState(() {
              _searchQuery = '';
              _applyFilters();
            }),
          ) : null,
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isMobile) {
    final filters = ['All', 'Pending', 'Approved', 'Rejected', 'Cancelled'];
    
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          
          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) => setState(() {
              _selectedFilter = filter;
              _applyFilters();
            }),
            selectedColor: ReservationDesignSystem.primaryMaroon,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : ReservationDesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    if (_isLoading) return _buildLoadingState();
    if (_errorMessage.isNotEmpty) return _buildErrorState();
    if (_filteredReservations.isEmpty) return _buildEmptyState(isMobile);
    
    return RefreshIndicator(
      onRefresh: _loadReservations,
      color: ReservationDesignSystem.primaryMaroon,
      child: ListView.builder(
        padding: EdgeInsets.all(ReservationDesignSystem.getSectionPadding(isMobile)),
        itemCount: _filteredReservations.length,
        itemBuilder: (context, index) {
          final reservation = _filteredReservations[index];
          return ReservationCard(
            reservation: reservation,
            isMobile: isMobile,
            onTap: () => _showReservationDetails(reservation, isMobile),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(ReservationDesignSystem.primaryMaroon)),
          SizedBox(height: 16),
          Text('Loading reservations...', style: ReservationDesignSystem.bodyLarge(false)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            SizedBox(height: 16),
            Text('Error', style: ReservationDesignSystem.titleLarge(false)),
            SizedBox(height: 8),
            Text(_errorMessage, style: ReservationDesignSystem.bodyLarge(false), textAlign: TextAlign.center),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadReservations,
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ReservationDesignSystem.primaryMaroon,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty || _selectedFilter != 'All' ? Icons.search_off : Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'All' ? 'No reservations found' : 'No reservations yet',
              style: ReservationDesignSystem.titleLarge(isMobile),
            ),
            SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'All' 
                  ? 'Try adjusting your search or filter criteria'
                  : 'Your reservation history will appear here once you make your first reservation',
              style: ReservationDesignSystem.bodyLarge(isMobile),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty || _selectedFilter != 'All') ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'All';
                  _applyFilters();
                }),
                icon: Icon(Icons.clear_all),
                label: Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ReservationDesignSystem.primaryMaroon,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReservationDetails(Reservation reservation, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) => ReservationDetailsDialog(
        reservation: reservation,
        isMobile: isMobile,
      ),
    );
  }
}