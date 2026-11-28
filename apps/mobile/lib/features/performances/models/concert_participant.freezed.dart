// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'concert_participant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConcertParticipant {

 int get bandId; String get name;/// 주최 팀인지 (`teams[].isHost`). 대표자 권한(`ConcertPermissions`)과는 다르다.
 bool get isHost; String? get profileImageUrl; List<String> get genres;/// 이전의 최소 참여자 projection에는 없는 값. 모르면 0명으로 바꾸지 않고 숨긴다.
 int? get memberCount;
/// Create a copy of ConcertParticipant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConcertParticipantCopyWith<ConcertParticipant> get copyWith => _$ConcertParticipantCopyWithImpl<ConcertParticipant>(this as ConcertParticipant, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConcertParticipant;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConcertParticipant&&(identical(other.bandId, _this.bandId) || other.bandId == _this.bandId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isHost, _this.isHost) || other.isHost == _this.isHost)&&(identical(other.profileImageUrl, _this.profileImageUrl) || other.profileImageUrl == _this.profileImageUrl)&&const DeepCollectionEquality().equals(other.genres, _this.genres)&&(identical(other.memberCount, _this.memberCount) || other.memberCount == _this.memberCount));
}


@override
int get hashCode {
  final _this = this as ConcertParticipant;
  return Object.hash(runtimeType,_this.bandId,_this.name,_this.isHost,_this.profileImageUrl,const DeepCollectionEquality().hash(_this.genres),_this.memberCount);
}

@override
String toString() {
  final _this = this as ConcertParticipant;
  return 'ConcertParticipant(bandId: ${_this.bandId}, name: ${_this.name}, isHost: ${_this.isHost}, profileImageUrl: ${_this.profileImageUrl}, genres: ${_this.genres}, memberCount: ${_this.memberCount})';
}


}

/// @nodoc
abstract mixin class $ConcertParticipantCopyWith<$Res>  {
  factory $ConcertParticipantCopyWith(ConcertParticipant value, $Res Function(ConcertParticipant) _then) = _$ConcertParticipantCopyWithImpl;
@useResult
$Res call({
 int bandId, String name, bool isHost, String? profileImageUrl, List<String> genres, int? memberCount
});




}
/// @nodoc
class _$ConcertParticipantCopyWithImpl<$Res>
    implements $ConcertParticipantCopyWith<$Res> {
  _$ConcertParticipantCopyWithImpl(this._self, this._then);

  final ConcertParticipant _self;
  final $Res Function(ConcertParticipant) _then;

/// Create a copy of ConcertParticipant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bandId = null,Object? name = null,Object? isHost = null,Object? profileImageUrl = freezed,Object? genres = null,Object? memberCount = freezed,}) {
  return _then(ConcertParticipant(
bandId: null == bandId ? _self.bandId : bandId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,memberCount: freezed == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConcertParticipant].
extension ConcertParticipantPatterns on ConcertParticipant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConcertParticipant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConcertParticipant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConcertParticipant value)  $default,){
final _that = this;
switch (_that) {
case _ConcertParticipant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConcertParticipant value)?  $default,){
final _that = this;
switch (_that) {
case _ConcertParticipant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bandId,  String name,  bool isHost,  String? profileImageUrl,  List<String> genres,  int? memberCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConcertParticipant() when $default != null:
return $default(_that.bandId,_that.name,_that.isHost,_that.profileImageUrl,_that.genres,_that.memberCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bandId,  String name,  bool isHost,  String? profileImageUrl,  List<String> genres,  int? memberCount)  $default,) {final _that = this;
switch (_that) {
case _ConcertParticipant():
return $default(_that.bandId,_that.name,_that.isHost,_that.profileImageUrl,_that.genres,_that.memberCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bandId,  String name,  bool isHost,  String? profileImageUrl,  List<String> genres,  int? memberCount)?  $default,) {final _that = this;
switch (_that) {
case _ConcertParticipant() when $default != null:
return $default(_that.bandId,_that.name,_that.isHost,_that.profileImageUrl,_that.genres,_that.memberCount);case _:
  return null;

}
}

}

/// @nodoc


class _ConcertParticipant implements ConcertParticipant {
  const _ConcertParticipant({required this.bandId, required this.name, required this.isHost, this.profileImageUrl,  List<String> genres = const <String>[], this.memberCount}): _genres = genres;
  

@override final  int bandId;
@override final  String name;
/// 주최 팀인지 (`teams[].isHost`). 대표자 권한(`ConcertPermissions`)과는 다르다.
@override final  bool isHost;
@override final  String? profileImageUrl;
 final  List<String> _genres;
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

/// 이전의 최소 참여자 projection에는 없는 값. 모르면 0명으로 바꾸지 않고 숨긴다.
@override final  int? memberCount;

/// Create a copy of ConcertParticipant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConcertParticipantCopyWith<_ConcertParticipant> get copyWith => __$ConcertParticipantCopyWithImpl<_ConcertParticipant>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConcertParticipant&&(identical(other.bandId, bandId) || other.bandId == bandId)&&(identical(other.name, name) || other.name == name)&&(identical(other.isHost, isHost) || other.isHost == isHost)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&const DeepCollectionEquality().equals(other.genres, _genres)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,bandId,name,isHost,profileImageUrl,const DeepCollectionEquality().hash(_genres),memberCount);
}

@override
String toString() {
    return 'ConcertParticipant(bandId: $bandId, name: $name, isHost: $isHost, profileImageUrl: $profileImageUrl, genres: $genres, memberCount: $memberCount)';
}


}

/// @nodoc
abstract mixin class _$ConcertParticipantCopyWith<$Res> implements $ConcertParticipantCopyWith<$Res> {
  factory _$ConcertParticipantCopyWith(_ConcertParticipant value, $Res Function(_ConcertParticipant) _then) = __$ConcertParticipantCopyWithImpl;
@override @useResult
$Res call({
 int bandId, String name, bool isHost, String? profileImageUrl, List<String> genres, int? memberCount
});




}
/// @nodoc
class __$ConcertParticipantCopyWithImpl<$Res>
    implements _$ConcertParticipantCopyWith<$Res> {
  __$ConcertParticipantCopyWithImpl(this._self, this._then);

  final _ConcertParticipant _self;
  final $Res Function(_ConcertParticipant) _then;

/// Create a copy of ConcertParticipant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bandId = null,Object? name = null,Object? isHost = null,Object? profileImageUrl = freezed,Object? genres = null,Object? memberCount = freezed,}) {
  return _then(_ConcertParticipant(
bandId: null == bandId ? _self.bandId : bandId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,memberCount: freezed == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
