import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/vlog.dart';
import 'hive_service.dart';

class VlogProvider extends ChangeNotifier {
  static const List<String> statusOptions = [
    'All',
    'Idea',
    'Draft',
    'Recording',
    'Editing',
    'Scheduled',
    'Published'
  ];

  static const List<String> platformOptions = [
    'All',
    'YouTube',
    'Instagram',
    'Facebook',
    'TikTok',
    'LinkedIn',
    'Blog'
  ];

  final List<Vlog> _vlogs = [];
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedPlatform = 'All';
  bool _isSortedByDate = true;

  List<Vlog> get vlogs => _vlogs;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  String get selectedPlatform => _selectedPlatform;
  bool get isSortedByDate => _isSortedByDate;

  List<Vlog> get filteredVlogs {
    final query = _searchQuery.trim().toLowerCase();

    final result = _vlogs.where((vlog) {
      final matchesSearch = query.isEmpty ||
          vlog.title.toLowerCase().contains(query) ||
          vlog.description.toLowerCase().contains(query) ||
          vlog.category.toLowerCase().contains(query);
      final matchesStatus = _selectedStatus == 'All' || vlog.status == _selectedStatus;
      final matchesPlatform =
          _selectedPlatform == 'All' || vlog.platform == _selectedPlatform;
      return matchesSearch && matchesStatus && matchesPlatform;
    }).toList()
      ..sort((a, b) {
        if (_isSortedByDate) {
          return b.uploadDate.compareTo(a.uploadDate);
        }
        return a.uploadDate.compareTo(b.uploadDate);
      });

    return result;
  }

  List<Vlog> get favoriteVlogs => _vlogs.where((vlog) => vlog.isFavorite).toList();

  int get totalContent => _vlogs.length;

  int get ideasCount => _vlogs.where((vlog) => vlog.status == 'Idea').length;
  int get draftsCount => _vlogs.where((vlog) => vlog.status == 'Draft').length;
  int get scheduledCount => _vlogs.where((vlog) => vlog.status == 'Scheduled').length;
  int get publishedCount => _vlogs.where((vlog) => vlog.status == 'Published').length;

  Future<void> loadVlogs() async {
    final stored = await HiveService.getAllVlogs();
    _vlogs
      ..clear()
      ..addAll(stored);
    notifyListeners();
  }

  Future<void> addVlog(Vlog vlog) async {
    final newVlog = vlog.copyWith(id: vlog.id.isEmpty ? const Uuid().v4() : vlog.id);
    await HiveService.saveVlog(newVlog);
    _vlogs.add(newVlog);
    notifyListeners();
  }

  Future<void> updateVlog(Vlog vlog) async {
    await HiveService.saveVlog(vlog);
    final index = _vlogs.indexWhere((item) => item.id == vlog.id);
    if (index != -1) {
      _vlogs[index] = vlog;
    }
    notifyListeners();
  }

  Future<void> deleteVlog(String id) async {
    await HiveService.deleteVlog(id);
    _vlogs.removeWhere((vlog) => vlog.id == id);
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _vlogs.indexWhere((vlog) => vlog.id == id);
    if (index != -1) {
      _vlogs[index] = _vlogs[index].copyWith(isFavorite: !_vlogs[index].isFavorite);
      HiveService.saveVlog(_vlogs[index]);
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setSelectedStatus(String value) {
    _selectedStatus = value;
    notifyListeners();
  }

  void setSelectedPlatform(String value) {
    _selectedPlatform = value;
    notifyListeners();
  }

  void toggleSortByDate() {
    _isSortedByDate = !_isSortedByDate;
    notifyListeners();
  }
}
