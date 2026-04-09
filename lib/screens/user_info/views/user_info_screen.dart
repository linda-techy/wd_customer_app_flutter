import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';
import '../../../constants.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/scale_button.dart';
import '../../../services/auth_service.dart';
import '../../../config/api_config.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();

  // State
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userInfo = await AuthService.getUserInfo();
      if (userInfo != null && mounted) {
        setState(() {
          _firstNameController.text = userInfo.firstName;
          _lastNameController.text = userInfo.lastName;
          _emailController.text = userInfo.email;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        _showSnackBar('Please log in again to save changes', isError: true);
        return;
      }

      final dio = Dio(BaseOptions(
        connectTimeout: ApiConfig.connectionTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
      ));
      final response = await dio.put(
        '${ApiConfig.baseUrl}/auth/profile',
        data: {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'whatsapp': _whatsappController.text.trim(),
        },
        options: Options(
          headers: ApiConfig.getAuthHeaders(token),
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() => _isEditing = false);
          _showSnackBar('Profile updated successfully');
        }
      } else {
        _showSnackBar('Failed to save profile (${response.statusCode})', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error saving profile: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? errorColor : successColor,
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      children: [
                        FadeEntry(
                          delay: 200.ms,
                          child: _buildInfoCard(),
                        ),
                        const SizedBox(height: defaultPadding * 2),
                        FadeEntry(
                          delay: 300.ms,
                          child: _buildActionButtons(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: surfaceColor,
      surfaceTintColor: surfaceColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withOpacity(0.1),
                    surfaceColor,
                  ],
                ),
              ),
            ),
            // Decorative Circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.05),
                ),
              ),
            ),
            // Profile Image
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: blackColor.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFFD32F2F),
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      if (_isEditing)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ).animate().scale(delay: 500.ms, duration: 400.ms),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isEditing ? primaryColor.withOpacity(0.1) : Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    _isEditing ? Icons.check : Icons.edit,
                    color: _isEditing ? primaryColor : blackColor,
                  ),
                  onPressed: () {
                    if (_isEditing) {
                      _saveProfile();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: blackColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personal Information",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField("First Name", Icons.person_outline, _firstNameController),
          const SizedBox(height: 20),
          _buildTextField("Last Name", Icons.person_outline, _lastNameController),
          const SizedBox(height: 20),
          _buildTextField("Email Address", Icons.email_outlined, _emailController, readOnly: true),
          const SizedBox(height: 20),
          _buildTextField("Phone Number", Icons.phone_outlined, _phoneController),
          const SizedBox(height: 20),
          _buildTextField("WhatsApp Number", Icons.chat_outlined, _whatsappController),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool readOnly = false}) {
    final effectivelyEditing = _isEditing && !readOnly;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: blackColor60,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: effectivelyEditing ? surfaceColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: effectivelyEditing ? primaryColor.withOpacity(0.2) : Colors.transparent,
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: effectivelyEditing,
            readOnly: readOnly,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: readOnly ? blackColor60 : blackColor,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: effectivelyEditing ? primaryColor : blackColor40),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: readOnly
                  ? const Icon(Icons.lock_outline, size: 16, color: blackColor40)
                  : null,
            ),
          ),
        ),
        if (!_isEditing)
          Container(height: 1, color: blackColor10, margin: const EdgeInsets.only(top: 8)),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_isEditing) {
      return Row(
        children: [
          Expanded(
            child: ScaleButton(
              onTap: _isSaving ? null : () {
                _loadUserData(); // Reset to saved values
                setState(() => _isEditing = false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: blackColor10),
                ),
                child: const Center(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ScaleButton(
              onTap: _isSaving ? null : _saveProfile,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _isSaving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Save Changes",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Account Security",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  "Your information is secure and private",
                  style: TextStyle(color: blackColor60, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
