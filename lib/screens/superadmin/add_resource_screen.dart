import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../services/resource_service.dart';

class AddResourceScreen extends StatefulWidget {

  const AddResourceScreen({super.key});

  @override
  State<AddResourceScreen> createState() => _AddResourceScreenState();
}

class _AddResourceScreenState extends State<AddResourceScreen> with TickerProviderStateMixin {
  // Color Palette consistent with DashboardScreen
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color lightMaroon = Color(0xFFB71C1C);
  static const Color maroonAccent = Color(0xFF6D1B2B);
  static const Color softMaroon = Color(0xFFF3E5F5);
  static const Color warmGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFBFF);

  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  final List<String> _categories = ['Facility', 'Room', 'Vehicle'];

  @override
  void initState() {
    super.initState();
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
    _idController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
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
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _selectedImage = pickedFile;
            _imageBytes = bytes;
          });
        } else {
          setState(() {
            _selectedImage = pickedFile;
            _imageBytes = null;
          });
        }
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedImage != null && _selectedCategory != null) {
      final file = kIsWeb ? null : File(_selectedImage!.path);
      final result = await context.read<ResourceService>().addResource(
        id: _idController.text,
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory!,
        image: file,
        imageBytes: kIsWeb ? _imageBytes : null,
        imageName: _selectedImage?.name,
      );

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildPremiumSnackBar(
            message: 'Resource added successfully',
            color: primaryMaroon,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildPremiumSnackBar(
            message: context.read<ResourceService>().errorMessage ?? 'Failed to add resource',
            color: Colors.red[600]!,
          ),
        );
      }
    } else {
      String message = 'Please complete all fields';
      if (_selectedImage == null) {
        message = 'Please select an image';
      } else if (_selectedCategory == null) {
        message = 'Please select a category';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        _buildPremiumSnackBar(
          message: message,
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
                          _buildFormField(
                            controller: _idController,
                            label: 'Resource ID',
                            icon: Icons.badge_rounded,
                            validator: (value) => value!.isEmpty ? 'Please enter a resource ID' : null,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: 16),
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
                            maxLines: 4,
                            validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: 16),
                          _buildCategoryDropdown(isMobile),
                          SizedBox(height: 16),
                          _buildImagePicker(isMobile),
                          SizedBox(height: 32),
                          _buildSubmitButton(resourceService.isLoading, isMobile),
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
                        'Add New Resource',
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
                          'Create a new resource entry',
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
                'Create New Resource',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Add a new resource to the system',
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
            _selectedCategory = value;
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

  // Enhanced Image Picker
  Widget _buildImagePicker(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: isMobile ? 120 : 150,
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
            child: _selectedImage == null
                ? Center(
                    child: Column(
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
                            Icons.add_a_photo_rounded,
                            color: primaryMaroon,
                            size: isMobile ? 24 : 28,
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
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: kIsWeb
                        ? Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(
                                Icons.error_rounded,
                                color: Colors.red[600],
                                size: isMobile ? 24 : 28,
                              ),
                            ),
                          )
                        : Image.file(
                            File(_selectedImage!.path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(
                                Icons.error_rounded,
                                color: Colors.red[600],
                                size: isMobile ? 24 : 28,
                              ),
                            ),
                          ),
                  ),
          ),
        ),
      ],
    );
  }

  // Enhanced Submit Button
  Widget _buildSubmitButton(bool isLoading, bool isMobile) {
    return AnimatedContainer(
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
        onPressed: isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: isMobile ? 14 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          minimumSize: Size(double.infinity, isMobile ? 48 : 52),
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
                'Add Resource',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}