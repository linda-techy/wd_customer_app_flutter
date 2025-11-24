// Construction Service Model

class ConstructionService {
  final String id;
  final String name;
  final String description;
  final ServiceCategory category;
  final String? imageUrl;
  final String? icon;
  final List<String> features;
  final double? estimatedPrice;
  final String? priceRange;
  final int? estimatedDuration; // in days
  final bool isPopular;

  ConstructionService({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.imageUrl,
    this.icon,
    this.features = const [],
    this.estimatedPrice,
    this.priceRange,
    this.estimatedDuration,
    this.isPopular = false,
  });

  factory ConstructionService.fromJson(Map<String, dynamic> json) {
    return ConstructionService(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: ServiceCategory.fromString(json['category'] ?? 'residential'),
      imageUrl: json['imageUrl'],
      icon: json['icon'],
      features:
          json['features'] != null ? List<String>.from(json['features']) : [],
      estimatedPrice: json['estimatedPrice']?.toDouble(),
      priceRange: json['priceRange'],
      estimatedDuration: json['estimatedDuration'],
      isPopular: json['isPopular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.toString(),
      'imageUrl': imageUrl,
      'icon': icon,
      'features': features,
      'estimatedPrice': estimatedPrice,
      'priceRange': priceRange,
      'estimatedDuration': estimatedDuration,
      'isPopular': isPopular,
    };
  }

  String get durationDisplay {
    if (estimatedDuration == null) return 'Varies';
    if (estimatedDuration! < 7) return '$estimatedDuration days';
    final weeks = (estimatedDuration! / 7).round();
    if (weeks < 4) return '$weeks weeks';
    final months = (estimatedDuration! / 30).round();
    return '$months months';
  }
}

// Service Category Enum
enum ServiceCategory {
  residential,
  commercial,
  industrial,
  renovation,
  design,
  consultation;

  String get displayName {
    switch (this) {
      case ServiceCategory.residential:
        return 'Residential';
      case ServiceCategory.commercial:
        return 'Commercial';
      case ServiceCategory.industrial:
        return 'Industrial';
      case ServiceCategory.renovation:
        return 'Renovation';
      case ServiceCategory.design:
        return 'Design';
      case ServiceCategory.consultation:
        return 'Consultation';
    }
  }

  static ServiceCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case 'residential':
        return ServiceCategory.residential;
      case 'commercial':
        return ServiceCategory.commercial;
      case 'industrial':
        return ServiceCategory.industrial;
      case 'renovation':
        return ServiceCategory.renovation;
      case 'design':
        return ServiceCategory.design;
      case 'consultation':
        return ServiceCategory.consultation;
      default:
        return ServiceCategory.residential;
    }
  }

  @override
  String toString() {
    return name;
  }
}

// Service Quote Request Model
class ServiceQuoteRequest {
  final String id;
  final String serviceId;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String? location;
  final String description;
  final DateTime requestDate;
  final QuoteRequestStatus status;
  final List<String>? attachments;

  ServiceQuoteRequest({
    required this.id,
    required this.serviceId,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.location,
    required this.description,
    required this.requestDate,
    required this.status,
    this.attachments,
  });

  factory ServiceQuoteRequest.fromJson(Map<String, dynamic> json) {
    return ServiceQuoteRequest(
      id: json['id']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      location: json['location'],
      description: json['description'] ?? '',
      requestDate: json['requestDate'] != null
          ? DateTime.parse(json['requestDate'])
          : DateTime.now(),
      status: QuoteRequestStatus.fromString(json['status'] ?? 'pending'),
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'location': location,
      'description': description,
      'requestDate': requestDate.toIso8601String(),
      'status': status.toString(),
      'attachments': attachments,
    };
  }
}

// Quote Request Status Enum
enum QuoteRequestStatus {
  pending,
  reviewing,
  quoted,
  accepted,
  rejected;

  String get displayName {
    switch (this) {
      case QuoteRequestStatus.pending:
        return 'Pending';
      case QuoteRequestStatus.reviewing:
        return 'Reviewing';
      case QuoteRequestStatus.quoted:
        return 'Quoted';
      case QuoteRequestStatus.accepted:
        return 'Accepted';
      case QuoteRequestStatus.rejected:
        return 'Rejected';
    }
  }

  static QuoteRequestStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return QuoteRequestStatus.pending;
      case 'reviewing':
        return QuoteRequestStatus.reviewing;
      case 'quoted':
        return QuoteRequestStatus.quoted;
      case 'accepted':
        return QuoteRequestStatus.accepted;
      case 'rejected':
        return QuoteRequestStatus.rejected;
      default:
        return QuoteRequestStatus.pending;
    }
  }

  @override
  String toString() {
    return name;
  }
}
