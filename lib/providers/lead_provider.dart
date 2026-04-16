import 'package:flutter/material.dart';
import '../models/lead_models.dart';
import '../services/lead_service.dart';

class LeadProvider with ChangeNotifier {
  List<CustomerLead> _leads = [];
  List<ReferralLead> _referrals = [];
  CustomerLead? _selectedLead;
  bool _isLoading = false;
  String? _error;

  List<CustomerLead> get leads => _leads;
  List<ReferralLead> get referrals => _referrals;
  CustomerLead? get selectedLead => _selectedLead;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMyLeads() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _leads = await LeadService.getMyLeads();
      _error = null;
    } catch (e) {
      _error = 'Failed to load enquiries';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyReferrals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final referralsData = await LeadService.getMyReferrals();
      _referrals = referralsData
          .map((e) => ReferralLead.fromJson(e as Map<String, dynamic>))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load referrals';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLeadDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedLead = await LeadService.getLeadDetail(id);
      _error = null;
    } catch (e) {
      _error = 'Failed to load enquiry details';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitEnquiry(NewEnquiryRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await LeadService.submitEnquiry(request);
      if (success) {
        // Refresh leads list to include the new enquiry
        await fetchMyLeads();
      }
      return success;
    } catch (e) {
      _error = 'Failed to submit enquiry';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedLead() {
    _selectedLead = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
