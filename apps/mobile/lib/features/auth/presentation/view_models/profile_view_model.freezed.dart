// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileState implements DiagnosticableTreeMixin {

 String get nickname;/// [nickname]의 "중복 확인" 결과. 닉네임을 고치면 null(다시 확인해야 함).
 NicknameCheckResult? get nicknameCheck;/// 중복 확인 중. 버튼은 다시 눌리지 않는다.
 bool get checkingNickname;/// 고른 순서대로.
 List<String> get genreCodes; String get genreCustomName; List<String> get positionCodes; String get positionCustomName;/// 고른 프로필 사진. 없으면 기본 이미지 (건너뛰기).
 PickedPhoto? get photo;/// 사진 선택기가 열려 있다. 다시 열리지 않는다.
 bool get pickingPhoto;/// 마지막 사진 고르기가 실패한 이유. 화면은 이 값이 생길 때 안내를 띄운다.
 PhotoPickProblem? get photoProblem;/// 저장 중. 버튼은 로딩으로 보이고 다시 눌리지 않는다.
 bool get saving;/// 마지막 확인·저장이 실패한 이유. 화면은 이 값이 생길 때 안내를 띄운다.
 ProfileFailureReason? get failure;
/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileStateCopyWith<ProfileState> get copyWith => _$ProfileStateCopyWithImpl<ProfileState>(this as ProfileState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as ProfileState;
  properties
    ..add(DiagnosticsProperty('type', 'ProfileState'))
    ..add(DiagnosticsProperty('nickname', _this.nickname))..add(DiagnosticsProperty('nicknameCheck', _this.nicknameCheck))..add(DiagnosticsProperty('checkingNickname', _this.checkingNickname))..add(DiagnosticsProperty('genreCodes', _this.genreCodes))..add(DiagnosticsProperty('genreCustomName', _this.genreCustomName))..add(DiagnosticsProperty('positionCodes', _this.positionCodes))..add(DiagnosticsProperty('positionCustomName', _this.positionCustomName))..add(DiagnosticsProperty('photo', _this.photo))..add(DiagnosticsProperty('pickingPhoto', _this.pickingPhoto))..add(DiagnosticsProperty('photoProblem', _this.photoProblem))..add(DiagnosticsProperty('saving', _this.saving))..add(DiagnosticsProperty('failure', _this.failure));
}

@override
bool operator ==(Object other) {
  final _this = this as ProfileState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileState&&(identical(other.nickname, _this.nickname) || other.nickname == _this.nickname)&&(identical(other.nicknameCheck, _this.nicknameCheck) || other.nicknameCheck == _this.nicknameCheck)&&(identical(other.checkingNickname, _this.checkingNickname) || other.checkingNickname == _this.checkingNickname)&&const DeepCollectionEquality().equals(other.genreCodes, _this.genreCodes)&&(identical(other.genreCustomName, _this.genreCustomName) || other.genreCustomName == _this.genreCustomName)&&const DeepCollectionEquality().equals(other.positionCodes, _this.positionCodes)&&(identical(other.positionCustomName, _this.positionCustomName) || other.positionCustomName == _this.positionCustomName)&&(identical(other.photo, _this.photo) || other.photo == _this.photo)&&(identical(other.pickingPhoto, _this.pickingPhoto) || other.pickingPhoto == _this.pickingPhoto)&&(identical(other.photoProblem, _this.photoProblem) || other.photoProblem == _this.photoProblem)&&(identical(other.saving, _this.saving) || other.saving == _this.saving)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as ProfileState;
  return Object.hash(runtimeType,_this.nickname,_this.nicknameCheck,_this.checkingNickname,const DeepCollectionEquality().hash(_this.genreCodes),_this.genreCustomName,const DeepCollectionEquality().hash(_this.positionCodes),_this.positionCustomName,_this.photo,_this.pickingPhoto,_this.photoProblem,_this.saving,_this.failure);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as ProfileState;
  return 'ProfileState(nickname: ${_this.nickname}, nicknameCheck: ${_this.nicknameCheck}, checkingNickname: ${_this.checkingNickname}, genreCodes: ${_this.genreCodes}, genreCustomName: ${_this.genreCustomName}, positionCodes: ${_this.positionCodes}, positionCustomName: ${_this.positionCustomName}, photo: ${_this.photo}, pickingPhoto: ${_this.pickingPhoto}, photoProblem: ${_this.photoProblem}, saving: ${_this.saving}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $ProfileStateCopyWith<$Res>  {
  factory $ProfileStateCopyWith(ProfileState value, $Res Function(ProfileState) _then) = _$ProfileStateCopyWithImpl;
@useResult
$Res call({
 String nickname, NicknameCheckResult? nicknameCheck, bool checkingNickname, List<String> genreCodes, String genreCustomName, List<String> positionCodes, String positionCustomName, PickedPhoto? photo, bool pickingPhoto, PhotoPickProblem? photoProblem, bool saving, ProfileFailureReason? failure
});




}
/// @nodoc
class _$ProfileStateCopyWithImpl<$Res>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._self, this._then);

  final ProfileState _self;
  final $Res Function(ProfileState) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nickname = null,Object? nicknameCheck = freezed,Object? checkingNickname = null,Object? genreCodes = null,Object? genreCustomName = null,Object? positionCodes = null,Object? positionCustomName = null,Object? photo = freezed,Object? pickingPhoto = null,Object? photoProblem = freezed,Object? saving = null,Object? failure = freezed,}) {
  return _then(ProfileState(
nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,nicknameCheck: freezed == nicknameCheck ? _self.nicknameCheck : nicknameCheck // ignore: cast_nullable_to_non_nullable
as NicknameCheckResult?,checkingNickname: null == checkingNickname ? _self.checkingNickname : checkingNickname // ignore: cast_nullable_to_non_nullable
as bool,genreCodes: null == genreCodes ? _self.genreCodes : genreCodes // ignore: cast_nullable_to_non_nullable
as List<String>,genreCustomName: null == genreCustomName ? _self.genreCustomName : genreCustomName // ignore: cast_nullable_to_non_nullable
as String,positionCodes: null == positionCodes ? _self.positionCodes : positionCodes // ignore: cast_nullable_to_non_nullable
as List<String>,positionCustomName: null == positionCustomName ? _self.positionCustomName : positionCustomName // ignore: cast_nullable_to_non_nullable
as String,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as PickedPhoto?,pickingPhoto: null == pickingPhoto ? _self.pickingPhoto : pickingPhoto // ignore: cast_nullable_to_non_nullable
as bool,photoProblem: freezed == photoProblem ? _self.photoProblem : photoProblem // ignore: cast_nullable_to_non_nullable
as PhotoPickProblem?,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as ProfileFailureReason?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileState].
extension ProfileStatePatterns on ProfileState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileState value)  $default,){
final _that = this;
switch (_that) {
case _ProfileState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nickname,  NicknameCheckResult? nicknameCheck,  bool checkingNickname,  List<String> genreCodes,  String genreCustomName,  List<String> positionCodes,  String positionCustomName,  PickedPhoto? photo,  bool pickingPhoto,  PhotoPickProblem? photoProblem,  bool saving,  ProfileFailureReason? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
return $default(_that.nickname,_that.nicknameCheck,_that.checkingNickname,_that.genreCodes,_that.genreCustomName,_that.positionCodes,_that.positionCustomName,_that.photo,_that.pickingPhoto,_that.photoProblem,_that.saving,_that.failure);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nickname,  NicknameCheckResult? nicknameCheck,  bool checkingNickname,  List<String> genreCodes,  String genreCustomName,  List<String> positionCodes,  String positionCustomName,  PickedPhoto? photo,  bool pickingPhoto,  PhotoPickProblem? photoProblem,  bool saving,  ProfileFailureReason? failure)  $default,) {final _that = this;
switch (_that) {
case _ProfileState():
return $default(_that.nickname,_that.nicknameCheck,_that.checkingNickname,_that.genreCodes,_that.genreCustomName,_that.positionCodes,_that.positionCustomName,_that.photo,_that.pickingPhoto,_that.photoProblem,_that.saving,_that.failure);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nickname,  NicknameCheckResult? nicknameCheck,  bool checkingNickname,  List<String> genreCodes,  String genreCustomName,  List<String> positionCodes,  String positionCustomName,  PickedPhoto? photo,  bool pickingPhoto,  PhotoPickProblem? photoProblem,  bool saving,  ProfileFailureReason? failure)?  $default,) {final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
return $default(_that.nickname,_that.nicknameCheck,_that.checkingNickname,_that.genreCodes,_that.genreCustomName,_that.positionCodes,_that.positionCustomName,_that.photo,_that.pickingPhoto,_that.photoProblem,_that.saving,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileState extends ProfileState with DiagnosticableTreeMixin {
  const _ProfileState({this.nickname = '', this.nicknameCheck, this.checkingNickname = false,  List<String> genreCodes = const <String>[], this.genreCustomName = '',  List<String> positionCodes = const <String>[], this.positionCustomName = '', this.photo, this.pickingPhoto = false, this.photoProblem, this.saving = false, this.failure}): _genreCodes = genreCodes,_positionCodes = positionCodes,super._();
  

@override@JsonKey() final  String nickname;
/// [nickname]의 "중복 확인" 결과. 닉네임을 고치면 null(다시 확인해야 함).
@override final  NicknameCheckResult? nicknameCheck;
/// 중복 확인 중. 버튼은 다시 눌리지 않는다.
@override@JsonKey() final  bool checkingNickname;
/// 고른 순서대로.
 final  List<String> _genreCodes;
/// 고른 순서대로.
@override@JsonKey() List<String> get genreCodes {
  if (_genreCodes is EqualUnmodifiableListView) return _genreCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genreCodes);
}

@override@JsonKey() final  String genreCustomName;
 final  List<String> _positionCodes;
@override@JsonKey() List<String> get positionCodes {
  if (_positionCodes is EqualUnmodifiableListView) return _positionCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_positionCodes);
}

@override@JsonKey() final  String positionCustomName;
/// 고른 프로필 사진. 없으면 기본 이미지 (건너뛰기).
@override final  PickedPhoto? photo;
/// 사진 선택기가 열려 있다. 다시 열리지 않는다.
@override@JsonKey() final  bool pickingPhoto;
/// 마지막 사진 고르기가 실패한 이유. 화면은 이 값이 생길 때 안내를 띄운다.
@override final  PhotoPickProblem? photoProblem;
/// 저장 중. 버튼은 로딩으로 보이고 다시 눌리지 않는다.
@override@JsonKey() final  bool saving;
/// 마지막 확인·저장이 실패한 이유. 화면은 이 값이 생길 때 안내를 띄운다.
@override final  ProfileFailureReason? failure;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileStateCopyWith<_ProfileState> get copyWith => __$ProfileStateCopyWithImpl<_ProfileState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'ProfileState'))
    ..add(DiagnosticsProperty('nickname', nickname))..add(DiagnosticsProperty('nicknameCheck', nicknameCheck))..add(DiagnosticsProperty('checkingNickname', checkingNickname))..add(DiagnosticsProperty('genreCodes', genreCodes))..add(DiagnosticsProperty('genreCustomName', genreCustomName))..add(DiagnosticsProperty('positionCodes', positionCodes))..add(DiagnosticsProperty('positionCustomName', positionCustomName))..add(DiagnosticsProperty('photo', photo))..add(DiagnosticsProperty('pickingPhoto', pickingPhoto))..add(DiagnosticsProperty('photoProblem', photoProblem))..add(DiagnosticsProperty('saving', saving))..add(DiagnosticsProperty('failure', failure));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileState&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.nicknameCheck, nicknameCheck) || other.nicknameCheck == nicknameCheck)&&(identical(other.checkingNickname, checkingNickname) || other.checkingNickname == checkingNickname)&&const DeepCollectionEquality().equals(other.genreCodes, _genreCodes)&&(identical(other.genreCustomName, genreCustomName) || other.genreCustomName == genreCustomName)&&const DeepCollectionEquality().equals(other.positionCodes, _positionCodes)&&(identical(other.positionCustomName, positionCustomName) || other.positionCustomName == positionCustomName)&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.pickingPhoto, pickingPhoto) || other.pickingPhoto == pickingPhoto)&&(identical(other.photoProblem, photoProblem) || other.photoProblem == photoProblem)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,nickname,nicknameCheck,checkingNickname,const DeepCollectionEquality().hash(_genreCodes),genreCustomName,const DeepCollectionEquality().hash(_positionCodes),positionCustomName,photo,pickingPhoto,photoProblem,saving,failure);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'ProfileState(nickname: $nickname, nicknameCheck: $nicknameCheck, checkingNickname: $checkingNickname, genreCodes: $genreCodes, genreCustomName: $genreCustomName, positionCodes: $positionCodes, positionCustomName: $positionCustomName, photo: $photo, pickingPhoto: $pickingPhoto, photoProblem: $photoProblem, saving: $saving, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$ProfileStateCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileStateCopyWith(_ProfileState value, $Res Function(_ProfileState) _then) = __$ProfileStateCopyWithImpl;
@override @useResult
$Res call({
 String nickname, NicknameCheckResult? nicknameCheck, bool checkingNickname, List<String> genreCodes, String genreCustomName, List<String> positionCodes, String positionCustomName, PickedPhoto? photo, bool pickingPhoto, PhotoPickProblem? photoProblem, bool saving, ProfileFailureReason? failure
});




}
/// @nodoc
class __$ProfileStateCopyWithImpl<$Res>
    implements _$ProfileStateCopyWith<$Res> {
  __$ProfileStateCopyWithImpl(this._self, this._then);

  final _ProfileState _self;
  final $Res Function(_ProfileState) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nickname = null,Object? nicknameCheck = freezed,Object? checkingNickname = null,Object? genreCodes = null,Object? genreCustomName = null,Object? positionCodes = null,Object? positionCustomName = null,Object? photo = freezed,Object? pickingPhoto = null,Object? photoProblem = freezed,Object? saving = null,Object? failure = freezed,}) {
  return _then(_ProfileState(
nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,nicknameCheck: freezed == nicknameCheck ? _self.nicknameCheck : nicknameCheck // ignore: cast_nullable_to_non_nullable
as NicknameCheckResult?,checkingNickname: null == checkingNickname ? _self.checkingNickname : checkingNickname // ignore: cast_nullable_to_non_nullable
as bool,genreCodes: null == genreCodes ? _self._genreCodes : genreCodes // ignore: cast_nullable_to_non_nullable
as List<String>,genreCustomName: null == genreCustomName ? _self.genreCustomName : genreCustomName // ignore: cast_nullable_to_non_nullable
as String,positionCodes: null == positionCodes ? _self._positionCodes : positionCodes // ignore: cast_nullable_to_non_nullable
as List<String>,positionCustomName: null == positionCustomName ? _self.positionCustomName : positionCustomName // ignore: cast_nullable_to_non_nullable
as String,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as PickedPhoto?,pickingPhoto: null == pickingPhoto ? _self.pickingPhoto : pickingPhoto // ignore: cast_nullable_to_non_nullable
as bool,photoProblem: freezed == photoProblem ? _self.photoProblem : photoProblem // ignore: cast_nullable_to_non_nullable
as PhotoPickProblem?,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as ProfileFailureReason?,
  ));
}


}

// dart format on
