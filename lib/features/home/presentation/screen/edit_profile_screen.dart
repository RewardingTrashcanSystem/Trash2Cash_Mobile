import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:trash2cash/core/helper/image_helper.dart';
import 'package:trash2cash/features/auth/data/model/user_model.dart';
import 'package:trash2cash/features/auth/presentation/provider/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final profileProvider = context.read<ProfileProvider>();
    final user = profileProvider.user;

    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Failed to take photo: $e');
    }
  }

  Future<void> _updateProfile() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (_firstNameController.text.isEmpty) {
      _showError('Please enter your first name');
      return;
    }

    if (_lastNameController.text.isEmpty) {
      _showError('Please enter your last name');
      return;
    }

    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      imageFile: _selectedImage,
    );

    if (!mounted) return;

    if (profileProvider.user != null) {
      _showSuccess('Profile updated successfully!');
      Navigator.pop(context);
    } else {
      _showError('Failed to update profile');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildProfileImage(UserModel? user) {
  return GestureDetector(
    onTap: _showImagePickerOptions,
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Main Avatar
        Container(
          width: 120,
          height: 120,
          child: _selectedImage != null
              ? ClipOval(
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                  ),
                )
              : ImageHelper.profileImage(
                  imagePath: user?.image,
                  size: 120,
                  isCircle: true,
                  backgroundColor: Colors.green.shade100,
                  iconColor: Colors.green.shade800,
                ),
        ),
        
        // Border
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green, width: 3),
          ),
        ),
        
        // Camera Icon
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.green.shade100,
      child: Center(
        child: Icon(
          Icons.person,
          size: 60,
          color: Colors.green.shade800,
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final user = profileProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.green,
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Center(child: _buildProfileImage(user)),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: user?.email ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    readOnly: true,
                    enabled: false,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: user?.phoneNumber ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    readOnly: true,
                    enabled: false,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: profileProvider.isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: profileProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Update Profile',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 30),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Points',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    '${user.totalPoints}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Eco Level',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  user.ecoLevel,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
