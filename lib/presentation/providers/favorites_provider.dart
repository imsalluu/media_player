import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/core/services/storage_service.dart';

final storageServiceProvider = Provider((ref) => StorageService());

class FavoritesNotifier extends StateNotifier<List<String>> {
  final StorageService _storage;

  FavoritesNotifier(this._storage) : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    state = await _storage.getFavorites();
  }

  Future<void> toggleFavorite(String id) async {
    await _storage.toggleFavorite(id);
    await _loadFavorites();
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  return FavoritesNotifier(ref.watch(storageServiceProvider));
});

class RecentNotifier extends StateNotifier<List<String>> {
  final StorageService _storage;

  RecentNotifier(this._storage) : super([]) {
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    state = await _storage.getRecent();
  }

  Future<void> addToRecent(String id) async {
    await _storage.addToRecent(id);
    await _loadRecent();
  }
}

final recentProvider = StateNotifierProvider<RecentNotifier, List<String>>((ref) {
  return RecentNotifier(ref.watch(storageServiceProvider));
});
