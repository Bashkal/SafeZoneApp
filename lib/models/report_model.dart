import 'package:latlong2/latlong.dart';

enum ReportStatus { pending, approved, inProgress, resolved, rejected }

enum ReportCategory {
  roadHazard,
  streetlight,
  graffiti,
  lostPet,
  foundPet,
  parking,
  noise,
  waste,
  other,
}

class Report {
  final String? id;
  final String title;
  final String description;
  final ReportCategory category;
  final List<String> photoUrls;
  final LatLng location;
  final String locationAddress;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ReportStatus status;
  final int likes;
  final int comments;
  final List<String> likedBy;

  Report({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.photoUrls,
    required this.location,
    required this.locationAddress,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.createdAt,
    this.updatedAt,
    this.status = ReportStatus.pending,
    this.likes = 0,
    this.comments = 0,
    this.likedBy = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'photoUrls': photoUrls,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'locationAddress': locationAddress,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status.name,
      'likes': likes,
      'comments': comments,
      'likedBy': likedBy,
    };
  }

  factory Report.fromMap(String id, Map<String, dynamic> map) {
    return Report(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: ReportCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ReportCategory.other,
      ),
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      location: LatLng(map['latitude'] ?? 0.0, map['longitude'] ?? 0.0),
      locationAddress: map['locationAddress'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      status: ReportStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReportStatus.pending,
      ),
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
    );
  }

  Report copyWith({
    String? id,
    String? title,
    String? description,
    ReportCategory? category,
    List<String>? photoUrls,
    LatLng? location,
    String? locationAddress,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    ReportStatus? status,
    int? likes,
    int? comments,
    List<String>? likedBy,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      photoUrls: photoUrls ?? this.photoUrls,
      location: location ?? this.location,
      locationAddress: locationAddress ?? this.locationAddress,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      likedBy: likedBy ?? this.likedBy,
    );
  }

  String getCategoryDisplayName() {
    switch (category) {
      case ReportCategory.roadHazard:
        return 'Road Hazard';
      case ReportCategory.streetlight:
        return 'Streetlight';
      case ReportCategory.graffiti:
        return 'Graffiti';
      case ReportCategory.lostPet:
        return 'Lost Pet';
      case ReportCategory.foundPet:
        return 'Found Pet';
      case ReportCategory.parking:
        return 'Parking Issue';
      case ReportCategory.noise:
        return 'Noise Complaint';
      case ReportCategory.waste:
        return 'Waste Management';
      case ReportCategory.other:
        return 'Other';
    }
  }

  String getStatusDisplayName() {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.approved:
        return 'Approved';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }
}
