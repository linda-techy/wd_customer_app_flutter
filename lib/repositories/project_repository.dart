import '../models/project_models.dart';

// Abstract repository interface for project data
abstract class ProjectRepository {
  // Projects
  Future<List<Project>> getProjects();
  Future<Project?> getProjectById(String projectId);
  Future<List<Project>> searchProjects(String query);
  Future<List<Project>> getProjectsByStatus(ProjectStatus status);
  Future<List<Project>> sortProjectsByProgress();
  Future<List<Project>> sortProjectsByLastUpdated();

  // Documents
  Future<List<Document>> getDocuments(String projectId);
  Future<Document?> getDocumentById(String documentId);
  Future<String> downloadDocument(String documentId);

  // Quality Check
  Future<List<QCItem>> getQCItems(String projectId);
  Future<QCItem?> getQCItemById(String qcId);
  Future<bool> updateQCStatus(String qcId, QCStatus status, String comments);

  // Queries
  Future<List<Query>> getQueries(String projectId);
  Future<Query?> getQueryById(String queryId);
  Future<String> createQuery(String projectId, Query query);
  Future<bool> addQueryMessage(String queryId, QueryMessage message);
  Future<bool> updateQueryStatus(String queryId, QueryStatus status);

  // Project Activities
  Future<List<ProjectActivity>> getProjectActivities(String projectId);
  Future<List<ProjectActivity>> getRecentActivities(
      String projectId, int limit);

  // Payments
  Future<List<Payment>> getPayments(String projectId);
  Future<Payment?> getPaymentById(String paymentId);
  Future<String> downloadInvoice(String paymentId);

  // Gallery
  Future<List<GalleryPhoto>> getGalleryPhotos(String projectId);
  Future<GalleryPhoto?> getGalleryPhotoById(String photoId);

  // Surveillance
  Future<List<SurveillanceCamera>> getSurveillanceCameras(String projectId);
  Future<String> getCameraStreamUrl(String cameraId);

  // Progress Data
  Future<List<ProgressDataPoint>> getProgressData(String projectId);
}
