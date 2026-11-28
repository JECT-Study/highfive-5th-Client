// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'concert_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConcertUpdate {

 String get title; List<String> get genres; int get recruitTeamCount; String? get performDate; String? get startTime; String? get endTime; String? get place; String? get address; String? get region; int? get rentalFee; String? get posterImageUrl; int get version;
/// Create a copy of ConcertUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConcertUpdateCopyWith<ConcertUpdate> get copyWith => _$ConcertUpdateCopyWithImpl<ConcertUpdate>(this as ConcertUpdate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConcertUpdate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConcertUpdate&&(identical(other.title, _this.title) || other.title == _this.title)&&const DeepCollectionEquality().equals(other.genres, _this.genres)&&(identical(other.recruitTeamCount, _this.recruitTeamCount) || other.recruitTeamCount == _this.recruitTeamCount)&&(identical(other.performDate, _this.performDate) || other.performDate == _this.performDate)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime)&&(identical(other.place, _this.place) || other.place == _this.place)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.region, _this.region) || other.region == _this.region)&&(identical(other.rentalFee, _this.rentalFee) || other.rentalFee == _this.rentalFee)&&(identical(other.posterImageUrl, _this.posterImageUrl) || other.posterImageUrl == _this.posterImageUrl)&&(identical(other.version, _this.version) || other.version == _this.version));
}


@override
int get hashCode {
  final _this = this as ConcertUpdate;
  return Object.hash(runtimeType,_this.title,const DeepCollectionEquality().hash(_this.genres),_this.recruitTeamCount,_this.performDate,_this.startTime,_this.endTime,_this.place,_this.address,_this.region,_this.rentalFee,_this.posterImageUrl,_this.version);
}

@override
String toString() {
  final _this = this as ConcertUpdate;
  return 'ConcertUpdate(title: ${_this.title}, genres: ${_this.genres}, recruitTeamCount: ${_this.recruitTeamCount}, performDate: ${_this.performDate}, startTime: ${_this.startTime}, endTime: ${_this.endTime}, place: ${_this.place}, address: ${_this.address}, region: ${_this.region}, rentalFee: ${_this.rentalFee}, posterImageUrl: ${_this.posterImageUrl}, version: ${_this.version})';
}


}

/// @nodoc
abstract mixin class $ConcertUpdateCopyWith<$Res>  {
  factory $ConcertUpdateCopyWith(ConcertUpdate value, $Res Function(ConcertUpdate) _then) = _$ConcertUpdateCopyWithImpl;
@useResult
$Res call({
 String title, List<String> genres, int recruitTeamCount, String? performDate, String? startTime, String? endTime, String? place, String? address, String? region, int? rentalFee, String? posterImageUrl, int version
});




}
/// @nodoc
class _$ConcertUpdateCopyWithImpl<$Res>
    implements $ConcertUpdateCopyWith<$Res> {
  _$ConcertUpdateCopyWithImpl(this._self, this._then);

  final ConcertUpdate _self;
  final $Res Function(ConcertUpdate) _then;

/// Create a copy of ConcertUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? genres = null,Object? recruitTeamCount = null,Object? performDate = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? place = freezed,Object? address = freezed,Object? region = freezed,Object? rentalFee = freezed,Object? posterImageUrl = freezed,Object? version = null,}) {
  return _then(ConcertUpdate(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
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
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ConcertUpdate].
extension ConcertUpdatePatterns on ConcertUpdate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConcertUpdate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConcertUpdate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConcertUpdate value)  $default,){
final _that = this;
switch (_that) {
case _ConcertUpdate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConcertUpdate value)?  $default,){
final _that = this;
switch (_that) {
case _ConcertUpdate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  List<String> genres,  int recruitTeamCount,  String? performDate,  String? startTime,  String? endTime,  String? place,  String? address,  String? region,  int? rentalFee,  String? posterImageUrl,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConcertUpdate() when $default != null:
return $default(_that.title,_that.genres,_that.recruitTeamCount,_that.performDate,_that.startTime,_that.endTime,_that.place,_that.address,_that.region,_that.rentalFee,_that.posterImageUrl,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  List<String> genres,  int recruitTeamCount,  String? performDate,  String? startTime,  String? endTime,  String? place,  String? address,  String? region,  int? rentalFee,  String? posterImageUrl,  int version)  $default,) {final _that = this;
switch (_that) {
case _ConcertUpdate():
return $default(_that.title,_that.genres,_that.recruitTeamCount,_that.performDate,_that.startTime,_that.endTime,_that.place,_that.address,_that.region,_that.rentalFee,_that.posterImageUrl,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  List<String> genres,  int recruitTeamCount,  String? performDate,  String? startTime,  String? endTime,  String? place,  String? address,  String? region,  int? rentalFee,  String? posterImageUrl,  int version)?  $default,) {final _that = this;
switch (_that) {
case _ConcertUpdate() when $default != null:
return $default(_that.title,_that.genres,_that.recruitTeamCount,_that.performDate,_that.startTime,_that.endTime,_that.place,_that.address,_that.region,_that.rentalFee,_that.posterImageUrl,_that.version);case _:
  return null;

}
}

}

/// @nodoc


class _ConcertUpdate extends ConcertUpdate {
  const _ConcertUpdate({required this.title, required  List<String> genres, required this.recruitTeamCount, required this.performDate, required this.startTime, required this.endTime, required this.place, required this.address, required this.region, required this.rentalFee, required this.posterImageUrl, required this.version}): _genres = genres,super._();
  

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
@override final  int version;

/// Create a copy of ConcertUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConcertUpdateCopyWith<_ConcertUpdate> get copyWith => __$ConcertUpdateCopyWithImpl<_ConcertUpdate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConcertUpdate&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.genres, _genres)&&(identical(other.recruitTeamCount, recruitTeamCount) || other.recruitTeamCount == recruitTeamCount)&&(identical(other.performDate, performDate) || other.performDate == performDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.place, place) || other.place == place)&&(identical(other.address, address) || other.address == address)&&(identical(other.region, region) || other.region == region)&&(identical(other.rentalFee, rentalFee) || other.rentalFee == rentalFee)&&(identical(other.posterImageUrl, posterImageUrl) || other.posterImageUrl == posterImageUrl)&&(identical(other.version, version) || other.version == version));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_genres),recruitTeamCount,performDate,startTime,endTime,place,address,region,rentalFee,posterImageUrl,version);
}

@override
String toString() {
    return 'ConcertUpdate(title: $title, genres: $genres, recruitTeamCount: $recruitTeamCount, performDate: $performDate, startTime: $startTime, endTime: $endTime, place: $place, address: $address, region: $region, rentalFee: $rentalFee, posterImageUrl: $posterImageUrl, version: $version)';
}


}

/// @nodoc
abstract mixin class _$ConcertUpdateCopyWith<$Res> implements $ConcertUpdateCopyWith<$Res> {
  factory _$ConcertUpdateCopyWith(_ConcertUpdate value, $Res Function(_ConcertUpdate) _then) = __$ConcertUpdateCopyWithImpl;
@override @useResult
$Res call({
 String title, List<String> genres, int recruitTeamCount, String? performDate, String? startTime, String? endTime, String? place, String? address, String? region, int? rentalFee, String? posterImageUrl, int version
});




}
/// @nodoc
class __$ConcertUpdateCopyWithImpl<$Res>
    implements _$ConcertUpdateCopyWith<$Res> {
  __$ConcertUpdateCopyWithImpl(this._self, this._then);

  final _ConcertUpdate _self;
  final $Res Function(_ConcertUpdate) _then;

/// Create a copy of ConcertUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? genres = null,Object? recruitTeamCount = null,Object? performDate = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? place = freezed,Object? address = freezed,Object? region = freezed,Object? rentalFee = freezed,Object? posterImageUrl = freezed,Object? version = null,}) {
  return _then(_ConcertUpdate(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
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
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
