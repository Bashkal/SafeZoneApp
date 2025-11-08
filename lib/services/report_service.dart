import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/report_model.dart';

class ReportService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Report> _reports = [];
  List<Report> get reports => _reports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Fetch all reports
  Future<void> fetchReports() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .get();

      _reports = snapshot.docs
          .map((doc) => Report.fromMap(doc.id, doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error fetching reports: $e');
      }
      rethrow;
    }
  }

  // Fetch user's reports
  Future<List<Report>> fetchUserReports(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Report.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user reports: $e');
      }
      rethrow;
    }
  }

  // Upload images to Firebase Storage
  Future<List<String>> uploadImages(List<File> images, String reportId) async {
    List<String> imageUrls = [];

    for (int i = 0; i < images.length; i++) {
      try {
        final ref = _storage.ref().child('reports/$reportId/image_$i.jpg');
        await ref.putFile(images[i]);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      } catch (e) {
        if (kDebugMode) {
          print('Error uploading image: $e');
        }
      }
    }

    return imageUrls;
  }

  // Create a new report
  Future<void> createReport(Report report, List<File> images) async {
    try {
      // Create report document first to get the ID
      final docRef = await _firestore.collection('reports').add(report.toMap());

      // Upload images if any
      if (images.isNotEmpty) {
        final imageUrls = await uploadImages(images, docRef.id);

        // Update report with image URLs
        await docRef.update({'photoUrls': imageUrls});
      }

      // Update user's report count
      await _firestore.collection('users').doc(report.userId).update({
        'reportsSubmitted': FieldValue.increment(1),
      });

      // Refresh reports
      await fetchReports();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating report: $e');
      }
      rethrow;
    }
  }

  // Update a report
  Future<void> updateReport(
    String reportId,
    Report report,
    List<File>? newImages,
  ) async {
    try {
      Map<String, dynamic> updateData = {
        'title': report.title,
        'description': report.description,
        'category': report.category.name,
        'locationAddress': report.locationAddress,
        'latitude': report.location.latitude,
        'longitude': report.location.longitude,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Upload new images if any
      if (newImages != null && newImages.isNotEmpty) {
        final imageUrls = await uploadImages(newImages, reportId);
        updateData['photoUrls'] = [...report.photoUrls, ...imageUrls];
      }

      await _firestore.collection('reports').doc(reportId).update(updateData);
      await fetchReports();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating report: $e');
      }
      rethrow;
    }
  }

  // Delete a report
  Future<void> deleteReport(String reportId, String userId) async {
    try {
      await _firestore.collection('reports').doc(reportId).delete();

      // Update user's report count
      await _firestore.collection('users').doc(userId).update({
        'reportsSubmitted': FieldValue.increment(-1),
      });

      // Delete images from storage
      try {
        final listResult = await _storage
            .ref()
            .child('reports/$reportId')
            .listAll();
        for (var item in listResult.items) {
          await item.delete();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error deleting images: $e');
        }
      }

      await fetchReports();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting report: $e');
      }
      rethrow;
    }
  }

  // Toggle like on a report
  Future<void> toggleLike(String reportId, String userId) async {
    try {
      final reportDoc = _firestore.collection('reports').doc(reportId);
      final report = await reportDoc.get();

      if (!report.exists) return;

      final likedBy = List<String>.from(report.data()?['likedBy'] ?? []);

      if (likedBy.contains(userId)) {
        // Unlike
        await reportDoc.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        // Like
        await reportDoc.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
        });
      }

      await fetchReports();
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling like: $e');
      }
      rethrow;
    }
  }

  // Update report status (admin function)
  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': status.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      await fetchReports();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating report status: $e');
      }
      rethrow;
    }
  }
}
