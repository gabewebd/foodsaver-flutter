import 'dart:typed_data'; // Velasquez, ito yung kailangan para cross-platform (Web/Mobile) via bytes.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Yamzon, ito yung magbubukas ng gallery.
import 'package:image_cropper/image_cropper.dart'; // Camus, ito yung para sa pag-crop ng photos.
import '../data/mock_data.dart'; // Velasquez: Kailangan natin 'to para mag-add sa global list.

/* 
Aguiluz, eto yung kailangan mo sa pubspec.yaml para gumana 'to:
dependencies:
  image_picker: ^1.0.7
  image_cropper: ^5.0.1
*/

class ShareFoodScreen extends StatefulWidget {
  const ShareFoodScreen({super.key});

  @override
  State<ShareFoodScreen> createState() => _ShareFoodScreenState();
}

class _ShareFoodScreenState extends State<ShareFoodScreen> {
  // Velasquez, ito na yung key para sa form validation natin.
  final _formKey = GlobalKey<FormState>();
  
  // Controllers para ma-capture natin yung input ni user.
  // Velasquez, ito yung mga saksakan natin sa Supabase later.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); // Velasquez, added description controller for backstory.
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Yamzon, dito natin i-store yung state variable natin para sa cropped image bytes.
  // Velasquez, memory bytes gamit natin (Uint8List) para rekta display sa Image.memory().
  Uint8List? _croppedImageBytes;
  XFile? _tempImageFile; // Camus, ito yung hahawak sa initial image bago i-crop.
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose(); // Velasquez, dispose the new controller.
    _expiryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Yamzon, ito yung function para kumuha ng image sa gallery o camera.
  // Yamaguchi, dito tatawagin yung native image picker library natin.
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _tempImageFile = image;
      });
      // Velasquez, pwedeng i-auto trigger yung crop dito or wait sa manual button tap.
      // For now, sine-save muna natin sa temp file.
    }
  }

  // Camus, ito yung logic para sa pag-crop ng image gamit yung high-fidelity UI.
  // Yamaguchi, dito tatawagin yung cropper library na may rotation at sliders.
  Future<void> _cropImage() async {
    if (_tempImageFile == null) return;
    
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _tempImageFile!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Food Photo',
          toolbarColor: const Color(0xFFE65100),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Food Photo',
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(
            width: 520,
            height: 520,
          ),
        ),
      ],
    );

    if (croppedFile != null) {
      // Velasquez, kukunin na natin yung raw bytes ng cropped photo.
      final bytes = await croppedFile.readAsBytes();
      setState(() {
        _croppedImageBytes = bytes;
      });
      // Camus, gumagana na yung crop pero single image flow pa lang ah.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey, // Velasquez, binalot natin ng Form widget ah.
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildPhotoSection(context),
                    const SizedBox(height: 20),
                    _buildDetailsSection(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFE65100),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aguiluz, tinanggal ko na yung back button dito kasi part na siya ng main shell navigation natin.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Food',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Help reduce waste in your community',
                style: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE65100),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Food Photo',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D3142),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Yamzon, dito na yung dynamic rendering natin using Image.memory().
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _croppedImageBytes != null
                ? Image.memory(
                    _croppedImageBytes!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          'No photo selected yet',
                          style: GoogleFonts.nunito(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Upload and crop your food photo',
                          style: GoogleFonts.nunito(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _tempImageFile != null ? _cropImage : null, 
                  icon: const Icon(Icons.crop_rotate, size: 18),
                  label: const Text('Crop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickImage, 
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                  label: const Text('Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    foregroundColor: const Color(0xFF2D3142),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF0F9D58).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F9D58),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Item Details',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D3142),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFormField(
            controller: _nameController,
            icon: Icons.inventory_2_outlined,
            hint: 'What is it? (e.g., Fresh Bagels)',
          ),
          const SizedBox(height: 15),
          // Velasquez, added description field for backstory as requested.
          _buildFormField(
            controller: _descriptionController,
            icon: Icons.description_outlined,
            hint: 'Description (e.g., Extra oranges...)',
            maxLines: 3,
          ),
          const SizedBox(height: 15),
          _buildFormField(
            controller: _expiryController,
            icon: Icons.calendar_month_outlined,
            hint: "When is the 'Best Before' date?",
          ),
          const SizedBox(height: 15),
          _buildFormField(
            controller: _locationController,
            icon: Icons.location_on_outlined,
            hint: 'Pickup Location (e.g., Building A, Apt 105)',
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Velasquez, dito yung checking kung valid yung fields at kung may cropped image na.
                if (_croppedImageBytes == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select and crop an image for the food item.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (_formKey.currentState!.validate()) {
                  // Velasquez, instantiating the new listing with perfectly aligned data.
                  final newEntry = FoodListing(
                    entryId: DateTime.now().toString(), // Velasquez, generated unique entry ID.
                    grabTitle: _nameController.text,
                    backstory: _descriptionController.text, // Map to backstory.
                    timeWindow: _expiryController.text,
                    dropDistance: '0.5 mi', // Hardcoded as per mock logic requirements.
                    meetupSpot: _locationController.text,
                    posterAlias: 'Current User', // Hardcoded placeholder for now.
                    offlineImage: 'assets/images/pasta_sauce.png', // Temporary placeholder asset.
                  );

                  FoodListing.addListing(newEntry);

                  // Velasquez, clear natin controllers at state after successful post.
                  _nameController.clear();
                  _descriptionController.clear();
                  _expiryController.clear();
                  _locationController.clear();
                  setState(() {
                    _croppedImageBytes = null;
                    _tempImageFile = null;
                  });
                  FocusScope.of(context).unfocus(); 
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item successfully posted to community!'),
                      backgroundColor: Color(0xFF0F9D58),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Post Item to Community'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F9D58),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required.';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          hintText: hint,
          hintStyle: GoogleFonts.nunito(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
    );
  }
}
