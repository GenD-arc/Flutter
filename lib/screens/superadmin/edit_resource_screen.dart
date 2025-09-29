import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/resource_service.dart';

class EditResourceScreen extends StatefulWidget {
  final Resource resource;

  const EditResourceScreen({Key? key, required this.resource}) : super(key: key);

  @override
  _EditResourceScreenState createState() => _EditResourceScreenState();
}

class _EditResourceScreenState extends State<EditResourceScreen> with TickerProviderStateMixin {
  // Color Palette consistent with previous screens
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color lightMaroon = Color(0xFFB71C1C);
  static const Color maroonAccent = Color(0xFF6D1B2B);
  static const Color warmGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFBFF);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Facility';
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _imageName;
  bool _imageChanged = false;
  bool _isFullUpdate = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  final List<String> _categories = ['Facility', 'Room', 'Vehicle'];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.resource.name;
    _descriptionController.text = widget.resource.description;
    _selectedCategory = widget.resource.category;
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1024,
        maxWidth: 1024,
      );
      if (pickedFile != null) {
        final extension = pickedFile.name.toLowerCase();
        if (!extension.endsWith('.jpg') && !extension.endsWith('.jpeg') && !extension.endsWith('.png')) {
          ScaffoldMessenger.of(context).showSnackBar(
            _buildPremiumSnackBar(
              message: 'Only JPEG and PNG images are allowed',
              color: Colors.red[600]!,
            ),
          );
          return;
        }
        setState(() {
          _imageChanged = true;
          if (kIsWeb) {
            pickedFile.readAsBytes().then((bytes) {
              setState(() {
                _imageBytes = bytes;
                _imageName = pickedFile.name;
              });
            });
          } else {
            _imageFile = File(pickedFile.path);
            _imageName = pickedFile.name;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildPremiumSnackBar(
          message: 'Error picking image: $e',
          color: Colors.red[600]!,
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _imageBytes = null;
      _imageName = null;
      _imageChanged = true;
    });
  }

  bool _hasChanges() {
    return _nameController.text != widget.resource.name ||
           _descriptionController.text != widget.resource.description ||
           _selectedCategory != widget.resource.category ||
           _imageChanged;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasChanges()) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildPremiumSnackBar(
          message: 'No changes detected',
          color: Colors.orange[600]!,
        ),
      );
      return;
    }

    final resourceService = Provider.of<ResourceService>(context, listen: false);

    String? name = _nameController.text != widget.resource.name ? _nameController.text : null;
    String? description = _descriptionController.text != widget.resource.description ? _descriptionController.text : null;
    String? category = _selectedCategory != widget.resource.category ? _selectedCategory : null;

    if (_isFullUpdate) {
      name = _nameController.text;
      description = _descriptionController.text;
      category = _selectedCategory;
    }

    final success = await resourceService.updateResource(
      id: widget.resource.id,
      name: name,
      description: description,
      category: category,
      image: _imageFile,
      imageBytes: _imageBytes,
      imageName: _imageName,
      isFullUpdate: _isFullUpdate,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildPremiumSnackBar(
          message: 'Resource updated successfully',
          color: primaryMaroon,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildPremiumSnackBar(
          message: resourceService.errorMessage ?? 'Failed to update resource',
          color: Colors.red[600]!,
        ),
      );
    }
  }

  SnackBar _buildPremiumSnackBar({required String message, required Color color}) {
    return SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.all(16),
      elevation: 6,
      duration: Duration(seconds: 3),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    final isTablet = screenSize.width >= 768 && screenSize.width < 1024;

    return Scaffold(
      backgroundColor: warmGray,
      appBar: _buildPremiumAppBar(isMobile),
      body: Consumer<ResourceService>(
        builder: (context, resourceService, child) {
          return FadeTransition(
            opacity: _fadeController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _slideController,
                curve: Curves.easeOutCubic,
              )),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 28),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cardBackground, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryMaroon.withOpacity(0.08),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 24 : 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(isMobile),
                          SizedBox(height: 32),
                          _buildUpdateModeIndicator(isMobile),
                          SizedBox(height: 24),
                          _buildResourceIdCard(isMobile),
                          SizedBox(height: 24),
                          _buildFormField(
                            controller: _nameController,
                            label: 'Resource Name',
                            icon: Icons.label_rounded,
                            validator: (value) => value!.isEmpty ? 'Please enter a resource name' : null,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: 16),
                          _buildFormField(
                            controller: _descriptionController,
                            label: 'Description',
                            icon: Icons.description_rounded,
                            maxLines: 3,
                            validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: 16),
                          _buildCategoryDropdown(isMobile),
                          SizedBox(height: 24),
                          _buildImageSection(isMobile),
                          SizedBox(height: 32),
                          _buildActionButtons(resourceService.isLoading, isMobile),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Premium AppBar with Enhanced Design
  PreferredSizeWidget _buildPremiumAppBar(bool isMobile) {
    return PreferredSize(
      preferredSize: Size.fromHeight(isMobile ? 70 : 85),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, cardBackground],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryMaroon.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 4),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 32,
              vertical: isMobile ? 12 : 16,
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryMaroon.withOpacity(0.1),
                        primaryMaroon.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: primaryMaroon.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: primaryMaroon, size: 24),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.all(8),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Edit Resource',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 22,
                          fontWeight: FontWeight.w800,
                          color: darkMaroon,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isMobile) ...[
                        SizedBox(height: 4),
                        Text(
                          'Update resource details',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _isFullUpdate = value == 'full';
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'full',
                      child: Row(
                        children: [
                          Icon(Icons.update_rounded, size: 20, color: primaryMaroon),
                          SizedBox(width: 8),
                          Text(
                            'Full Update',
                            style: TextStyle(color: darkMaroon, fontWeight: FontWeight.w600),
                          ),
                          if (_isFullUpdate)
                            Icon(Icons.check, color: primaryMaroon, size: 16),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'partial',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 20, color: primaryMaroon),
                          SizedBox(width: 8),
                          Text(
                            'Partial Update',
                            style: TextStyle(color: darkMaroon, fontWeight: FontWeight.w600),
                          ),
                          if (!_isFullUpdate)
                            Icon(Icons.check, color: primaryMaroon, size: 16),
                        ],
                      ),
                    ),
                  ],
                  icon: Icon(Icons.more_vert_rounded, color: primaryMaroon),
                  color: cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: primaryMaroon.withOpacity(0.2)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header with Enhanced Visuals
  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryMaroon, maroonAccent, lightMaroon],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryMaroon.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Resource',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Update existing resource details',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Enhanced Update Mode Indicator
  Widget _buildUpdateModeIndicator(bool isMobile) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _isFullUpdate ? primaryMaroon.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            _isFullUpdate ? primaryMaroon.withOpacity(0.05) : Colors.orange.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFullUpdate ? primaryMaroon : Colors.orange,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isFullUpdate ? primaryMaroon : Colors.orange).withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _isFullUpdate ? primaryMaroon.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                  _isFullUpdate ? primaryMaroon.withOpacity(0.08) : Colors.orange.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isFullUpdate ? Icons.update_rounded : Icons.edit_rounded,
              color: _isFullUpdate ? primaryMaroon : Colors.orange,
              size: isMobile ? 18 : 20,
            ),
          ),
          SizedBox(width: 8),
          Text(
            _isFullUpdate ? 'Full Update Mode' : 'Partial Update Mode',
            style: TextStyle(
              color: _isFullUpdate ? primaryMaroon : Colors.orange,
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Resource ID Card
  Widget _buildResourceIdCard(bool isMobile) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, cardBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryMaroon.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryMaroon.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryMaroon.withOpacity(0.15),
                  primaryMaroon.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.badge_rounded,
              color: primaryMaroon,
              size: isMobile ? 20 : 22,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resource ID',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                widget.resource.id,
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w700,
                  color: darkMaroon,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Enhanced Form Field
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    required bool isMobile,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, cardBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryMaroon.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryMaroon.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: darkMaroon,
          fontSize: isMobile ? 14 : 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: isMobile ? 12 : 14,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryMaroon.withOpacity(0.15),
                  primaryMaroon.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: primaryMaroon,
              size: isMobile ? 20 : 22,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isMobile ? 14 : 16,
          ),
        ),
      ),
    );
  }

  // Enhanced Category Dropdown
  Widget _buildCategoryDropdown(bool isMobile) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, cardBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryMaroon.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryMaroon.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        items: _categories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(
              category,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: darkMaroon,
                fontSize: isMobile ? 14 : 15,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value!;
          });
        },
        validator: (value) => value == null ? 'Please select a category' : null,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: darkMaroon,
          fontSize: isMobile ? 14 : 15,
        ),
        decoration: InputDecoration(
          labelText: 'Category',
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: isMobile ? 12 : 14,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryMaroon.withOpacity(0.15),
                  primaryMaroon.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.category_rounded,
              color: primaryMaroon,
              size: isMobile ? 20 : 22,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isMobile ? 14 : 16,
          ),
        ),
        dropdownColor: cardBackground,
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: primaryMaroon,
          size: isMobile ? 24 : 26,
        ),
      ),
    );
  }

  // Enhanced Image Section
  Widget _buildImageSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Resource Image',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w800,
                color: darkMaroon,
                letterSpacing: 0.3,
              ),
            ),
            if (_hasImage() || (!_imageChanged && widget.resource.imageUrl != null))
              TextButton.icon(
                onPressed: _removeImage,
                icon: Icon(Icons.delete_rounded, size: isMobile ? 16 : 18, color: Colors.red[600]),
                label: Text(
                  'Remove',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
          ],
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: isMobile ? 150 : 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[50]!,
                  Colors.grey[100]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryMaroon.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryMaroon.withOpacity(0.08),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildImagePreview(isMobile),
            ),
          ),
        ),
      ],
    );
  }

  bool _hasImage() {
    return _imageFile != null || _imageBytes != null;
  }

  Widget _buildImagePreview(bool isMobile) {
    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(isMobile),
      );
    }

    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(isMobile),
      );
    }

    if (!_imageChanged && widget.resource.imageUrl != null) {
      return Image.network(
        widget.resource.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(isMobile),
      );
    }

    return _buildImagePlaceholder(isMobile);
  }

  Widget _buildImagePlaceholder(bool isMobile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 8 : 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryMaroon.withOpacity(0.15),
                primaryMaroon.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.add_photo_alternate_rounded,
            size: isMobile ? 32 : 40,
            color: primaryMaroon,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Tap to select image',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: isMobile ? 12 : 14,
          ),
        ),
      ],
    );
  }

  // Enhanced Action Buttons
  Widget _buildActionButtons(bool isLoading, bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryMaroon.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryMaroon.withOpacity(0.08),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: primaryMaroon,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryMaroon, lightMaroon],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryMaroon.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}