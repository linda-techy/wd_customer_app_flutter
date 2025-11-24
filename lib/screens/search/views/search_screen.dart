import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../utils/responsive.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  String selectedCategory = 'All';

  // Construction-specific search categories
  final List<String> categories = [
    'All',
    'Services',
    'Projects',
    'Materials',
    'Documents',
    'FAQs',
  ];

  // Construction services data
  final List<Map<String, dynamic>> constructionServices = [
    {
      'title': 'House Construction',
      'category': 'Services',
      'description':
          'Complete residential construction from foundation to finishing',
      'icon': Icons.home_rounded,
      'tags': ['residential', 'villa', 'home', 'house building'],
    },
    {
      'title': 'Commercial Building',
      'category': 'Services',
      'description': 'Office buildings, showrooms, and commercial spaces',
      'icon': Icons.business_rounded,
      'tags': ['commercial', 'office', 'showroom', 'retail'],
    },
    {
      'title': 'Interior Design',
      'category': 'Services',
      'description': 'Modern interior design and execution services',
      'icon': Icons.design_services_rounded,
      'tags': ['interior', 'design', 'modular kitchen', 'furnishing'],
    },
    {
      'title': 'Renovation & Remodeling',
      'category': 'Services',
      'description': 'Transform your existing space with expert renovation',
      'icon': Icons.home_repair_service_rounded,
      'tags': ['renovation', 'remodeling', 'reconstruction', 'repair'],
    },
    {
      'title': 'Floor Plan Design',
      'category': 'Services',
      'description': 'Custom floor plans designed by expert architects',
      'icon': Icons.architecture_rounded,
      'tags': ['floor plan', 'design', 'architect', 'blueprint'],
    },
    {
      'title': '3D Visualization',
      'category': 'Services',
      'description': 'See your dream home before construction starts',
      'icon': Icons.view_in_ar_rounded,
      'tags': ['3d', 'visualization', 'rendering', 'virtual tour'],
    },
    {
      'title': 'Steel & TMT Bars',
      'category': 'Materials',
      'description': 'Premium quality steel and TMT bars for construction',
      'icon': Icons.hardware_rounded,
      'tags': ['steel', 'tmt', 'iron', 'bars', 'materials'],
    },
    {
      'title': 'Cement & Concrete',
      'category': 'Materials',
      'description': 'High-grade cement and RMC concrete supply',
      'icon': Icons.foundation_rounded,
      'tags': ['cement', 'concrete', 'rmc', 'building material'],
    },
    {
      'title': 'Bricks & Blocks',
      'category': 'Materials',
      'description': 'Quality bricks, blocks, and masonry materials',
      'icon': Icons.view_module_rounded,
      'tags': ['bricks', 'blocks', 'aac', 'red brick', 'fly ash'],
    },
    {
      'title': 'Villa Project - Whitefield',
      'category': 'Projects',
      'description': '3BHK luxury villa completed in 8 months',
      'icon': Icons.villa_rounded,
      'tags': ['villa', 'completed', '3bhk', 'luxury', 'whitefield'],
    },
    {
      'title': 'Office Complex - Koramangala',
      'category': 'Projects',
      'description': '5-floor commercial building with modern amenities',
      'icon': Icons.corporate_fare_rounded,
      'tags': ['office', 'commercial', 'completed', 'koramangala'],
    },
    {
      'title': 'Building Permit',
      'category': 'Documents',
      'description': 'How to obtain building permit and approvals',
      'icon': Icons.approval_rounded,
      'tags': ['permit', 'approval', 'license', 'bbmp', 'authority'],
    },
    {
      'title': 'Construction Agreement',
      'category': 'Documents',
      'description': 'Sample construction contract templates',
      'icon': Icons.description_rounded,
      'tags': ['agreement', 'contract', 'legal', 'terms'],
    },
    {
      'title': 'How long does construction take?',
      'category': 'FAQs',
      'description': 'Typical timelines for different construction types',
      'icon': Icons.help_rounded,
      'tags': ['timeline', 'duration', 'time', 'how long', 'period'],
    },
    {
      'title': 'What is the cost per sq ft?',
      'category': 'FAQs',
      'description': 'Construction cost breakdown and estimation',
      'icon': Icons.calculate_rounded,
      'tags': ['cost', 'price', 'rate', 'sq ft', 'budget', 'estimate'],
    },
    {
      'title': 'Payment schedule explained',
      'category': 'FAQs',
      'description': 'Understanding milestone-based payment structure',
      'icon': Icons.payment_rounded,
      'tags': ['payment', 'schedule', 'installment', 'milestone'],
    },
  ];

  // Quick search suggestions
  final List<String> popularSearches = [
    'House construction cost',
    'Villa design ideas',
    'Interior design packages',
    'Building materials',
    'Construction timeline',
    'Floor plan samples',
    'Payment schedule',
    'Quality standards',
  ];

  List<Map<String, dynamic>> get filteredResults {
    List<Map<String, dynamic>> results = constructionServices;

    // Filter by category
    if (selectedCategory != 'All') {
      results = results
          .where((item) => item['category'] == selectedCategory)
          .toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      results = results.where((item) {
        final titleMatch =
            item['title'].toString().toLowerCase().contains(query);
        final descMatch =
            item['description'].toString().toLowerCase().contains(query);
        final tagsMatch = (item['tags'] as List)
            .any((tag) => tag.toString().toLowerCase().contains(query));
        return titleMatch || descMatch || tagsMatch;
      }).toList();
    }

    return results;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [logoRed, logoPink],
            ),
          ),
        ),
        title: const Text(
          "Search Construction Services",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Category Filters
          _buildCategoryFilters(),

          // Results or Suggestions
          Expanded(
            child: searchQuery.isEmpty
                ? _buildSearchSuggestions()
                : filteredResults.isEmpty
                    ? _buildNoResults()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(ResponsiveSpacing.getPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        style: TextStyle(
          fontSize: ResponsiveFontSize.getBody(context),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search services, projects, materials...',
          hintStyle: TextStyle(
            color: logoGreyDark.withOpacity(0.5),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [logoRed, logoPink],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      searchQuery = '';
                    });
                  },
                  icon: Icon(
                    Icons.clear_rounded,
                    color: logoGreyDark,
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: logoGreyLight.withOpacity(0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: logoRed,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveSpacing.getPadding(context),
        vertical: ResponsiveSpacing.getPadding(context) / 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: logoGreyLight.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [logoRed, logoPink],
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : logoGreyLight.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: logoRed.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : logoGreyDark,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        fontSize: ResponsiveFontSize.getBody(context) - 2,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return ListView(
      padding: EdgeInsets.all(ResponsiveSpacing.getPadding(context)),
      children: [
        // Popular Searches Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [logoRed.withOpacity(0.1), logoPink.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.trending_up_rounded,
                color: logoRed,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Popular Searches',
              style: TextStyle(
                fontSize: ResponsiveFontSize.getTitle(context) - 2,
                fontWeight: FontWeight.w700,
                color: logoBackground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Popular Search Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularSearches.map((search) {
            return ActionChip(
              label: Text(search),
              onPressed: () {
                setState(() {
                  _searchController.text = search;
                  searchQuery = search;
                });
              },
              backgroundColor: Colors.white,
              side: BorderSide(
                color: logoRed.withOpacity(0.3),
                width: 1,
              ),
              labelStyle: TextStyle(
                color: logoRed,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveFontSize.getBody(context) - 2,
              ),
              avatar: Icon(
                Icons.search_rounded,
                size: 18,
                color: logoRed,
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 32),

        // Quick Access Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [logoRed.withOpacity(0.1), logoPink.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.bolt_rounded,
                color: logoPink,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Quick Access',
              style: TextStyle(
                fontSize: ResponsiveFontSize.getTitle(context) - 2,
                fontWeight: FontWeight.w700,
                color: logoBackground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Quick Access Categories
        _buildQuickAccessCard(
          'Construction Services',
          'Browse all construction services',
          Icons.construction_rounded,
          logoRed,
          () {
            setState(() {
              selectedCategory = 'Services';
            });
          },
        ),
        const SizedBox(height: 12),
        _buildQuickAccessCard(
          'Completed Projects',
          'View our portfolio of projects',
          Icons.photo_library_rounded,
          logoPink,
          () {
            setState(() {
              selectedCategory = 'Projects';
            });
          },
        ),
        const SizedBox(height: 12),
        _buildQuickAccessCard(
          'Building Materials',
          'Quality materials catalog',
          Icons.inventory_2_rounded,
          const Color(0xFF2E7D32),
          () {
            setState(() {
              selectedCategory = 'Materials';
            });
          },
        ),
        const SizedBox(height: 12),
        _buildQuickAccessCard(
          'Help & FAQs',
          'Get answers to common questions',
          Icons.help_center_rounded,
          const Color(0xFF0288D1),
          () {
            setState(() {
              selectedCategory = 'FAQs';
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(ResponsiveSpacing.getCardPadding(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: logoGreyLight.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveFontSize.getBody(context),
                      fontWeight: FontWeight.w700,
                      color: logoBackground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveFontSize.getBody(context) - 2,
                      color: logoGreyDark.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: logoGreyDark.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveSpacing.getPadding(context)),
      itemCount: filteredResults.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '${filteredResults.length} Results Found',
              style: TextStyle(
                fontSize: ResponsiveFontSize.getBody(context),
                fontWeight: FontWeight.w700,
                color: logoBackground,
              ),
            ),
          );
        }

        final item = filteredResults[index - 1];
        return _buildResultCard(item);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: logoGreyLight.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to relevant screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening: ${item['title']}'),
              backgroundColor: logoRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveSpacing.getCardPadding(context)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      logoRed.withOpacity(0.1),
                      logoPink.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: logoRed.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: logoRed,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: ResponsiveFontSize.getBody(context),
                              fontWeight: FontWeight.w700,
                              color: logoBackground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: logoPink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['category'] as String,
                            style: TextStyle(
                              fontSize: ResponsiveFontSize.getBody(context) - 3,
                              fontWeight: FontWeight.w600,
                              color: logoPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['description'] as String,
                      style: TextStyle(
                        fontSize: ResponsiveFontSize.getBody(context) - 1,
                        color: logoGreyDark.withOpacity(0.8),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: logoGreyDark.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    logoRed.withOpacity(0.1),
                    logoPink.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: logoRed.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: logoRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Results Found',
              style: TextStyle(
                fontSize: ResponsiveFontSize.getTitle(context),
                fontWeight: FontWeight.w700,
                color: logoBackground,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Try different keywords or browse our categories',
                style: TextStyle(
                  fontSize: ResponsiveFontSize.getBody(context),
                  color: logoGreyDark.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  searchQuery = '';
                  selectedCategory = 'All';
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Clear Search',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: logoRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
