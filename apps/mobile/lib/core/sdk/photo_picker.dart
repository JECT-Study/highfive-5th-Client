import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// 사진을 어디서 가져올지.
enum PhotoSource { album, camera }

/// 고른 사진 파일. 업로드 URL 발급에 [sizeBytes]·[contentType]을 보낸다.
class PickedPhoto {
  const PickedPhoto({
    required this.path,
    required this.sizeBytes,
    required this.contentType,
  });

  /// 기기 안 임시 파일 경로. 화면 미리보기와 업로드에 쓴다.
  final String path;
  final int sizeBytes;

  /// `image/jpeg` · `image/png` · `image/heic`. 서버가 받지 않는 형식이면 null.
  final String? contentType;
}

/// 사용자가 카메라·사진 접근을 거부했다. 다시 묻지 않으므로 설정에서 켜야 한다.
class PhotoAccessDenied implements Exception {
  const PhotoAccessDenied(this.source);

  final PhotoSource source;

  @override
  String toString() => 'PhotoAccessDenied(${source.name})';
}

/// `image_picker` 래퍼. 앨범은 시스템 사진 선택기(Android Photo Picker, iOS PHPicker)를,
/// 카메라는 시스템 카메라 앱을 연다. Android는 둘 다 권한 선언이 필요 없고,
/// iOS는 Info.plist의 `NSPhotoLibraryUsageDescription`·`NSCameraUsageDescription` 문구를 쓴다.
///
/// 프로필 사진은 작게 보이므로 긴 변 [maxDimension]으로 줄여 받는다 (업로드 용량·시간 절약).
class PhotoPicker {
  PhotoPicker(this._picker);

  final ImagePicker _picker;

  static const maxDimension = 1080.0;
  static const _quality = 85;

  /// 사용자가 취소하면 null. 접근을 거부했으면 [PhotoAccessDenied].
  Future<PickedPhoto?> pick(PhotoSource source) async {
    final XFile? file;
    try {
      file = await _picker.pickImage(
        source: switch (source) {
          PhotoSource.album => ImageSource.gallery,
          PhotoSource.camera => ImageSource.camera,
        },
        maxWidth: maxDimension,
        maxHeight: maxDimension,
        imageQuality: _quality,
      );
    } on PlatformException catch (error) {
      if (error.code == 'camera_access_denied' ||
          error.code == 'photo_access_denied') {
        throw PhotoAccessDenied(source);
      }
      rethrow;
    }
    if (file == null) return null;
    return PickedPhoto(
      path: file.path,
      sizeBytes: await file.length(),
      contentType: _contentTypeOf(file.path),
    );
  }

  /// 서버가 받는 형식만 (docs/api/profile.md 업로드 URL 발급 `contentType`).
  static String? _contentTypeOf(String path) {
    final extension = path.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'heic' => 'image/heic',
      _ => null,
    };
  }
}
