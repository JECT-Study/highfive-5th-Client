// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileDraft {

 String get nickname;/// 고른 순서대로. [genreCustomCode]가 있으면 [genreCustomName]을 보낸다.
 List<String> get genreCodes; String? get genreCustomName;/// 고른 순서대로. [positionCustomCode]가 있으면 [positionCustomName]을 보낸다.
 List<String> get positionCodes; String? get positionCustomName;/// 업로드한 사진 주소. 건너뛰면 null (기본 이미지).
 String? get profileImageUrl;
/// Create a copy of ProfileDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileDraftCopyWith<ProfileDraft> get copyWith => _$ProfileDraftCopyWithImpl<ProfileDraft>(this as ProfileDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProfileDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileDraft&&(identical(other.nickname, _this.nickname) || other.nickname == _this.nickname)&&const DeepCollectionEquality().equals(other.genreCodes, _this.genreCodes)&&(identical(other.genreCustomName, _this.genreCustomName) || other.genreCustomName == _this.genreCustomName)&&const DeepCollectionEquality().equals(other.positionCodes, _this.positionCodes)&&(identical(other.positionCustomName, _this.positionCustomName) || other.positionCustomName == _this.positionCustomName)&&(identical(other.profileImageUrl, _this.profileImageUrl) || other.profileImageUrl == _this.profileImageUrl));
}


@override
int get hashCode {
  final _this = this as ProfileDraft;
  return Object.hash(runtimeType,_this.nickname,const DeepCollectionEquality().hash(_this.genreCodes),_this.genreCustomName,const DeepCollectionEquality().hash(_this.positionCodes),_this.positionCustomName,_this.profileImageUrl);
}

@override
String toString() {
  final _this = this as ProfileDraft;
  return 'ProfileDraft(nickname: ${_this.nickname}, genreCodes: ${_this.genreCodes}, genreCustomName: ${_this.genreCustomName}, positionCodes: ${_this.positionCodes}, positionCustomName: ${_this.positionCustomName}, profileImageUrl: ${_this.profileImageUrl})';
}


}

/// @nodoc
abstract mixin class $ProfileDraftCopyWith<$Res>  {
  factory $ProfileDraftCopyWith(ProfileDraft value, $Res Function(ProfileDraft) _then) = _$ProfileDraftCopyWithImpl;
@useResult
$Res call({
 String nickname, List<String> genreCodes, String? genreCustomName, List<String> positionCodes, String? positionCustomName, String? profileImageUrl
});




}
/// @nodoc
class _$ProfileDraftCopyWithImpl<$Res>
    implements $ProfileDraftCopyWith<$Res> {
  _$ProfileDraftCopyWithImpl(this._self, this._then);

  final ProfileDraft _self;
  final $Res Function(ProfileDraft) _then;

/// Create a copy of ProfileDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nickname = null,Object? genreCodes = null,Object? genreCustomName = freezed,Object? positionCodes = null,Object? positionCustomName = freezed,Object? profileImageUrl = freezed,}) {
  return _then(ProfileDraft(
nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,genreCodes: null == genreCodes ? _self.genreCodes : genreCodes // ignore: cast_nullable_to_non_nullable
as List<String>,genreCustomName: freezed == genreCustomName ? _self.genreCustomName : genreCustomName // ignore: cast_nullable_to_non_nullable
as String?,positionCodes: null == positionCodes ? _self.positionCodes : positionCodes // ignore: cast_nullable_to_non_nullable
as List<String>,positionCustomName: freezed == positionCustomName ? _self.positionCustomName : positionCustomName // ignore: cast_nullable_to_non_nullable
as String?,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileDraft].
extension ProfileDraftPatterns on ProfileDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileDraft value)  $default,){
final _that = this;
switch (_that) {
case _ProfileDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileDraft value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nickname,  List<String> genreCodes,  String? genreCustomName,  List<String> positionCodes,  String? positionCustomName,  String? profileImageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileDraft() when $default != null:
return $default(_that.nickname,_that.genreCodes,_that.genreCustomName,_that.positionCodes,_that.positionCustomName,_that.profileImageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nickname,  List<String> genreCodes,  String? genreCustomName,  List<String> positionCodes,  String? positionCustomName,  String? profileImageUrl)  $default,) {final _that = this;
switch (_that) {
case _ProfileDraft():
return $default(_that.nickname,_that.genreCodes,_that.genreCustomName,_that.positionCodes,_that.positionCustomName,_that.profileImageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nickname,  List<String> genreCodes,  String? genreCustomName,  List<String> positionCodes,  String? positionCustomName,  String? profileImageUrl)?  $default,) {final _that = this;
switch (_that) {
case _ProfileDraft() when $default != null:
return $default(_that.nickname,_that.genreCodes,_that.genreCustomName,_that.positionCodes,_that.positionCustomName,_that.profileImageUrl);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileDraft implements ProfileDraft {
  const _ProfileDraft({required this.nickname, required  List<String> genreCodes, this.genreCustomName, required  List<String> positionCodes, this.positionCustomName, this.profileImageUrl}): _genreCodes = genreCodes,_positionCodes = positionCodes;
  

@override final  String nickname;
/// 고른 순서대로. [genreCustomCode]가 있으면 [genreCustomName]을 보낸다.
 final  List<String> _genreCodes;
/// 고른 순서대로. [genreCustomCode]가 있으면 [genreCustomName]을 보낸다.
@override List<String> get genreCodes {
  if (_genreCodes is EqualUnmodifiableListView) return _genreCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genreCodes);
}

@override final  String? genreCustomName;
/// 고른 순서대로. [positionCustomCode]가 있으면 [positionCustomName]을 보낸다.
 final  List<String> _positionCodes;
/// 고른 순서대로. [positionCustomCode]가 있으면 [positionCustomName]을 보낸다.
@override List<String> get positionCodes {
  if (_positionCodes is EqualUnmodifiableListView) return _positionCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_positionCodes);
}

@override final  String? positionCustomName;
/// 업로드한 사진 주소. 건너뛰면 null (기본 이미지).
@override final  String? profileImageUrl;

/// Create a copy of ProfileDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileDraftCopyWith<_ProfileDraft> get copyWith => __$ProfileDraftCopyWithImpl<_ProfileDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileDraft&&(identical(other.nickname, nickname) || other.nickname == nickname)&&const DeepCollectionEquality().equals(other.genreCodes, _genreCodes)&&(identical(other.genreCustomName, genreCustomName) || other.genreCustomName == genreCustomName)&&const DeepCollectionEquality().equals(other.positionCodes, _positionCodes)&&(identical(other.positionCustomName, positionCustomName) || other.positionCustomName == positionCustomName)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,nickname,const DeepCollectionEquality().hash(_genreCodes),genreCustomName,const DeepCollectionEquality().hash(_positionCodes),positionCustomName,profileImageUrl);
}

@override
String toString() {
    return 'ProfileDraft(nickname: $nickname, genreCodes: $genreCodes, genreCustomName: $genreCustomName, positionCodes: $positionCodes, positionCustomName: $positionCustomName, profileImageUrl: $profileImageUrl)';
}


}

/// @nodoc
abstract mixin class _$ProfileDraftCopyWith<$Res> implements $ProfileDraftCopyWith<$Res> {
  factory _$ProfileDraftCopyWith(_ProfileDraft value, $Res Function(_ProfileDraft) _then) = __$ProfileDraftCopyWithImpl;
@override @useResult
$Res call({
 String nickname, List<String> genreCodes, String? genreCustomName, List<String> positionCodes, String? positionCustomName, String? profileImageUrl
});




}
/// @nodoc
class __$ProfileDraftCopyWithImpl<$Res>
    implements _$ProfileDraftCopyWith<$Res> {
  __$ProfileDraftCopyWithImpl(this._self, this._then);

  final _ProfileDraft _self;
  final $Res Function(_ProfileDraft) _then;

/// Create a copy of ProfileDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nickname = null,Object? genreCodes = null,Object? genreCustomName = freezed,Object? positionCodes = null,Object? positionCustomName = freezed,Object? profileImageUrl = freezed,}) {
  return _then(_ProfileDraft(
nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,genreCodes: null == genreCodes ? _self._genreCodes : genreCodes // ignore: cast_nullable_to_non_nullable
as List<String>,genreCustomName: freezed == genreCustomName ? _self.genreCustomName : genreCustomName // ignore: cast_nullable_to_non_nullable
as String?,positionCodes: null == positionCodes ? _self._positionCodes : positionCodes // ignore: cast_nullable_to_non_nullable
as List<String>,positionCustomName: freezed == positionCustomName ? _self.positionCustomName : positionCustomName // ignore: cast_nullable_to_non_nullable
as String?,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
