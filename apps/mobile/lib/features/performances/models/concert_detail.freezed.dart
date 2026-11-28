// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'concert_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConcertDetail {

 int get concertId; String get title; List<String> get genres; int get recruitTeamCount; String? get performDate; String? get startTime; String? get endTime; String? get place; String? get address; String? get region; int? get rentalFee; String? get posterImageUrl; ConcertStatus get status; int get hostBandId; List<int> get myBandIds; ConcertPermissions get myPermissions; ConcertRecruitment? get recruitment;/// 수정 요청에 그대로 돌려보낼 낙관적 잠금 버전.
 int get version; String get updatedAt;
/// Create a copy of ConcertDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConcertDetailCopyWith<ConcertDetail> get copyWith => _$ConcertDetailCopyWithImpl<ConcertDetail>(this as ConcertDetail, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConcertDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConcertDetail&&(identical(other.concertId, _this.concertId) || other.concertId == _this.concertId)&&(identical(other.title, _this.title) || other.title == _this.title)&&const DeepCollectionEquality().equals(other.genres, _this.genres)&&(identical(other.recruitTeamCount, _this.recruitTeamCount) || other.recruitTeamCount == _this.recruitTeamCount)&&(identical(other.performDate, _this.performDate) || other.performDate == _this.performDate)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime)&&(identical(other.place, _this.place) || other.place == _this.place)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.region, _this.region) || other.region == _this.region)&&(identical(other.rentalFee, _this.rentalFee) || other.rentalFee == _this.rentalFee)&&(identical(other.posterImageUrl, _this.posterImageUrl) || other.posterImageUrl == _this.posterImageUrl)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.hostBandId, _this.hostBandId) || other.hostBandId == _this.hostBandId)&&const DeepCollectionEquality().equals(other.myBandIds, _this.myBandIds)&&(identical(other.myPermissions, _this.myPermissions) || other.myPermissions == _this.myPermissions)&&(identical(other.recruitment, _this.recruitment) || other.recruitment == _this.recruitment)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}


@override
int get hashCode {
  final _this = this as ConcertDetail;
  return Object.hashAll([runtimeType,_this.concertId,_this.title,const DeepCollectionEquality().hash(_this.genres),_this.recruitTeamCount,_this.performDate,_this.startTime,_this.endTime,_this.place,_this.address,_this.region,_this.rentalFee,_this.posterImageUrl,_this.status,_this.hostBandId,const DeepCollectionEquality().hash(_this.myBandIds),_this.myPermissions,_this.recruitment,_this.version,_this.updatedAt]);
}

@override
String toString() {
  final _this = this as ConcertDetail;
  return 'ConcertDetail(concertId: ${_this.concertId}, title: ${_this.title}, genres: ${_this.genres}, recruitTeamCount: ${_this.recruitTeamCount}, performDate: ${_this.performDate}, startTime: ${_this.startTime}, endTime: ${_this.endTime}, place: ${_this.place}, address: ${_this.address}, region: ${_this.region}, rentalFee: ${_this.rentalFee}, posterImageUrl: ${_this.posterImageUrl}, status: ${_this.status}, hostBandId: ${_this.hostBandId}, myBandIds: ${_this.myBandIds}, myPermissions: ${_this.myPermissions}, recruitment: ${_this.recruitment}, version: ${_this.version}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ConcertDetailCopyWith<$Res>  {
  factory $ConcertDetailCopyWith(ConcertDetail value, $Res Function(ConcertDetail) _then) = _$ConcertDetailCopyWithImpl;
@useResult
$Res call({
 int concertId, String title, List<String> genres, int recruitTeamCount, String? performDate, String? startTime, String? endTime, String? place, String? address, String? region, int? rentalFee, String? posterImageUrl, ConcertStatus status, int hostBandId, List<int> myBandIds, ConcertPermissions myPermissions, ConcertRecruitment? recruitment, int version, String updatedAt
});


$ConcertPermissionsCopyWith<$Res> get myPermissions;$ConcertRecruitmentCopyWith<$Res>? get recruitment;

}
/// @nodoc
class _$ConcertDetailCopyWithImpl<$Res>
    implements $ConcertDetailCopyWith<$Res> {
  _$ConcertDetailCopyWithImpl(this._self, this._then);

  final ConcertDetail _self;
  final $Res Function(ConcertDetail) _then;

/// Create a copy of ConcertDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? concertId = null,Object? title = null,Object? genres = null,Object? recruitTeamCount = null,Object? performDate = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? place = freezed,Object? address = freezed,Object? region = freezed,Object? rentalFee = freezed,Object? posterImageUrl = freezed,Object? status = null,Object? hostBandId = null,Object? myBandIds = null,Object? myPermissions = null,Object? recruitment = freezed,Object? version = null,Object? updatedAt = null,}) {
  return _then(ConcertDetail(
concertId: null == concertId ? _self.concertId : concertId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,recruitTeamCount: null == recruitTeamCount ? _self.recruitTeamCount : recruitTeamCount // ignore: cast_nullable_to_non_nullable
as int,performDate: freezed == performDate ? _self.performDate : performDate // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,place: freezed == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,rentalFee: freezed == rentalFee ? _self.rentalFee : rentalFee // ignore: cast_nullable_to_non_nullable
as int?,posterImageUrl: freezed == posterImageUrl ? _self.posterImageUrl : posterImageUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConcertStatus,hostBandId: null == hostBandId ? _self.hostBandId : hostBandId // ignore: cast_nullable_to_non_nullable
as int,myBandIds: null == myBandIds ? _self.myBandIds : myBandIds // ignore: cast_nullable_to_non_nullable
as List<int>,myPermissions: null == myPermissions ? _self.myPermissions : myPermissions // ignore: cast_nullable_to_non_nullable
as ConcertPermissions,recruitment: freezed == recruitment ? _self.recruitment : recruitment // ignore: cast_nullable_to_non_nullable
as ConcertRecruitment?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of ConcertDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConcertPermissionsCopyWith<$Res> get myPermissions {
  
  return $ConcertPermissionsCopyWith<$Res>(_self.myPermissions, (value) {
    return _then(_self.copyWith(myPermissions: value));
  });
}/// Create a copy of ConcertDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConcertRecruitmentCopyWith<$Res>? get recruitment {
    if (_self.recruitment == null) {
    return null;
  }

  return $ConcertRecruitmentCopyWith<$Res>(_self.recruitment!, (value) {
    return _then(_self.copyWith(recruitment: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConcertDetail].
extension ConcertDetailPatterns on ConcertDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConcertDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConcertDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConcertDetail value)  $default,){
final _that = this;
switch (_that) {
case _ConcertDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConcertDetail value)?  $default,){
final _that = this;
switch (_that) {
case _ConcertDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int concertId,  String title,  List<String> genres,  int recruitTeamCount,  String? performDate,  String? startTime,  String? endTime,  String? place,  String? address,  String? region,  int? rentalFee,  String? posterImageUrl,  ConcertStatus status,  int hostBandId,  List<int> myBandIds,  ConcertPermissions myPermissions,  ConcertRecruitment? recruitment,  int version,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConcertDetail() when $default != null:
return $default(_that.concertId,_that.title,_that.genres,_that.recruitTeamCount,_that.performDate,_that.startTime,_that.endTime,_that.place,_that.address,_that.region,_that.rentalFee,_that.posterImageUrl,_that.status,_that.hostBandId,_that.myBandIds,_that.myPermissions,_that.recruitment,_that.version,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int concertId,  String title,  List<String> genres,  int recruitTeamCount,  String? performDate,  String? startTime,  String? endTime,  String? place,  String? address,  String? region,  int? rentalFee,  String? posterImageUrl,  ConcertStatus status,  int hostBandId,  List<int> myBandIds,  ConcertPermissions myPermissions,  ConcertRecruitment? recruitment,  int version,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ConcertDetail():
return $default(_that.concertId,_that.title,_that.genres,_that.recruitTeamCount,_that.performDate,_that.startTime,_that.endTime,_that.place,_that.address,_that.region,_that.rentalFee,_that.posterImageUrl,_that.status,_that.hostBandId,_that.myBandIds,_that.myPermissions,_that.recruitment,_that.version,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int concertId,  String title,  List<String> genres,  int recruitTeamCount,  String? performDate,  String? startTime,  String? endTime,  String? place,  String? address,  String? region,  int? rentalFee,  String? posterImageUrl,  ConcertStatus status,  int hostBandId,  List<int> myBandIds,  ConcertPermissions myPermissions,  ConcertRecruitment? recruitment,  int version,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ConcertDetail() when $default != null:
return $default(_that.concertId,_that.title,_that.genres,_that.recruitTeamCount,_that.performDate,_that.startTime,_that.endTime,_that.place,_that.address,_that.region,_that.rentalFee,_that.posterImageUrl,_that.status,_that.hostBandId,_that.myBandIds,_that.myPermissions,_that.recruitment,_that.version,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ConcertDetail implements ConcertDetail {
  const _ConcertDetail({required this.concertId, required this.title, required  List<String> genres, required this.recruitTeamCount, required this.performDate, required this.startTime, required this.endTime, required this.place, required this.address, required this.region, required this.rentalFee, required this.posterImageUrl, required this.status, required this.hostBandId, required  List<int> myBandIds, required this.myPermissions, required this.recruitment, required this.version, required this.updatedAt}): _genres = genres,_myBandIds = myBandIds;
  

@override final  int concertId;
@override final  String title;
 final  List<String> _genres;
@override List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override final  int recruitTeamCount;
@override final  String? performDate;
@override final  String? startTime;
@override final  String? endTime;
@override final  String? place;
@override final  String? address;
@override final  String? region;
@override final  int? rentalFee;
@override final  String? posterImageUrl;
@override final  ConcertStatus status;
@override final  int hostBandId;
 final  List<int> _myBandIds;
@override List<int> get myBandIds {
  if (_myBandIds is EqualUnmodifiableListView) return _myBandIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_myBandIds);
}

@override final  ConcertPermissions myPermissions;
@override final  ConcertRecruitment? recruitment;
/// 수정 요청에 그대로 돌려보낼 낙관적 잠금 버전.
@override final  int version;
@override final  String updatedAt;

/// Create a copy of ConcertDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConcertDetailCopyWith<_ConcertDetail> get copyWith => __$ConcertDetailCopyWithImpl<_ConcertDetail>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConcertDetail&&(identical(other.concertId, concertId) || other.concertId == concertId)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.genres, _genres)&&(identical(other.recruitTeamCount, recruitTeamCount) || other.recruitTeamCount == recruitTeamCount)&&(identical(other.performDate, performDate) || other.performDate == performDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.place, place) || other.place == place)&&(identical(other.address, address) || other.address == address)&&(identical(other.region, region) || other.region == region)&&(identical(other.rentalFee, rentalFee) || other.rentalFee == rentalFee)&&(identical(other.posterImageUrl, posterImageUrl) || other.posterImageUrl == posterImageUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.hostBandId, hostBandId) || other.hostBandId == hostBandId)&&const DeepCollectionEquality().equals(other.myBandIds, _myBandIds)&&(identical(other.myPermissions, myPermissions) || other.myPermissions == myPermissions)&&(identical(other.recruitment, recruitment) || other.recruitment == recruitment)&&(identical(other.version, version) || other.version == version)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,concertId,title,const DeepCollectionEquality().hash(_genres),recruitTeamCount,performDate,startTime,endTime,place,address,region,rentalFee,posterImageUrl,status,hostBandId,const DeepCollectionEquality().hash(_myBandIds),myPermissions,recruitment,version,updatedAt]);
}

@override
String toString() {
    return 'ConcertDetail(concertId: $concertId, title: $title, genres: $genres, recruitTeamCount: $recruitTeamCount, performDate: $performDate, startTime: $startTime, endTime: $endTime, place: $place, address: $address, region: $region, rentalFee: $rentalFee, posterImageUrl: $posterImageUrl, status: $status, hostBandId: $hostBandId, myBandIds: $myBandIds, myPermissions: $myPermissions, recruitment: $recruitment, version: $version, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ConcertDetailCopyWith<$Res> implements $ConcertDetailCopyWith<$Res> {
  factory _$ConcertDetailCopyWith(_ConcertDetail value, $Res Function(_ConcertDetail) _then) = __$ConcertDetailCopyWithImpl;
@override @useResult
$Res call({
 int concertId, String title, List<String> genres, int recruitTeamCount, String? performDate, String? startTime, String? endTime, String? place, String? address, String? region, int? rentalFee, String? posterImageUrl, ConcertStatus status, int hostBandId, List<int> myBandIds, ConcertPermissions myPermissions, ConcertRecruitment? recruitment, int version, String updatedAt
});


@override $ConcertPermissionsCopyWith<$Res> get myPermissions;@override $ConcertRecruitmentCopyWith<$Res>? get recruitment;

}
/// @nodoc
class __$ConcertDetailCopyWithImpl<$Res>
    implements _$ConcertDetailCopyWith<$Res> {
  __$ConcertDetailCopyWithImpl(this._self, this._then);

  final _ConcertDetail _self;
  final $Res Function(_ConcertDetail) _then;

/// Create a copy of ConcertDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? concertId = null,Object? title = null,Object? genres = null,Object? recruitTeamCount = null,Object? performDate = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? place = freezed,Object? address = freezed,Object? region = freezed,Object? rentalFee = freezed,Object? posterImageUrl = freezed,Object? status = null,Object? hostBandId = null,Object? myBandIds = null,Object? myPermissions = null,Object? recruitment = freezed,Object? version = null,Object? updatedAt = null,}) {
  return _then(_ConcertDetail(
concertId: null == concertId ? _self.concertId : concertId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,recruitTeamCount: null == recruitTeamCount ? _self.recruitTeamCount : recruitTeamCount // ignore: cast_nullable_to_non_nullable
as int,performDate: freezed == performDate ? _self.performDate : performDate // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,place: freezed == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,rentalFee: freezed == rentalFee ? _self.rentalFee : rentalFee // ignore: cast_nullable_to_non_nullable
as int?,posterImageUrl: freezed == posterImageUrl ? _self.posterImageUrl : posterImageUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConcertStatus,hostBandId: null == hostBandId ? _self.hostBandId : hostBandId // ignore: cast_nullable_to_non_nullable
as int,myBandIds: null == myBandIds ? _self._myBandIds : myBandIds // ignore: cast_nullable_to_non_nullable
as List<int>,myPermissions: null == myPermissions ? _self.myPermissions : myPermissions // ignore: cast_nullable_to_non_nullable
as ConcertPermissions,recruitment: freezed == recruitment ? _self.recruitment : recruitment // ignore: cast_nullable_to_non_nullable
as ConcertRecruitment?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ConcertDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConcertPermissionsCopyWith<$Res> get myPermissions {
  
  return $ConcertPermissionsCopyWith<$Res>(_self.myPermissions, (value) {
    return _then(_self.copyWith(myPermissions: value));
  });
}/// Create a copy of ConcertDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConcertRecruitmentCopyWith<$Res>? get recruitment {
    if (_self.recruitment == null) {
    return null;
  }

  return $ConcertRecruitmentCopyWith<$Res>(_self.recruitment!, (value) {
    return _then(_self.copyWith(recruitment: value));
  });
}
}

/// @nodoc
mixin _$ConcertPermissions {

 bool get isHostLeader; bool get isTeamLeader;
/// Create a copy of ConcertPermissions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConcertPermissionsCopyWith<ConcertPermissions> get copyWith => _$ConcertPermissionsCopyWithImpl<ConcertPermissions>(this as ConcertPermissions, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConcertPermissions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConcertPermissions&&(identical(other.isHostLeader, _this.isHostLeader) || other.isHostLeader == _this.isHostLeader)&&(identical(other.isTeamLeader, _this.isTeamLeader) || other.isTeamLeader == _this.isTeamLeader));
}


@override
int get hashCode {
  final _this = this as ConcertPermissions;
  return Object.hash(runtimeType,_this.isHostLeader,_this.isTeamLeader);
}

@override
String toString() {
  final _this = this as ConcertPermissions;
  return 'ConcertPermissions(isHostLeader: ${_this.isHostLeader}, isTeamLeader: ${_this.isTeamLeader})';
}


}

/// @nodoc
abstract mixin class $ConcertPermissionsCopyWith<$Res>  {
  factory $ConcertPermissionsCopyWith(ConcertPermissions value, $Res Function(ConcertPermissions) _then) = _$ConcertPermissionsCopyWithImpl;
@useResult
$Res call({
 bool isHostLeader, bool isTeamLeader
});




}
/// @nodoc
class _$ConcertPermissionsCopyWithImpl<$Res>
    implements $ConcertPermissionsCopyWith<$Res> {
  _$ConcertPermissionsCopyWithImpl(this._self, this._then);

  final ConcertPermissions _self;
  final $Res Function(ConcertPermissions) _then;

/// Create a copy of ConcertPermissions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isHostLeader = null,Object? isTeamLeader = null,}) {
  return _then(ConcertPermissions(
isHostLeader: null == isHostLeader ? _self.isHostLeader : isHostLeader // ignore: cast_nullable_to_non_nullable
as bool,isTeamLeader: null == isTeamLeader ? _self.isTeamLeader : isTeamLeader // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ConcertPermissions].
extension ConcertPermissionsPatterns on ConcertPermissions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConcertPermissions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConcertPermissions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConcertPermissions value)  $default,){
final _that = this;
switch (_that) {
case _ConcertPermissions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConcertPermissions value)?  $default,){
final _that = this;
switch (_that) {
case _ConcertPermissions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isHostLeader,  bool isTeamLeader)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConcertPermissions() when $default != null:
return $default(_that.isHostLeader,_that.isTeamLeader);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isHostLeader,  bool isTeamLeader)  $default,) {final _that = this;
switch (_that) {
case _ConcertPermissions():
return $default(_that.isHostLeader,_that.isTeamLeader);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isHostLeader,  bool isTeamLeader)?  $default,) {final _that = this;
switch (_that) {
case _ConcertPermissions() when $default != null:
return $default(_that.isHostLeader,_that.isTeamLeader);case _:
  return null;

}
}

}

/// @nodoc


class _ConcertPermissions implements ConcertPermissions {
  const _ConcertPermissions({required this.isHostLeader, required this.isTeamLeader});
  

@override final  bool isHostLeader;
@override final  bool isTeamLeader;

/// Create a copy of ConcertPermissions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConcertPermissionsCopyWith<_ConcertPermissions> get copyWith => __$ConcertPermissionsCopyWithImpl<_ConcertPermissions>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConcertPermissions&&(identical(other.isHostLeader, isHostLeader) || other.isHostLeader == isHostLeader)&&(identical(other.isTeamLeader, isTeamLeader) || other.isTeamLeader == isTeamLeader));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isHostLeader,isTeamLeader);
}

@override
String toString() {
    return 'ConcertPermissions(isHostLeader: $isHostLeader, isTeamLeader: $isTeamLeader)';
}


}

/// @nodoc
abstract mixin class _$ConcertPermissionsCopyWith<$Res> implements $ConcertPermissionsCopyWith<$Res> {
  factory _$ConcertPermissionsCopyWith(_ConcertPermissions value, $Res Function(_ConcertPermissions) _then) = __$ConcertPermissionsCopyWithImpl;
@override @useResult
$Res call({
 bool isHostLeader, bool isTeamLeader
});




}
/// @nodoc
class __$ConcertPermissionsCopyWithImpl<$Res>
    implements _$ConcertPermissionsCopyWith<$Res> {
  __$ConcertPermissionsCopyWithImpl(this._self, this._then);

  final _ConcertPermissions _self;
  final $Res Function(_ConcertPermissions) _then;

/// Create a copy of ConcertPermissions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isHostLeader = null,Object? isTeamLeader = null,}) {
  return _then(_ConcertPermissions(
isHostLeader: null == isHostLeader ? _self.isHostLeader : isHostLeader // ignore: cast_nullable_to_non_nullable
as bool,isTeamLeader: null == isTeamLeader ? _self.isTeamLeader : isTeamLeader // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ConcertRecruitment {

 int get recruitPostId; RecruitmentStatus get status; String get deadline; int get joinedTeamCount; int get recruitTeamCount; int get newInquiryCount;
/// Create a copy of ConcertRecruitment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConcertRecruitmentCopyWith<ConcertRecruitment> get copyWith => _$ConcertRecruitmentCopyWithImpl<ConcertRecruitment>(this as ConcertRecruitment, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConcertRecruitment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConcertRecruitment&&(identical(other.recruitPostId, _this.recruitPostId) || other.recruitPostId == _this.recruitPostId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.deadline, _this.deadline) || other.deadline == _this.deadline)&&(identical(other.joinedTeamCount, _this.joinedTeamCount) || other.joinedTeamCount == _this.joinedTeamCount)&&(identical(other.recruitTeamCount, _this.recruitTeamCount) || other.recruitTeamCount == _this.recruitTeamCount)&&(identical(other.newInquiryCount, _this.newInquiryCount) || other.newInquiryCount == _this.newInquiryCount));
}


@override
int get hashCode {
  final _this = this as ConcertRecruitment;
  return Object.hash(runtimeType,_this.recruitPostId,_this.status,_this.deadline,_this.joinedTeamCount,_this.recruitTeamCount,_this.newInquiryCount);
}

@override
String toString() {
  final _this = this as ConcertRecruitment;
  return 'ConcertRecruitment(recruitPostId: ${_this.recruitPostId}, status: ${_this.status}, deadline: ${_this.deadline}, joinedTeamCount: ${_this.joinedTeamCount}, recruitTeamCount: ${_this.recruitTeamCount}, newInquiryCount: ${_this.newInquiryCount})';
}


}

/// @nodoc
abstract mixin class $ConcertRecruitmentCopyWith<$Res>  {
  factory $ConcertRecruitmentCopyWith(ConcertRecruitment value, $Res Function(ConcertRecruitment) _then) = _$ConcertRecruitmentCopyWithImpl;
@useResult
$Res call({
 int recruitPostId, RecruitmentStatus status, String deadline, int joinedTeamCount, int recruitTeamCount, int newInquiryCount
});




}
/// @nodoc
class _$ConcertRecruitmentCopyWithImpl<$Res>
    implements $ConcertRecruitmentCopyWith<$Res> {
  _$ConcertRecruitmentCopyWithImpl(this._self, this._then);

  final ConcertRecruitment _self;
  final $Res Function(ConcertRecruitment) _then;

/// Create a copy of ConcertRecruitment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recruitPostId = null,Object? status = null,Object? deadline = null,Object? joinedTeamCount = null,Object? recruitTeamCount = null,Object? newInquiryCount = null,}) {
  return _then(ConcertRecruitment(
recruitPostId: null == recruitPostId ? _self.recruitPostId : recruitPostId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecruitmentStatus,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as String,joinedTeamCount: null == joinedTeamCount ? _self.joinedTeamCount : joinedTeamCount // ignore: cast_nullable_to_non_nullable
as int,recruitTeamCount: null == recruitTeamCount ? _self.recruitTeamCount : recruitTeamCount // ignore: cast_nullable_to_non_nullable
as int,newInquiryCount: null == newInquiryCount ? _self.newInquiryCount : newInquiryCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ConcertRecruitment].
extension ConcertRecruitmentPatterns on ConcertRecruitment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConcertRecruitment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConcertRecruitment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConcertRecruitment value)  $default,){
final _that = this;
switch (_that) {
case _ConcertRecruitment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConcertRecruitment value)?  $default,){
final _that = this;
switch (_that) {
case _ConcertRecruitment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int recruitPostId,  RecruitmentStatus status,  String deadline,  int joinedTeamCount,  int recruitTeamCount,  int newInquiryCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConcertRecruitment() when $default != null:
return $default(_that.recruitPostId,_that.status,_that.deadline,_that.joinedTeamCount,_that.recruitTeamCount,_that.newInquiryCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int recruitPostId,  RecruitmentStatus status,  String deadline,  int joinedTeamCount,  int recruitTeamCount,  int newInquiryCount)  $default,) {final _that = this;
switch (_that) {
case _ConcertRecruitment():
return $default(_that.recruitPostId,_that.status,_that.deadline,_that.joinedTeamCount,_that.recruitTeamCount,_that.newInquiryCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int recruitPostId,  RecruitmentStatus status,  String deadline,  int joinedTeamCount,  int recruitTeamCount,  int newInquiryCount)?  $default,) {final _that = this;
switch (_that) {
case _ConcertRecruitment() when $default != null:
return $default(_that.recruitPostId,_that.status,_that.deadline,_that.joinedTeamCount,_that.recruitTeamCount,_that.newInquiryCount);case _:
  return null;

}
}

}

/// @nodoc


class _ConcertRecruitment implements ConcertRecruitment {
  const _ConcertRecruitment({required this.recruitPostId, required this.status, required this.deadline, required this.joinedTeamCount, required this.recruitTeamCount, required this.newInquiryCount});
  

@override final  int recruitPostId;
@override final  RecruitmentStatus status;
@override final  String deadline;
@override final  int joinedTeamCount;
@override final  int recruitTeamCount;
@override final  int newInquiryCount;

/// Create a copy of ConcertRecruitment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConcertRecruitmentCopyWith<_ConcertRecruitment> get copyWith => __$ConcertRecruitmentCopyWithImpl<_ConcertRecruitment>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConcertRecruitment&&(identical(other.recruitPostId, recruitPostId) || other.recruitPostId == recruitPostId)&&(identical(other.status, status) || other.status == status)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.joinedTeamCount, joinedTeamCount) || other.joinedTeamCount == joinedTeamCount)&&(identical(other.recruitTeamCount, recruitTeamCount) || other.recruitTeamCount == recruitTeamCount)&&(identical(other.newInquiryCount, newInquiryCount) || other.newInquiryCount == newInquiryCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,recruitPostId,status,deadline,joinedTeamCount,recruitTeamCount,newInquiryCount);
}

@override
String toString() {
    return 'ConcertRecruitment(recruitPostId: $recruitPostId, status: $status, deadline: $deadline, joinedTeamCount: $joinedTeamCount, recruitTeamCount: $recruitTeamCount, newInquiryCount: $newInquiryCount)';
}


}

/// @nodoc
abstract mixin class _$ConcertRecruitmentCopyWith<$Res> implements $ConcertRecruitmentCopyWith<$Res> {
  factory _$ConcertRecruitmentCopyWith(_ConcertRecruitment value, $Res Function(_ConcertRecruitment) _then) = __$ConcertRecruitmentCopyWithImpl;
@override @useResult
$Res call({
 int recruitPostId, RecruitmentStatus status, String deadline, int joinedTeamCount, int recruitTeamCount, int newInquiryCount
});




}
/// @nodoc
class __$ConcertRecruitmentCopyWithImpl<$Res>
    implements _$ConcertRecruitmentCopyWith<$Res> {
  __$ConcertRecruitmentCopyWithImpl(this._self, this._then);

  final _ConcertRecruitment _self;
  final $Res Function(_ConcertRecruitment) _then;

/// Create a copy of ConcertRecruitment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recruitPostId = null,Object? status = null,Object? deadline = null,Object? joinedTeamCount = null,Object? recruitTeamCount = null,Object? newInquiryCount = null,}) {
  return _then(_ConcertRecruitment(
recruitPostId: null == recruitPostId ? _self.recruitPostId : recruitPostId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecruitmentStatus,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as String,joinedTeamCount: null == joinedTeamCount ? _self.joinedTeamCount : joinedTeamCount // ignore: cast_nullable_to_non_nullable
as int,recruitTeamCount: null == recruitTeamCount ? _self.recruitTeamCount : recruitTeamCount // ignore: cast_nullable_to_non_nullable
as int,newInquiryCount: null == newInquiryCount ? _self.newInquiryCount : newInquiryCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
