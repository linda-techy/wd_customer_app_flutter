import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/project_module_models.dart';

void main() {
  group('BoqSummary.fromJson', () {
    // Regression lock for the customer BoQ screen showing "₹0" everywhere.
    // The customer endpoint GET /api/projects/{uuid}/boq/summary returns the
    // approved document-level totals as totalValueExGst / totalValueInclGst
    // (NOT totalPlannedAmount). The model previously only read totalPlannedAmount
    // → null → 0.0, so "Planned Budget" and "Total Project Cost" rendered ₹0 even
    // for a fully-approved ₹58.9L contract. Payload mirrors the REAL shape for
    // demo project 49.
    test('reads document totals (totalValueInclGst) when planned amount absent', () {
      final json = {
        'documentId': 7,
        'projectId': 49,
        'totalValueExGst': 4992500.0,
        'totalGstAmount': 898650.0,
        'totalValueInclGst': 5891150.0,
        'gstRate': 0.18,
        'status': 'APPROVED',
        // no totalPlannedAmount / totalItems on the customer payload
      };

      final s = BoqSummary.fromJson(json);

      expect(s.projectId, 49);
      expect(s.totalValueExGst, 4992500.0);
      expect(s.totalValueInclGst, 5891150.0);
      // the all-in contract value drives "Planned Budget" / "Total Project Cost"
      expect(s.totalPlannedAmount, 5891150.0);
    });

    test('still prefers an explicit totalPlannedAmount when the API sends one', () {
      final json = {
        'projectId': 49,
        'totalPlannedAmount': 1234567.0,
        'totalValueInclGst': 5891150.0,
        'status': 'APPROVED',
      };

      final s = BoqSummary.fromJson(json);

      expect(s.totalPlannedAmount, 1234567.0);
    });
  });
}
