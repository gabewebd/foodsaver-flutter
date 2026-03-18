import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/food_listing.dart';
import '../data/supabase_service.dart';
import '../utils/date_utils.dart';
import '../utils/error_utils.dart';

class ShareFoodScreen extends StatefulWidget {
  final FoodListing? existingItem;
  const ShareFoodScreen({super.key, this.existingItem});

  @override
  State<ShareFoodScreen> createState() => _ShareFoodScreenState();
}

class _ShareFoodScreenState extends State<ShareFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _backstoryController = TextEditingController();
  
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      _titleController.text = widget.existingItem!.grabTitle;
      _locationController.text = widget.existingItem!.meetupSpot;
      _backstoryController.text = widget.existingItem!.backstory;
      _selectedExpiryDate = widget.existingItem!.expiryDate;
    }
  }

  Future<void> _selectExpiryDate() async {
    // Aguiluz: Paki-check if maayos yung date picker, baka malito yung user pre.
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F9D58),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedExpiryDate = picked);
    }
  }

  Future<void> _pickImage(bool shouldCrop) async {
    // Aguiluz: Pick image logic natin pre. Matic na quality 80 para di mabigat sa DB.
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    if (pickedFile != null) {
      if (shouldCrop) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Food Photo',
              toolbarColor: Colors.white,
              toolbarWidgetColor: const Color(0xFFE65100),
              backgroundColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.ratio16x9,
              lockAspectRatio: true,
              hideBottomControls: false,
            ),
            IOSUiSettings(
              title: 'Crop Food Photo',
              aspectRatioLockEnabled: true,
            ),
            WebUiSettings(
              context: context,
              presentStyle: WebPresentStyle.dialog,
              size: const CropperSize(width: 520, height: 520),
            ),
          ],
        );

        if (croppedFile != null) {
          final bytes = await croppedFile.readAsBytes();
          setState(() {
            _imageBytes = bytes;
          });
        }
      } else {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    }
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF0F9D58)),
              title: Text('Upload New Photo', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.crop, color: Color(0xFFE65100)),
              title: Text('Crop New Photo', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    // Velasquez: Form check muna tayo pre bago i-hit yung Supabase.
    if (!_formKey.currentState!.validate()) return;
    if (_imageBytes == null && widget.existingItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isUploading = true);
    // Velasquez: Yamzon, paki-check if mabilis yung loading state pag mabagal internet.
    try {
      String? imageUrl = widget.existingItem?.offlineImage;
      if (_imageBytes != null) {
        final fileName = 'listing_${DateTime.now().millisecondsSinceEpoch}.jpg';
        // Velasquez: Gamit na natin yung bagong uploadImage method pre, wag na yung luma.
        imageUrl = await SupabaseService.uploadImage(fileName, _imageBytes!);
      }

      final listing = FoodListing(
        entryId: widget.existingItem?.entryId ?? '',
        grabTitle: _titleController.text,
        backstory: _backstoryController.text,
        timeWindow: _selectedExpiryDate?.toIso8601String() ?? 'Flexible', 
        dropDistance: '0.1 mi',
        meetupSpot: _locationController.text,
        posterAlias: 'You',
        offlineImage: imageUrl ?? '',
        createdAt: widget.existingItem?.createdAt ?? DateTime.now(),
        expiryDate: _selectedExpiryDate,
      );

      if (widget.existingItem != null) {
        await SupabaseService.updateListing(
          widget.existingItem!.entryId,
          listing,
          imageUrl,
        );
      } else {
        await SupabaseService.postListing(
          listing,
          imageUrl,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingItem != null ? 'Listing updated!' : 'Food shared successfully!'),
          backgroundColor: const Color(0xFF0F9D58),
        ),
      );
      
      if (widget.existingItem != null) {
        Navigator.pop(context);
      } else {
        // Reset form for root tab posting
        _formKey.currentState?.reset();
        _titleController.clear();
        _locationController.clear();
        _backstoryController.clear();
        setState(() {
          _imageBytes = null;
          _selectedExpiryDate = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorUtils.getFriendlyErrorMessage(e)), 
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.existingItem != null;

    return Scaffold(
      backgroundColor: const Color(0xFFE65100),
      body: Column(
        children: [
          _buildHeader(context, isEdit),
          Expanded(
            child: ColoredBox(
              color: const Color(0xFFF9F9F9),
              child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey, 
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildPhotoSection(context),
                      const SizedBox(height: 20),
                      _buildDetailsSection(context, isEdit),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildHeader(BuildContext context, bool isEdit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 24, left: 16, right: 24),
      decoration: const BoxDecoration(
      ),
      child: Row(
        children: [
          if (isEdit)
            IconButton(
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.all(12),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
          if (isEdit) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEdit ? 'Edit Listing' : 'Share Food',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  isEdit ? 'Update your listing details' : 'Help reduce waste in your community',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: _imageBytes != null || widget.existingItem != null
          ? GestureDetector(
              onTap: () => _showImageOptions(context),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: _imageBytes != null
                        ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                        : Image.network(widget.existingItem!.offlineImage, fit: BoxFit.cover),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Icon(Icons.edit, color: Colors.white, size: 40),
                    ),
                  ),
                ],
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickImage(false),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined, size: 50, color: Color(0xFF0F9D58)),
                        const SizedBox(height: 12),
                        Text(
                          'Upload',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 100, color: Colors.grey[200]),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickImage(true),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.crop, size: 50, color: Color(0xFFE65100)),
                        const SizedBox(height: 12),
                        Text(
                          'Crop',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, bool isEdit) {
    return Column(
      children: [
        _buildTextField(
          controller: _titleController,
          label: 'What food is it?',
          hint: 'e.g. 3 slices of pizza, 2 apples',
          icon: Icons.fastfood_outlined,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _locationController,
          label: 'Pickup Location',
          hint: 'e.g. Building 4 lobby, Canteen area',
          icon: Icons.location_on_outlined,
        ),
        _buildTextField(
          controller: _backstoryController,
          label: 'Description (Optional)',
          hint: 'e.g. Bought too much for lunch, still fresh!',
          icon: Icons.history_edu_outlined,
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        // Aguiluz: Date selection para sa expiry. Mark Dave, paki-check design nito.
        GestureDetector(
          onTap: _selectExpiryDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE65100).withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Color(0xFFE65100)),
                const SizedBox(width: 12),
                Text(
                  _selectedExpiryDate == null 
                      ? 'Select Expiry Date' 
                      : 'Expires: ${Months.full[_selectedExpiryDate!.month - 1]} ${_selectedExpiryDate!.day}, ${_selectedExpiryDate!.year}',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: _selectedExpiryDate == null ? Colors.grey[600] : Colors.black,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Color(0xFFE65100)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isUploading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F9D58),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: _isUploading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    isEdit ? 'Update Details' : 'Post Item to Community',
                    style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE65100).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFFE65100)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          labelStyle: GoogleFonts.nunito(color: Colors.grey[600], fontWeight: FontWeight.w600),
          hintStyle: GoogleFonts.nunito(color: Colors.grey[400]),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
