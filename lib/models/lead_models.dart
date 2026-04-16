class CustomerLead {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String projectType;
  final String budget;
  final String area;
  final String location;
  final String district;
  final String state;
  final String status;
  final String internalStatus;
  final String source;
  final String? nextFollowUp;
  final String createdAt;

  const CustomerLead({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.projectType,
    required this.budget,
    required this.area,
    required this.location,
    required this.district,
    required this.state,
    required this.status,
    required this.internalStatus,
    required this.source,
    this.nextFollowUp,
    required this.createdAt,
  });

  factory CustomerLead.fromJson(Map<String, dynamic> json) => CustomerLead(
    id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
    name: json['name']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    projectType: json['projectType']?.toString() ?? '',
    budget: json['budget']?.toString() ?? '',
    area: json['area']?.toString() ?? '',
    location: json['location']?.toString() ?? '',
    district: json['district']?.toString() ?? '',
    state: json['state']?.toString() ?? '',
    status: json['status']?.toString() ?? 'Processing',
    internalStatus: json['internalStatus']?.toString() ?? '',
    source: json['source']?.toString() ?? '',
    nextFollowUp: json['nextFollowUp']?.toString(),
    createdAt: json['createdAt']?.toString() ?? '',
  );

  // Status step index for the stepper (0-based)
  int get statusStepIndex {
    return switch (internalStatus.toLowerCase()) {
      'new_inquiry' => 0,
      'contacted' => 1,
      'qualified' => 2,
      'proposal_sent' => 3,
      'negotiation' => 4,
      'converted' => 5,
      _ => 0,
    };
  }

  static const List<String> statusSteps = [
    'Enquiry Received',
    'Contacted',
    'Under Review',
    'Proposal Sent',
    'In Discussion',
    'Project Started',
  ];
}

class NewEnquiryRequest {
  final String projectType;
  final String state;
  final String district;
  final String? location;
  final String? budget;
  final String? area;
  final String? requirements;

  const NewEnquiryRequest({
    required this.projectType,
    required this.state,
    required this.district,
    this.location,
    this.budget,
    this.area,
    this.requirements,
  });

  Map<String, dynamic> toJson() => {
    'projectType': projectType,
    'state': state,
    'district': district,
    if (location != null && location!.isNotEmpty) 'location': location,
    if (budget != null && budget!.isNotEmpty) 'budget': budget,
    if (area != null && area!.isNotEmpty) 'area': area,
    if (requirements != null && requirements!.isNotEmpty) 'requirements': requirements,
  };
}
