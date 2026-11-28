// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_concert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MyConcert {

/// 명세 없음: 공연 ID. 카드를 누르면 이 공연의 페이지를 연다.
 int get concertId;/// 명세 없음: 공연 제목.
 String get title;/// 명세 없음: 공연 상태. 공연 페이지 조회와 같은 코드로 추정한다.
 ConcertStatus get status;/// 명세 없음: 공연 날짜(서버 `LocalDate`, 예: `2026-12-20`). null이면 미정.
 String? get performDate;/// 명세 없음: 시작 시각(서버 `LocalTime`, 예: `19:00:00`). null이면 미정.
 String? get startTime;/// 명세 없음: 카드에 보일 지역(예: `서울 마포구`). 주소가 없으면 공연장, 둘 다 없으면 null.
 String? get area;/// 명세 없음: 내 밴드가 이 공연의 주최 팀인지. 대표자 권한과는 따로 본다.
 bool get isHost;/// 명세 없음: 포스터 이미지 URL. null이면 회색 자리를 그린다.
 String? get posterImageUrl;
/// Create a copy of MyConcert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyConcertCopyWith<MyConcert> get copyWith => _$MyConcertCopyWithImpl<MyConcert>(this as MyConcert, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MyConcert;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyConcert&&(identical(other.concertId, _this.concertId) || other.concertId == _this.concertId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.performDate, _this.performDate) || other.performDate == _this.performDate)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.area, _this.area) || other.area == _this.area)&&(identical(other.isHost, _this.isHost) || other.isHost == _this.isHost)&&(identical(other.posterImageUrl, _this.posterImageUrl) || other.posterImageUrl == _this.posterImageUrl));
}


@override
int get hashCode {
  final _this = this as MyConcert;
  return Object.hash(runtimeType,_this.concertId,_this.title,_this.status,_this.performDate,_this.startTime,_this.area,_this.isHost,_this.posterImageUrl);
}

@override
String toString() {
  final _this = this as MyConcert;
  return 'MyConcert(concertId: ${_this.concertId}, title: ${_this.title}, status: ${_this.status}, performDate: ${_this.performDate}, startTime: ${_this.startTime}, area: ${_this.area}, isHost: ${_this.isHost}, posterImageUrl: ${_this.posterImageUrl})';
}


}

/// @nodoc
abstract mixin class $MyConcertCopyWith<$Res>  {
  factory $MyConcertCopyWith(MyConcert value, $Res Function(MyConcert) _then) = _$MyConcertCopyWithImpl;
@useResult
$Res call({
 int concertId, String title, ConcertStatus status, String? performDate, String? startTime, String? area, bool isHost, String? posterImageUrl
});




}
/// @nodoc
class _$MyConcertCopyWithImpl<$Res>
    implements $MyConcertCopyWith<$Res> {
  _$MyConcertCopyWithImpl(this._self, this._then);

  final MyConcert _self;
  final $Res Function(MyConcert) _then;

/// Create a copy of MyConcert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? concertId = null,Object? title = null,Object? status = null,Object? performDate = freezed,Object? startTime = freezed,Object? area = freezed,Object? isHost = null,Object? posterImageUrl = freezed,}) {
  return _then(MyConcert(
concertId: null == concertId ? _self.concertId : concertId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConcertStatus,performDate: freezed == performDate ? _self.performDate : performDate // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,posterImageUrl: freezed == posterImageUrl ? _self.posterImageUrl : posterImageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MyConcert].
extension MyConcertPatterns on MyConcert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyConcert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyConcert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyConcert value)  $default,){
final _that = this;
switch (_that) {
case _MyConcert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyConcert value)?  $default,){
final _that = this;
switch (_that) {
case _MyConcert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int concertId,  String title,  ConcertStatus status,  String? performDate,  String? startTime,  String? area,  bool isHost,  String? posterImageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyConcert() when $default != null:
return $default(_that.concertId,_that.title,_that.status,_that.performDate,_that.startTime,_that.area,_that.isHost,_that.posterImageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int concertId,  String title,  ConcertStatus status,  String? performDate,  String? startTime,  String? area,  bool isHost,  String? posterImageUrl)  $default,) {final _that = this;
switch (_that) {
case _MyConcert():
return $default(_that.concertId,_that.title,_that.status,_that.performDate,_that.startTime,_that.area,_that.isHost,_that.posterImageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int concertId,  String title,  ConcertStatus status,  String? performDate,  String? startTime,  String? area,  bool isHost,  String? posterImageUrl)?  $default,) {final _that = this;
switch (_that) {
case _MyConcert() when $default != null:
return $default(_that.concertId,_that.title,_that.status,_that.performDate,_that.startTime,_that.area,_that.isHost,_that.posterImageUrl);case _:
  return null;

}
}

}

/// @nodoc


class _MyConcert implements MyConcert {
  const _MyConcert({required this.concertId, required this.title, required this.status, required this.performDate, required this.startTime, required this.area, required this.isHost, required this.posterImageUrl});
  

/// 명세 없음: 공연 ID. 카드를 누르면 이 공연의 페이지를 연다.
@override final  int concertId;
/// 명세 없음: 공연 제목.
@override final  String title;
/// 명세 없음: 공연 상태. 공연 페이지 조회와 같은 코드로 추정한다.
@override final  ConcertStatus status;
/// 명세 없음: 공연 날짜(서버 `LocalDate`, 예: `2026-12-20`). null이면 미정.
@override final  String? performDate;
/// 명세 없음: 시작 시각(서버 `LocalTime`, 예: `19:00:00`). null이면 미정.
@override final  String? startTime;
/// 명세 없음: 카드에 보일 지역(예: `서울 마포구`). 주소가 없으면 공연장, 둘 다 없으면 null.
@override final  String? area;
/// 명세 없음: 내 밴드가 이 공연의 주최 팀인지. 대표자 권한과는 따로 본다.
@override final  bool isHost;
/// 명세 없음: 포스터 이미지 URL. null이면 회색 자리를 그린다.
@override final  String? posterImageUrl;

/// Create a copy of MyConcert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyConcertCopyWith<_MyConcert> get copyWith => __$MyConcertCopyWithImpl<_MyConcert>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyConcert&&(identical(other.concertId, concertId) || other.concertId == concertId)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.performDate, performDate) || other.performDate == performDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.area, area) || other.area == area)&&(identical(other.isHost, isHost) || other.isHost == isHost)&&(identical(other.posterImageUrl, posterImageUrl) || other.posterImageUrl == posterImageUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,concertId,title,status,performDate,startTime,area,isHost,posterImageUrl);
}

@override
String toString() {
    return 'MyConcert(concertId: $concertId, title: $title, status: $status, performDate: $performDate, startTime: $startTime, area: $area, isHost: $isHost, posterImageUrl: $posterImageUrl)';
}


}

/// @nodoc
abstract mixin class _$MyConcertCopyWith<$Res> implements $MyConcertCopyWith<$Res> {
  factory _$MyConcertCopyWith(_MyConcert value, $Res Function(_MyConcert) _then) = __$MyConcertCopyWithImpl;
@override @useResult
$Res call({
 int concertId, String title, ConcertStatus status, String? performDate, String? startTime, String? area, bool isHost, String? posterImageUrl
});




}
/// @nodoc
class __$MyConcertCopyWithImpl<$Res>
    implements _$MyConcertCopyWith<$Res> {
  __$MyConcertCopyWithImpl(this._self, this._then);

  final _MyConcert _self;
  final $Res Function(_MyConcert) _then;

/// Create a copy of MyConcert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? concertId = null,Object? title = null,Object? status = null,Object? performDate = freezed,Object? startTime = freezed,Object? area = freezed,Object? isHost = null,Object? posterImageUrl = freezed,}) {
  return _then(_MyConcert(
concertId: null == concertId ? _self.concertId : concertId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConcertStatus,performDate: freezed == performDate ? _self.performDate : performDate // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,posterImageUrl: freezed == posterImageUrl ? _self.posterImageUrl : posterImageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
