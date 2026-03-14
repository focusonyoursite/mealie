import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope, // Full Access om makkelijk te downloaden/bekijken in GDrive
    ],
    // Let op: OAuth Client ID configureren via Google Cloud Console
  );

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (error) {
      print("Google Sign In Error: $error");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
  }

  Future<bool> backupDatabase() async {
    final account = _googleSignIn.currentUser ?? await signIn();
    if (account == null) {
      print("Not signed in");
      return false;
    }

    try {
      final authHeaders = await account.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'recipes.db');
      final file = File(path);

      if (!await file.exists()) {
        print("Geen lokale database gevonden.");
        return false;
      }

      final query = "name = 'mealie_backup.db' and trashed = false";
      final fileList = await driveApi.files.list(q: query);

      var driveFile = drive.File();
      driveFile.name = 'mealie_backup.db';

      final media = drive.Media(file.openRead(), file.lengthSync());

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final existingFileId = fileList.files!.first.id!;
        await driveApi.files.update(driveFile, existingFileId, uploadMedia: media);
        print("Database backup updated");
      } else {
        await driveApi.files.create(driveFile, uploadMedia: media);
        print("New Database backup created");
      }
      return true;
    } catch (e) {
      print("Error backing up: $e");
      return false;
    }
  }
}
