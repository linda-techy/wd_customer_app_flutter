import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';
import '../../models/lead_models.dart';
import '../../services/lead_service.dart';

class NewEnquiryScreen extends StatefulWidget {
  const NewEnquiryScreen({super.key});

  @override
  State<NewEnquiryScreen> createState() => _NewEnquiryScreenState();
}

class _NewEnquiryScreenState extends State<NewEnquiryScreen> {
  static const Color _brand = Color(0xFFD84940);

  final _formKey = GlobalKey<FormState>();

  String _projectType = '';
  final _stateCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _requirementsCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _stateCtrl.dispose();
    _districtCtrl.dispose();
    _locationCtrl.dispose();
    _budgetCtrl.dispose();
    _areaCtrl.dispose();
    _requirementsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_projectType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a project type'),
          backgroundColor: _brand,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final request = NewEnquiryRequest(
      projectType: _projectType,
      state: _stateCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      budget: _budgetCtrl.text.trim(),
      area: _areaCtrl.text.trim(),
      requirements: _requirementsCtrl.text.trim(),
    );

    final success = await LeadService.submitEnquiry(request);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enquiry submitted successfully! Our team will contact you soon.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit enquiry. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('New Project Enquiry'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Info banner ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _brand.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _brand.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: _brand, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Tell us about your project and we\'ll get in touch with a proposal.',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Project type ─────────────────────────────────────────────
              _buildSectionHeader('Project Type', Icons.home_work_outlined),
              const SizedBox(height: 12),
              _buildDropdownField(
                label: 'Project Type *',
                value: _projectType.isEmpty ? null : _projectType,
                icon: Icons.home_work_outlined,
                items: const [
                  DropdownMenuItem(value: 'Apartment', child: Text('Apartment')),
                  DropdownMenuItem(value: 'Villa', child: Text('Villa')),
                  DropdownMenuItem(value: 'Office Space', child: Text('Office Space')),
                  DropdownMenuItem(value: 'Commercial', child: Text('Commercial')),
                  DropdownMenuItem(value: 'Residential', child: Text('Residential')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _projectType = v ?? ''),
              ),
              const SizedBox(height: 24),

              // ── Location ─────────────────────────────────────────────────
              _buildSectionHeader('Location', Icons.location_on_outlined),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _stateCtrl,
                label: 'State *',
                hint: 'e.g. Kerala',
                icon: Icons.map_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'State is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _districtCtrl,
                label: 'District *',
                hint: 'e.g. Thrissur',
                icon: Icons.location_city_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'District is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationCtrl,
                label: 'Location / Area (Optional)',
                hint: 'e.g. Palarivattom, Kakkanad',
                icon: Icons.place_outlined,
              ),
              const SizedBox(height: 24),

              // ── Project details ───────────────────────────────────────────
              _buildSectionHeader('Project Details', Icons.construction_outlined),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _budgetCtrl,
                label: 'Estimated Budget (Optional)',
                hint: 'e.g. 50 Lakhs, 1 Crore',
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _areaCtrl,
                label: 'Estimated Area in sqft (Optional)',
                hint: 'e.g. 2000',
                icon: Icons.square_foot_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _requirementsCtrl,
                label: 'Requirements / Notes (Optional)',
                hint: 'Describe your project requirements, preferences, or any questions...',
                icon: Icons.notes_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // ── Submit button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Submit Enquiry',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _brand, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _brand, size: 20),
        filled: true,
        fillColor: Theme.of(context).cardTheme.color ?? Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _brand, size: 20),
        filled: true,
        fillColor: Theme.of(context).cardTheme.color ?? Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brand, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
