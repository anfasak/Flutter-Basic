import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/vlog.dart';

class HiveService {
  static const String _boxName = 'vlogs';
  static bool _isInitialized = false;
  static late Box<Vlog> _box;

  static Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    Hive.registerAdapter(VlogAdapter());
    _box = await Hive.openBox<Vlog>(_boxName);
    _isInitialized = true;
  }

  static Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  static Box<Vlog> get box => _box;

  static Future<void> saveVlog(Vlog vlog) async {
    await ensureInitialized();
    await _box.put(vlog.id, vlog);
  }

  static Future<void> deleteVlog(String id) async {
    await ensureInitialized();
    await _box.delete(id);
  }

  static Future<List<Vlog>> getAllVlogs() async {
    await ensureInitialized();
    return _box.values.toList();
  }

  static Future<void> clearAll() async {
    await ensureInitialized();
    await _box.clear();
  }
}
