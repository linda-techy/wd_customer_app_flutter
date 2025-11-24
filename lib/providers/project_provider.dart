import 'package:flutter/material.dart';
import '../models/project_models.dart';
import '../repositories/project_repository.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectRepository _repository;

  ProjectProvider(this._repository);

  // State variables
  List<Project> _projects = [];
  Project? _selectedProject;
  List<Document> _documents = [];
  List<QCItem> _qcItems = [];
  List<Query> _queries = [];
  List<ProjectActivity> _activities = [];
  List<Payment> _payments = [];
  List<GalleryPhoto> _galleryPhotos = [];
  List<SurveillanceCamera> _cameras = [];
  List<ProgressDataPoint> _progressData = [];

  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  ProjectStatus? _filterStatus;
  String _sortBy = 'lastUpdated';

  // Getters
  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  List<Document> get documents => _documents;
  List<QCItem> get qcItems => _qcItems;
  List<Query> get queries => _queries;
  List<ProjectActivity> get activities => _activities;
  List<Payment> get payments => _payments;
  List<GalleryPhoto> get galleryPhotos => _galleryPhotos;
  List<SurveillanceCamera> get cameras => _cameras;
  List<ProgressDataPoint> get progressData => _progressData;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  ProjectStatus? get filterStatus => _filterStatus;
  String get sortBy => _sortBy;

  // Filtered and sorted projects
  List<Project> get filteredProjects {
    List<Project> filtered = _projects;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((project) =>
              project.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              project.location
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              project.city.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply status filter
    if (_filterStatus != null) {
      filtered =
          filtered.where((project) => project.status == _filterStatus).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'progress':
        filtered.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'lastUpdated':
        filtered.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
        break;
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return filtered;
  }

  // Project methods
  Future<void> loadProjects() async {
    _setLoading(true);
    try {
      _projects = await _repository.getProjects();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProject(String projectId) async {
    _setLoading(true);
    try {
      _selectedProject = await _repository.getProjectById(projectId);
      if (_selectedProject != null) {
        await _loadProjectDetails(projectId);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadProjectDetails(String projectId) async {
    try {
      // Load all project details in parallel
      final futures = await Future.wait([
        _repository.getDocuments(projectId),
        _repository.getQCItems(projectId),
        _repository.getQueries(projectId),
        _repository.getProjectActivities(projectId),
        _repository.getPayments(projectId),
        _repository.getGalleryPhotos(projectId),
        _repository.getSurveillanceCameras(projectId),
        _repository.getProgressData(projectId),
      ]);

      _documents = futures[0] as List<Document>;
      _qcItems = futures[1] as List<QCItem>;
      _queries = futures[2] as List<Query>;
      _activities = futures[3] as List<ProjectActivity>;
      _payments = futures[4] as List<Payment>;
      _galleryPhotos = futures[5] as List<GalleryPhoto>;
      _cameras = futures[6] as List<SurveillanceCamera>;
      _progressData = futures[7] as List<ProgressDataPoint>;
    } catch (e) {
      _error = e.toString();
    }
  }

  // Search and filter methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(ProjectStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _sortBy = 'lastUpdated';
    notifyListeners();
  }

  // QC methods
  Future<bool> updateQCStatus(
      String qcId, QCStatus status, String comments) async {
    try {
      final success = await _repository.updateQCStatus(qcId, status, comments);
      if (success) {
        // Update local state
        final index = _qcItems.indexWhere((item) => item.id == qcId);
        if (index != -1) {
          _qcItems[index] = QCItem(
            id: _qcItems[index].id,
            title: _qcItems[index].title,
            description: _qcItems[index].description,
            status: status,
            dueDate: _qcItems[index].dueDate,
            assignedTo: _qcItems[index].assignedTo,
            photos: _qcItems[index].photos,
            comments: comments,
            correctiveActions: _qcItems[index].correctiveActions,
            createdAt: _qcItems[index].createdAt,
            completedAt: status == QCStatus.completed ? DateTime.now() : null,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Query methods
  Future<String?> createQuery(String projectId, Query query) async {
    try {
      final queryId = await _repository.createQuery(projectId, query);
      // Refresh queries list
      _queries = await _repository.getQueries(projectId);
      notifyListeners();
      return queryId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> addQueryMessage(String queryId, QueryMessage message) async {
    try {
      final success = await _repository.addQueryMessage(queryId, message);
      if (success && _selectedProject != null) {
        // Refresh queries list
        _queries = await _repository.getQueries(_selectedProject!.id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateQueryStatus(String queryId, QueryStatus status) async {
    try {
      final success = await _repository.updateQueryStatus(queryId, status);
      if (success && _selectedProject != null) {
        // Refresh queries list
        _queries = await _repository.getQueries(_selectedProject!.id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Download methods
  Future<String> downloadDocument(String documentId) async {
    try {
      return await _repository.downloadDocument(documentId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<String> downloadInvoice(String paymentId) async {
    try {
      return await _repository.downloadInvoice(paymentId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Refresh methods
  Future<void> refreshProjects() async {
    await loadProjects();
  }

  Future<void> refreshProjectDetails() async {
    if (_selectedProject != null) {
      await _loadProjectDetails(_selectedProject!.id);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if user has single project
  bool get hasSingleProject => _projects.length == 1;

  // Get single project if available
  Project? get singleProject => hasSingleProject ? _projects.first : null;
}
