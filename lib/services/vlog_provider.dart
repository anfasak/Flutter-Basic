import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/vlog.dart';
import 'hive_service.dart';

class VlogProvider extends ChangeNotifier {
  final List<Vlog> _vlogs = [];
  String _searchQuery = '';
  String _selectedStatus = 'All';
  bool _isSortedByDate = false;

  List<Vlog> get vlogs => _vlogs;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  bool get isSortedByDate => _isSortedByDate;

  List<Vlog> get filteredVlogs {
    final query = _searchQuery.toLowerCase();

    return _vlogs.where((vlog) {
      final matchesSearch = vlog.title.toLowerCase().contains(query) ||
          vlog.description.toLowerCase().contains(query);
      final matchesStatus = _selectedStatus == 'All' || vlog.status == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList()
      ..sort((a, b) {
        if (_isSortedByDate) {
          return a.uploadDate.compareTo(b.uploadDate);
        }
        return b.uploadDate.compareTo(a.uploadDate);
      });
  }

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

  void toggleSortByDate() {
    _isSortedByDate = !_isSortedByDate;
    notifyListeners();
  }
}
