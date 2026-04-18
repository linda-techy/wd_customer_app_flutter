class RoleConstants {
  RoleConstants._();

  static const List<String> boqAllowedRoles = ['CUSTOMER', 'ADMIN', 'CUSTOMER_ADMIN'];
  static const List<String> financialAllowedRoles = ['CUSTOMER', 'ADMIN', 'CUSTOMER_ADMIN'];
  static const List<String> allAuthenticatedRoles = [
    'CUSTOMER', 'ADMIN', 'ARCHITECT', 'INTERIOR_DESIGNER',
    'SITE_ENGINEER', 'VIEWER', 'CUSTOMER_ADMIN', 'CONTRACTOR', 'BUILDER',
  ];
}
