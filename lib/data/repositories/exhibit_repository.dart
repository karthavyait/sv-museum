import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/exhibit.dart';
import '../local/local_data_source.dart';
import '../remote/remote_data_source.dart';

class ExhibitRepository {
  ExhibitRepository({LocalDataSource? localDataSource, RemoteDataSource? remoteDataSource})
      : _localDataSource = localDataSource ?? LocalDataSource(),
        _remoteDataSource = remoteDataSource ?? RemoteDataSource();

  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;

  Future<void> ensureSeedData() async {
    await _localDataSource.ensureSeedData();
  }

  Future<List<Exhibit>> fetchExhibits() async {
    return _localDataSource.fetchExhibits();
  }

  Future<int> addExhibit(Exhibit exhibit) async {
    return _localDataSource.insertExhibit(exhibit);
  }

  Future<int> updateExhibit(Exhibit exhibit) async {
    return _localDataSource.updateExhibit(exhibit);
  }

  Future<int> deleteExhibit(int id) async {
    return _localDataSource.deleteExhibit(id);
  }

  Future<String> copyFileToAppStorage(String originalPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final filename = p.basename(originalPath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newPath = p.join(directory.path, '${timestamp}_$filename');
    final file = File(originalPath);
    return file.copy(newPath).then((copied) => copied.path);
  }

  Future<void> syncRemote() async {
    await _remoteDataSource.sync();
  }
}
