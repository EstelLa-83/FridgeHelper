import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fridge/controller/global.dart';
import 'package:fridge/controller/auth_service.dart';
import 'package:fridge/controller/profileImages.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  int profile = 0;
  bool isEditingName = false;

  Future<void> _loadUserInfo() async {
    final response = await authenticatedRequest(
      context: context,
      url: Uri.parse('$BASE_URL/users/me'),
      method: 'GET',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (!mounted) return;
      setState(() {
        nameController.text = data['userName'];
        emailController.text = data['email'];
        profile = data['userProfile'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user info')),
      );
    }
  }

  Future<void> _submitNameChange() async {
    final response = await authenticatedRequest(
      context: context,
      url: Uri.parse('$BASE_URL/users'),
      method: 'PUT',
      body: {
        'name': nameController.text,
      },
    );

    if (response.statusCode == 200) {
      if (!mounted) return;
      setState(() => isEditingName = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update name')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (onServer) {
      _loadUserInfo();
    }
    else {
      profile = 1;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile")
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                // Profile Image
                Container(
                  margin: const EdgeInsets.only(bottom: 24), // 원하는 마진 테두리 안쪽 여백
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.lightBlueAccent, width: 2), // 테두리
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      profileImages[profile],
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 100),
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // 수정 버튼
                Positioned(
                  bottom: 28,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _showProfileImagePicker(context),
                    child: Container(
                    width:36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          spreadRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.edit,
                        size: 25,
                        color: Colors.grey,
                    ),
                    ),
                  ),
                  ),
                ),
              ],
            ),
            _buildRoundedField(
              controller: nameController,
              label: 'Name',
              readOnly: !isEditingName,
              suffixIcon: isEditingName
                  ? IconButton(
                icon: const Icon(Icons.check),
                onPressed: _submitNameChange,
              )
                  : IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  if (!mounted) return;
                  setState(() => isEditingName = true);
                },
              ),
            ),
            _buildRoundedField(
              controller: emailController,
              label: 'Email',
              readOnly: true,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _showChangePasswordDialog,
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: 400,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: profileImages.length,
            itemBuilder: (context, index) {
              final imagePath = profileImages[index];
              return GestureDetector(
                onTap: () async {
                  final response = await authenticatedRequest(
                    context: context,
                    url: Uri.parse('$BASE_URL/users/profile'),
                    method: 'PUT',
                    body: {
                      'userProfile': index,
                    },
                  );

                  if (response.statusCode == 200) {
                    if (!mounted) return;
                    setState(() {
                      profile = index;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile Image updated successfully')),
                    );
                  } 
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update profile image')),
                    );
                  }

                  Navigator.pop(context);
                },
                child: ClipOval(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final currentPwController = TextEditingController();
    final newPwController = TextEditingController();
    final confirmPwController = TextEditingController();
    bool isMatch = false;
    bool isWrong = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void validateMatch() {
              if (!mounted) return;
              setState(() {
                isMatch = newPwController.text.isNotEmpty &&
                    confirmPwController.text.isNotEmpty &&
                    newPwController.text == confirmPwController.text;
              });
            }

            Future<void> submit() async {
              final response = await authenticatedRequest(
                context: context,
                url: Uri.parse('$BASE_URL/users/change-password'),
                method: 'POST',
                body: {
                  'currentPassword': currentPwController.text,
                  'newPassword': newPwController.text,
                },
              );

              if (response.statusCode == 200) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully')),
                );
              } else if (response.statusCode == 400) {
                if (!mounted) return;
                setState(() => isWrong = true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to change password')),
                );
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _styledField(
                      controller: currentPwController,
                      label: 'Current Password',
                      isError: isWrong,
                      obscure: true,
                      errorText: isWrong ? 'Incorrect password' : null,
                    ),
                    const SizedBox(height: 12),
                    _styledField(
                      controller: newPwController,
                      label: 'New Password',
                      obscure: true,
                      onChanged: (_) => validateMatch(),
                    ),
                    const SizedBox(height: 12),
                    _styledField(
                      controller: confirmPwController,
                      label: 'Confirm Password',
                      obscure: true,
                      isError: confirmPwController.text.isNotEmpty &&
                          newPwController.text != confirmPwController.text,
                      errorText: confirmPwController.text.isNotEmpty &&
                          newPwController.text != confirmPwController.text
                          ? 'Passwords do not match'
                          : null,
                      onChanged: (_) => validateMatch(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: isMatch ? submit : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF395BA9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Change'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _styledField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    String? errorText,
    bool isError = false,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: Colors.grey[100],
        errorText: errorText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF395BA9), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildRoundedField({
    required TextEditingController controller,
    required String label,
    bool readOnly = true,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}