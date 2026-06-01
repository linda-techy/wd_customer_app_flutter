import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/lead_models.dart';

void main() {
  group('CustomerLead.fromJson', () {
    test('parses a real-shaped lead payload', () {
      final json = {
        'id': 7,
        'name': 'Krishnan R',
        'email': 'krishnan@example.com',
        'phone': '+919876543210',
        'projectType': 'NEW_BUILD',
        'budget': '50-75 Lakhs',
        'area': '2400 sqft',
        'location': 'Kakkanad',
        'district': 'Ernakulam',
        'state': 'Kerala',
        'status': 'Processing',
        'internalStatus': 'contacted',
        'source': 'WEBSITE',
        'nextFollowUp': '2026-06-10',
        'createdAt': '2026-05-01T10:00:00',
      };

      final lead = CustomerLead.fromJson(json);

      expect(lead.id, 7);
      expect(lead.name, 'Krishnan R');
      expect(lead.email, 'krishnan@example.com');
      expect(lead.phone, '+919876543210');
      expect(lead.projectType, 'NEW_BUILD');
      expect(lead.budget, '50-75 Lakhs');
      expect(lead.area, '2400 sqft');
      expect(lead.location, 'Kakkanad');
      expect(lead.district, 'Ernakulam');
      expect(lead.state, 'Kerala');
      expect(lead.status, 'Processing');
      expect(lead.internalStatus, 'contacted');
      expect(lead.source, 'WEBSITE');
      expect(lead.nextFollowUp, '2026-06-10');
      expect(lead.createdAt, '2026-05-01T10:00:00');
      // internalStatus 'contacted' -> step index 1
      expect(lead.statusStepIndex, 1);
    });

    test('applies defaults on empty json', () {
      final lead = CustomerLead.fromJson({});

      expect(lead.id, 0);
      expect(lead.name, '');
      expect(lead.email, '');
      expect(lead.phone, '');
      expect(lead.projectType, '');
      expect(lead.budget, '');
      expect(lead.area, '');
      expect(lead.location, '');
      expect(lead.district, '');
      expect(lead.state, '');
      expect(lead.status, 'Processing'); // default
      expect(lead.internalStatus, '');
      expect(lead.source, '');
      expect(lead.nextFollowUp, isNull);
      expect(lead.createdAt, '');
      // empty internalStatus -> default step 0
      expect(lead.statusStepIndex, 0);
    });

    test('id falls back to int.tryParse for string ids', () {
      final lead = CustomerLead.fromJson({'id': '42'});
      expect(lead.id, 42);
    });

    test('statusStepIndex maps each known internal status', () {
      expect(
          CustomerLead.fromJson({'internalStatus': 'new_inquiry'})
              .statusStepIndex,
          0);
      expect(
          CustomerLead.fromJson({'internalStatus': 'contacted'})
              .statusStepIndex,
          1);
      expect(
          CustomerLead.fromJson({'internalStatus': 'qualified'})
              .statusStepIndex,
          2);
      expect(
          CustomerLead.fromJson({'internalStatus': 'proposal_sent'})
              .statusStepIndex,
          3);
      expect(
          CustomerLead.fromJson({'internalStatus': 'negotiation'})
              .statusStepIndex,
          4);
      expect(
          CustomerLead.fromJson({'internalStatus': 'converted'})
              .statusStepIndex,
          5);
      expect(
          CustomerLead.fromJson({'internalStatus': 'project_won'})
              .statusStepIndex,
          5);
      // unknown status collapses to 0
      expect(
          CustomerLead.fromJson({'internalStatus': 'whatever'})
              .statusStepIndex,
          0);
    });

    test('statusSteps exposes the 6 stepper labels', () {
      expect(CustomerLead.statusSteps.length, 6);
      expect(CustomerLead.statusSteps.first, 'Enquiry Received');
      expect(CustomerLead.statusSteps.last, 'Project Started');
    });
  });

  group('ReferralLead.fromJson', () {
    test('parses a real-shaped referral payload', () {
      final json = {
        'id': 3,
        'friendName': 'Anil Kumar',
        'friendPhone': '9123456780',
        'projectType': 'RENOVATION',
        'status': 'Contacted',
        'createdAt': '2026-05-02T09:00:00',
      };

      final ref = ReferralLead.fromJson(json);

      expect(ref.id, 3);
      expect(ref.friendName, 'Anil Kumar');
      expect(ref.friendPhone, '9123456780');
      expect(ref.projectType, 'RENOVATION');
      expect(ref.status, 'Contacted');
      expect(ref.createdAt, '2026-05-02T09:00:00');
    });

    test('applies defaults on empty json', () {
      final ref = ReferralLead.fromJson({});

      expect(ref.id, 0);
      expect(ref.friendName, '');
      expect(ref.friendPhone, '');
      expect(ref.projectType, '');
      expect(ref.status, 'Processing'); // default
      expect(ref.createdAt, '');
    });

    test('non-int id collapses to 0', () {
      final ref = ReferralLead.fromJson({'id': '5'});
      expect(ref.id, 0); // only literal int retained
    });
  });

  group('NewEnquiryRequest.toJson', () {
    test('serializes required fields and omits empty optionals', () {
      const req = NewEnquiryRequest(
        projectType: 'NEW_BUILD',
        state: 'Kerala',
        district: 'Ernakulam',
        location: '',
        budget: null,
      );

      final json = req.toJson();

      expect(json['projectType'], 'NEW_BUILD');
      expect(json['state'], 'Kerala');
      expect(json['district'], 'Ernakulam');
      expect(json.containsKey('location'), isFalse);
      expect(json.containsKey('budget'), isFalse);
      expect(json.containsKey('area'), isFalse);
      expect(json.containsKey('requirements'), isFalse);
    });

    test('includes non-empty optionals', () {
      const req = NewEnquiryRequest(
        projectType: 'NEW_BUILD',
        state: 'Kerala',
        district: 'Ernakulam',
        location: 'Kakkanad',
        budget: '50L',
        area: '2400',
        requirements: 'G+1',
      );

      final json = req.toJson();

      expect(json['location'], 'Kakkanad');
      expect(json['budget'], '50L');
      expect(json['area'], '2400');
      expect(json['requirements'], 'G+1');
    });
  });
}
