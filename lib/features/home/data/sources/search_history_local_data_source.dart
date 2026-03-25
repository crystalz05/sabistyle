import 'package:shared_preferences/shared_preferences.dart';

abstract class SearchHistoryLocalDataSource {
  Future<List<String>> getSearchHistory();
  Future<void> saveSearchQuery(String query);
  Future<void> clearSearchHistory();
}

class SearchHistoryLocalDataSourceImpl implements SearchHistoryLocalDataSource {
  final SharedPreferences _sharedPreferences;
  static const String _key = 'search_history';

  SearchHistoryLocalDataSourceImpl({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  @override
  Future<List<String>> getSearchHistory() async {
    final history = _sharedPreferences.getStringList(_key) ?? [];
    return List<String>.from(history);
  }

  @override
  Future<void> saveSearchQuery(String query) async {
    if (query.trim().isEmpty) return;

    final history = await getSearchHistory();
    // Remove if exists to move to top
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase().trim());
    // Add to top
    history.insert(0, query.trim());
    
    // Keep only last 4
    final limitedHistory = history.take(4).toList();
    
    await _sharedPreferences.setStringList(_key, limitedHistory);
  }

  @override
  Future<void> clearSearchHistory() async {
    await _sharedPreferences.remove(_key);
  }
}
