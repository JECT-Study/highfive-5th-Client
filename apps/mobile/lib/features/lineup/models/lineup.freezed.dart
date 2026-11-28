// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lineup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Lineup {

 List<LineupTeam> get teams; int get emptySlotCount;
/// Create a copy of Lineup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineupCopyWith<Lineup> get copyWith => _$LineupCopyWithImpl<Lineup>(this as Lineup, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Lineup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lineup&&const DeepCollectionEquality().equals(other.teams, _this.teams)&&(identical(other.emptySlotCount, _this.emptySlotCount) || other.emptySlotCount == _this.emptySlotCount));
}


@override
int get hashCode {
  final _this = this as Lineup;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.teams),_this.emptySlotCount);
}

@override
String toString() {
  final _this = this as Lineup;
  return 'Lineup(teams: ${_this.teams}, emptySlotCount: ${_this.emptySlotCount})';
}


}

/// @nodoc
abstract mixin class $LineupCopyWith<$Res>  {
  factory $LineupCopyWith(Lineup value, $Res Function(Lineup) _then) = _$LineupCopyWithImpl;
@useResult
$Res call({
 List<LineupTeam> teams, int emptySlotCount
});




}
/// @nodoc
class _$LineupCopyWithImpl<$Res>
    implements $LineupCopyWith<$Res> {
  _$LineupCopyWithImpl(this._self, this._then);

  final Lineup _self;
  final $Res Function(Lineup) _then;

/// Create a copy of Lineup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teams = null,Object? emptySlotCount = null,}) {
  return _then(Lineup(
teams: null == teams ? _self.teams : teams // ignore: cast_nullable_to_non_nullable
as List<LineupTeam>,emptySlotCount: null == emptySlotCount ? _self.emptySlotCount : emptySlotCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Lineup].
extension LineupPatterns on Lineup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lineup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lineup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lineup value)  $default,){
final _that = this;
switch (_that) {
case _Lineup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lineup value)?  $default,){
final _that = this;
switch (_that) {
case _Lineup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LineupTeam> teams,  int emptySlotCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lineup() when $default != null:
return $default(_that.teams,_that.emptySlotCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LineupTeam> teams,  int emptySlotCount)  $default,) {final _that = this;
switch (_that) {
case _Lineup():
return $default(_that.teams,_that.emptySlotCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LineupTeam> teams,  int emptySlotCount)?  $default,) {final _that = this;
switch (_that) {
case _Lineup() when $default != null:
return $default(_that.teams,_that.emptySlotCount);case _:
  return null;

}
}

}

/// @nodoc


class _Lineup implements Lineup {
  const _Lineup({required  List<LineupTeam> teams, required this.emptySlotCount}): _teams = teams;
  

 final  List<LineupTeam> _teams;
@override List<LineupTeam> get teams {
  if (_teams is EqualUnmodifiableListView) return _teams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_teams);
}

@override final  int emptySlotCount;

/// Create a copy of Lineup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineupCopyWith<_Lineup> get copyWith => __$LineupCopyWithImpl<_Lineup>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lineup&&const DeepCollectionEquality().equals(other.teams, _teams)&&(identical(other.emptySlotCount, emptySlotCount) || other.emptySlotCount == emptySlotCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_teams),emptySlotCount);
}

@override
String toString() {
    return 'Lineup(teams: $teams, emptySlotCount: $emptySlotCount)';
}


}

/// @nodoc
abstract mixin class _$LineupCopyWith<$Res> implements $LineupCopyWith<$Res> {
  factory _$LineupCopyWith(_Lineup value, $Res Function(_Lineup) _then) = __$LineupCopyWithImpl;
@override @useResult
$Res call({
 List<LineupTeam> teams, int emptySlotCount
});




}
/// @nodoc
class __$LineupCopyWithImpl<$Res>
    implements _$LineupCopyWith<$Res> {
  __$LineupCopyWithImpl(this._self, this._then);

  final _Lineup _self;
  final $Res Function(_Lineup) _then;

/// Create a copy of Lineup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teams = null,Object? emptySlotCount = null,}) {
  return _then(_Lineup(
teams: null == teams ? _self._teams : teams // ignore: cast_nullable_to_non_nullable
as List<LineupTeam>,emptySlotCount: null == emptySlotCount ? _self.emptySlotCount : emptySlotCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$LineupTeam {

 int get concertTeamId; int get lineupOrder; bool get isHost; LineupBand get band; List<String> get setlistPreview; int get setlistTotalCount;
/// Create a copy of LineupTeam
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineupTeamCopyWith<LineupTeam> get copyWith => _$LineupTeamCopyWithImpl<LineupTeam>(this as LineupTeam, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LineupTeam;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineupTeam&&(identical(other.concertTeamId, _this.concertTeamId) || other.concertTeamId == _this.concertTeamId)&&(identical(other.lineupOrder, _this.lineupOrder) || other.lineupOrder == _this.lineupOrder)&&(identical(other.isHost, _this.isHost) || other.isHost == _this.isHost)&&(identical(other.band, _this.band) || other.band == _this.band)&&const DeepCollectionEquality().equals(other.setlistPreview, _this.setlistPreview)&&(identical(other.setlistTotalCount, _this.setlistTotalCount) || other.setlistTotalCount == _this.setlistTotalCount));
}


@override
int get hashCode {
  final _this = this as LineupTeam;
  return Object.hash(runtimeType,_this.concertTeamId,_this.lineupOrder,_this.isHost,_this.band,const DeepCollectionEquality().hash(_this.setlistPreview),_this.setlistTotalCount);
}

@override
String toString() {
  final _this = this as LineupTeam;
  return 'LineupTeam(concertTeamId: ${_this.concertTeamId}, lineupOrder: ${_this.lineupOrder}, isHost: ${_this.isHost}, band: ${_this.band}, setlistPreview: ${_this.setlistPreview}, setlistTotalCount: ${_this.setlistTotalCount})';
}


}

/// @nodoc
abstract mixin class $LineupTeamCopyWith<$Res>  {
  factory $LineupTeamCopyWith(LineupTeam value, $Res Function(LineupTeam) _then) = _$LineupTeamCopyWithImpl;
@useResult
$Res call({
 int concertTeamId, int lineupOrder, bool isHost, LineupBand band, List<String> setlistPreview, int setlistTotalCount
});


$LineupBandCopyWith<$Res> get band;

}
/// @nodoc
class _$LineupTeamCopyWithImpl<$Res>
    implements $LineupTeamCopyWith<$Res> {
  _$LineupTeamCopyWithImpl(this._self, this._then);

  final LineupTeam _self;
  final $Res Function(LineupTeam) _then;

/// Create a copy of LineupTeam
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? concertTeamId = null,Object? lineupOrder = null,Object? isHost = null,Object? band = null,Object? setlistPreview = null,Object? setlistTotalCount = null,}) {
  return _then(LineupTeam(
concertTeamId: null == concertTeamId ? _self.concertTeamId : concertTeamId // ignore: cast_nullable_to_non_nullable
as int,lineupOrder: null == lineupOrder ? _self.lineupOrder : lineupOrder // ignore: cast_nullable_to_non_nullable
as int,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,band: null == band ? _self.band : band // ignore: cast_nullable_to_non_nullable
as LineupBand,setlistPreview: null == setlistPreview ? _self.setlistPreview : setlistPreview // ignore: cast_nullable_to_non_nullable
as List<String>,setlistTotalCount: null == setlistTotalCount ? _self.setlistTotalCount : setlistTotalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of LineupTeam
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LineupBandCopyWith<$Res> get band {
  
  return $LineupBandCopyWith<$Res>(_self.band, (value) {
    return _then(_self.copyWith(band: value));
  });
}
}


/// Adds pattern-matching-related methods to [LineupTeam].
extension LineupTeamPatterns on LineupTeam {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineupTeam value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineupTeam() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineupTeam value)  $default,){
final _that = this;
switch (_that) {
case _LineupTeam():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineupTeam value)?  $default,){
final _that = this;
switch (_that) {
case _LineupTeam() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int concertTeamId,  int lineupOrder,  bool isHost,  LineupBand band,  List<String> setlistPreview,  int setlistTotalCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineupTeam() when $default != null:
return $default(_that.concertTeamId,_that.lineupOrder,_that.isHost,_that.band,_that.setlistPreview,_that.setlistTotalCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int concertTeamId,  int lineupOrder,  bool isHost,  LineupBand band,  List<String> setlistPreview,  int setlistTotalCount)  $default,) {final _that = this;
switch (_that) {
case _LineupTeam():
return $default(_that.concertTeamId,_that.lineupOrder,_that.isHost,_that.band,_that.setlistPreview,_that.setlistTotalCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int concertTeamId,  int lineupOrder,  bool isHost,  LineupBand band,  List<String> setlistPreview,  int setlistTotalCount)?  $default,) {final _that = this;
switch (_that) {
case _LineupTeam() when $default != null:
return $default(_that.concertTeamId,_that.lineupOrder,_that.isHost,_that.band,_that.setlistPreview,_that.setlistTotalCount);case _:
  return null;

}
}

}

/// @nodoc


class _LineupTeam implements LineupTeam {
  const _LineupTeam({required this.concertTeamId, required this.lineupOrder, required this.isHost, required this.band, required  List<String> setlistPreview, required this.setlistTotalCount}): _setlistPreview = setlistPreview;
  

@override final  int concertTeamId;
@override final  int lineupOrder;
@override final  bool isHost;
@override final  LineupBand band;
 final  List<String> _setlistPreview;
@override List<String> get setlistPreview {
  if (_setlistPreview is EqualUnmodifiableListView) return _setlistPreview;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_setlistPreview);
}

@override final  int setlistTotalCount;

/// Create a copy of LineupTeam
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineupTeamCopyWith<_LineupTeam> get copyWith => __$LineupTeamCopyWithImpl<_LineupTeam>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineupTeam&&(identical(other.concertTeamId, concertTeamId) || other.concertTeamId == concertTeamId)&&(identical(other.lineupOrder, lineupOrder) || other.lineupOrder == lineupOrder)&&(identical(other.isHost, isHost) || other.isHost == isHost)&&(identical(other.band, band) || other.band == band)&&const DeepCollectionEquality().equals(other.setlistPreview, _setlistPreview)&&(identical(other.setlistTotalCount, setlistTotalCount) || other.setlistTotalCount == setlistTotalCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,concertTeamId,lineupOrder,isHost,band,const DeepCollectionEquality().hash(_setlistPreview),setlistTotalCount);
}

@override
String toString() {
    return 'LineupTeam(concertTeamId: $concertTeamId, lineupOrder: $lineupOrder, isHost: $isHost, band: $band, setlistPreview: $setlistPreview, setlistTotalCount: $setlistTotalCount)';
}


}

/// @nodoc
abstract mixin class _$LineupTeamCopyWith<$Res> implements $LineupTeamCopyWith<$Res> {
  factory _$LineupTeamCopyWith(_LineupTeam value, $Res Function(_LineupTeam) _then) = __$LineupTeamCopyWithImpl;
@override @useResult
$Res call({
 int concertTeamId, int lineupOrder, bool isHost, LineupBand band, List<String> setlistPreview, int setlistTotalCount
});


@override $LineupBandCopyWith<$Res> get band;

}
/// @nodoc
class __$LineupTeamCopyWithImpl<$Res>
    implements _$LineupTeamCopyWith<$Res> {
  __$LineupTeamCopyWithImpl(this._self, this._then);

  final _LineupTeam _self;
  final $Res Function(_LineupTeam) _then;

/// Create a copy of LineupTeam
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? concertTeamId = null,Object? lineupOrder = null,Object? isHost = null,Object? band = null,Object? setlistPreview = null,Object? setlistTotalCount = null,}) {
  return _then(_LineupTeam(
concertTeamId: null == concertTeamId ? _self.concertTeamId : concertTeamId // ignore: cast_nullable_to_non_nullable
as int,lineupOrder: null == lineupOrder ? _self.lineupOrder : lineupOrder // ignore: cast_nullable_to_non_nullable
as int,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,band: null == band ? _self.band : band // ignore: cast_nullable_to_non_nullable
as LineupBand,setlistPreview: null == setlistPreview ? _self._setlistPreview : setlistPreview // ignore: cast_nullable_to_non_nullable
as List<String>,setlistTotalCount: null == setlistTotalCount ? _self.setlistTotalCount : setlistTotalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of LineupTeam
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LineupBandCopyWith<$Res> get band {
  
  return $LineupBandCopyWith<$Res>(_self.band, (value) {
    return _then(_self.copyWith(band: value));
  });
}
}

/// @nodoc
mixin _$LineupBand {

 int get bandId; String get name; String? get profileImageUrl; List<String> get genres; int get memberCount;
/// Create a copy of LineupBand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineupBandCopyWith<LineupBand> get copyWith => _$LineupBandCopyWithImpl<LineupBand>(this as LineupBand, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LineupBand;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineupBand&&(identical(other.bandId, _this.bandId) || other.bandId == _this.bandId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.profileImageUrl, _this.profileImageUrl) || other.profileImageUrl == _this.profileImageUrl)&&const DeepCollectionEquality().equals(other.genres, _this.genres)&&(identical(other.memberCount, _this.memberCount) || other.memberCount == _this.memberCount));
}


@override
int get hashCode {
  final _this = this as LineupBand;
  return Object.hash(runtimeType,_this.bandId,_this.name,_this.profileImageUrl,const DeepCollectionEquality().hash(_this.genres),_this.memberCount);
}

@override
String toString() {
  final _this = this as LineupBand;
  return 'LineupBand(bandId: ${_this.bandId}, name: ${_this.name}, profileImageUrl: ${_this.profileImageUrl}, genres: ${_this.genres}, memberCount: ${_this.memberCount})';
}


}

/// @nodoc
abstract mixin class $LineupBandCopyWith<$Res>  {
  factory $LineupBandCopyWith(LineupBand value, $Res Function(LineupBand) _then) = _$LineupBandCopyWithImpl;
@useResult
$Res call({
 int bandId, String name, String? profileImageUrl, List<String> genres, int memberCount
});




}
/// @nodoc
class _$LineupBandCopyWithImpl<$Res>
    implements $LineupBandCopyWith<$Res> {
  _$LineupBandCopyWithImpl(this._self, this._then);

  final LineupBand _self;
  final $Res Function(LineupBand) _then;

/// Create a copy of LineupBand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bandId = null,Object? name = null,Object? profileImageUrl = freezed,Object? genres = null,Object? memberCount = null,}) {
  return _then(LineupBand(
bandId: null == bandId ? _self.bandId : bandId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LineupBand].
extension LineupBandPatterns on LineupBand {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineupBand value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineupBand() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineupBand value)  $default,){
final _that = this;
switch (_that) {
case _LineupBand():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineupBand value)?  $default,){
final _that = this;
switch (_that) {
case _LineupBand() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bandId,  String name,  String? profileImageUrl,  List<String> genres,  int memberCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineupBand() when $default != null:
return $default(_that.bandId,_that.name,_that.profileImageUrl,_that.genres,_that.memberCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bandId,  String name,  String? profileImageUrl,  List<String> genres,  int memberCount)  $default,) {final _that = this;
switch (_that) {
case _LineupBand():
return $default(_that.bandId,_that.name,_that.profileImageUrl,_that.genres,_that.memberCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bandId,  String name,  String? profileImageUrl,  List<String> genres,  int memberCount)?  $default,) {final _that = this;
switch (_that) {
case _LineupBand() when $default != null:
return $default(_that.bandId,_that.name,_that.profileImageUrl,_that.genres,_that.memberCount);case _:
  return null;

}
}

}

/// @nodoc


class _LineupBand implements LineupBand {
  const _LineupBand({required this.bandId, required this.name, this.profileImageUrl, required  List<String> genres, required this.memberCount}): _genres = genres;
  

@override final  int bandId;
@override final  String name;
@override final  String? profileImageUrl;
 final  List<String> _genres;
@override List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override final  int memberCount;

/// Create a copy of LineupBand
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineupBandCopyWith<_LineupBand> get copyWith => __$LineupBandCopyWithImpl<_LineupBand>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineupBand&&(identical(other.bandId, bandId) || other.bandId == bandId)&&(identical(other.name, name) || other.name == name)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&const DeepCollectionEquality().equals(other.genres, _genres)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,bandId,name,profileImageUrl,const DeepCollectionEquality().hash(_genres),memberCount);
}

@override
String toString() {
    return 'LineupBand(bandId: $bandId, name: $name, profileImageUrl: $profileImageUrl, genres: $genres, memberCount: $memberCount)';
}


}

/// @nodoc
abstract mixin class _$LineupBandCopyWith<$Res> implements $LineupBandCopyWith<$Res> {
  factory _$LineupBandCopyWith(_LineupBand value, $Res Function(_LineupBand) _then) = __$LineupBandCopyWithImpl;
@override @useResult
$Res call({
 int bandId, String name, String? profileImageUrl, List<String> genres, int memberCount
});




}
/// @nodoc
class __$LineupBandCopyWithImpl<$Res>
    implements _$LineupBandCopyWith<$Res> {
  __$LineupBandCopyWithImpl(this._self, this._then);

  final _LineupBand _self;
  final $Res Function(_LineupBand) _then;

/// Create a copy of LineupBand
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bandId = null,Object? name = null,Object? profileImageUrl = freezed,Object? genres = null,Object? memberCount = null,}) {
  return _then(_LineupBand(
bandId: null == bandId ? _self.bandId : bandId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$BandSetlist {

 bool get isHost; bool get canEdit; LineupBand get band; List<LineupSong> get songs;
/// Create a copy of BandSetlist
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BandSetlistCopyWith<BandSetlist> get copyWith => _$BandSetlistCopyWithImpl<BandSetlist>(this as BandSetlist, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BandSetlist;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BandSetlist&&(identical(other.isHost, _this.isHost) || other.isHost == _this.isHost)&&(identical(other.canEdit, _this.canEdit) || other.canEdit == _this.canEdit)&&(identical(other.band, _this.band) || other.band == _this.band)&&const DeepCollectionEquality().equals(other.songs, _this.songs));
}


@override
int get hashCode {
  final _this = this as BandSetlist;
  return Object.hash(runtimeType,_this.isHost,_this.canEdit,_this.band,const DeepCollectionEquality().hash(_this.songs));
}

@override
String toString() {
  final _this = this as BandSetlist;
  return 'BandSetlist(isHost: ${_this.isHost}, canEdit: ${_this.canEdit}, band: ${_this.band}, songs: ${_this.songs})';
}


}

/// @nodoc
abstract mixin class $BandSetlistCopyWith<$Res>  {
  factory $BandSetlistCopyWith(BandSetlist value, $Res Function(BandSetlist) _then) = _$BandSetlistCopyWithImpl;
@useResult
$Res call({
 bool isHost, bool canEdit, LineupBand band, List<LineupSong> songs
});


$LineupBandCopyWith<$Res> get band;

}
/// @nodoc
class _$BandSetlistCopyWithImpl<$Res>
    implements $BandSetlistCopyWith<$Res> {
  _$BandSetlistCopyWithImpl(this._self, this._then);

  final BandSetlist _self;
  final $Res Function(BandSetlist) _then;

/// Create a copy of BandSetlist
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isHost = null,Object? canEdit = null,Object? band = null,Object? songs = null,}) {
  return _then(BandSetlist(
isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,canEdit: null == canEdit ? _self.canEdit : canEdit // ignore: cast_nullable_to_non_nullable
as bool,band: null == band ? _self.band : band // ignore: cast_nullable_to_non_nullable
as LineupBand,songs: null == songs ? _self.songs : songs // ignore: cast_nullable_to_non_nullable
as List<LineupSong>,
  ));
}
/// Create a copy of BandSetlist
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LineupBandCopyWith<$Res> get band {
  
  return $LineupBandCopyWith<$Res>(_self.band, (value) {
    return _then(_self.copyWith(band: value));
  });
}
}


/// Adds pattern-matching-related methods to [BandSetlist].
extension BandSetlistPatterns on BandSetlist {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BandSetlist value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BandSetlist() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BandSetlist value)  $default,){
final _that = this;
switch (_that) {
case _BandSetlist():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BandSetlist value)?  $default,){
final _that = this;
switch (_that) {
case _BandSetlist() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isHost,  bool canEdit,  LineupBand band,  List<LineupSong> songs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BandSetlist() when $default != null:
return $default(_that.isHost,_that.canEdit,_that.band,_that.songs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isHost,  bool canEdit,  LineupBand band,  List<LineupSong> songs)  $default,) {final _that = this;
switch (_that) {
case _BandSetlist():
return $default(_that.isHost,_that.canEdit,_that.band,_that.songs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isHost,  bool canEdit,  LineupBand band,  List<LineupSong> songs)?  $default,) {final _that = this;
switch (_that) {
case _BandSetlist() when $default != null:
return $default(_that.isHost,_that.canEdit,_that.band,_that.songs);case _:
  return null;

}
}

}

/// @nodoc


class _BandSetlist implements BandSetlist {
  const _BandSetlist({required this.isHost, required this.canEdit, required this.band, required  List<LineupSong> songs}): _songs = songs;
  

@override final  bool isHost;
@override final  bool canEdit;
@override final  LineupBand band;
 final  List<LineupSong> _songs;
@override List<LineupSong> get songs {
  if (_songs is EqualUnmodifiableListView) return _songs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_songs);
}


/// Create a copy of BandSetlist
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BandSetlistCopyWith<_BandSetlist> get copyWith => __$BandSetlistCopyWithImpl<_BandSetlist>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BandSetlist&&(identical(other.isHost, isHost) || other.isHost == isHost)&&(identical(other.canEdit, canEdit) || other.canEdit == canEdit)&&(identical(other.band, band) || other.band == band)&&const DeepCollectionEquality().equals(other.songs, _songs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isHost,canEdit,band,const DeepCollectionEquality().hash(_songs));
}

@override
String toString() {
    return 'BandSetlist(isHost: $isHost, canEdit: $canEdit, band: $band, songs: $songs)';
}


}

/// @nodoc
abstract mixin class _$BandSetlistCopyWith<$Res> implements $BandSetlistCopyWith<$Res> {
  factory _$BandSetlistCopyWith(_BandSetlist value, $Res Function(_BandSetlist) _then) = __$BandSetlistCopyWithImpl;
@override @useResult
$Res call({
 bool isHost, bool canEdit, LineupBand band, List<LineupSong> songs
});


@override $LineupBandCopyWith<$Res> get band;

}
/// @nodoc
class __$BandSetlistCopyWithImpl<$Res>
    implements _$BandSetlistCopyWith<$Res> {
  __$BandSetlistCopyWithImpl(this._self, this._then);

  final _BandSetlist _self;
  final $Res Function(_BandSetlist) _then;

/// Create a copy of BandSetlist
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isHost = null,Object? canEdit = null,Object? band = null,Object? songs = null,}) {
  return _then(_BandSetlist(
isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,canEdit: null == canEdit ? _self.canEdit : canEdit // ignore: cast_nullable_to_non_nullable
as bool,band: null == band ? _self.band : band // ignore: cast_nullable_to_non_nullable
as LineupBand,songs: null == songs ? _self._songs : songs // ignore: cast_nullable_to_non_nullable
as List<LineupSong>,
  ));
}

/// Create a copy of BandSetlist
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LineupBandCopyWith<$Res> get band {
  
  return $LineupBandCopyWith<$Res>(_self.band, (value) {
    return _then(_self.copyWith(band: value));
  });
}
}

/// @nodoc
mixin _$LineupSong {

 SongType get type; String get songTitle; String? get trackId; String? get artist; int? get durationSeconds; String? get albumImageUrl; String? get externalUrl;
/// Create a copy of LineupSong
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineupSongCopyWith<LineupSong> get copyWith => _$LineupSongCopyWithImpl<LineupSong>(this as LineupSong, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LineupSong;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineupSong&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.songTitle, _this.songTitle) || other.songTitle == _this.songTitle)&&(identical(other.trackId, _this.trackId) || other.trackId == _this.trackId)&&(identical(other.artist, _this.artist) || other.artist == _this.artist)&&(identical(other.durationSeconds, _this.durationSeconds) || other.durationSeconds == _this.durationSeconds)&&(identical(other.albumImageUrl, _this.albumImageUrl) || other.albumImageUrl == _this.albumImageUrl)&&(identical(other.externalUrl, _this.externalUrl) || other.externalUrl == _this.externalUrl));
}


@override
int get hashCode {
  final _this = this as LineupSong;
  return Object.hash(runtimeType,_this.type,_this.songTitle,_this.trackId,_this.artist,_this.durationSeconds,_this.albumImageUrl,_this.externalUrl);
}

@override
String toString() {
  final _this = this as LineupSong;
  return 'LineupSong(type: ${_this.type}, songTitle: ${_this.songTitle}, trackId: ${_this.trackId}, artist: ${_this.artist}, durationSeconds: ${_this.durationSeconds}, albumImageUrl: ${_this.albumImageUrl}, externalUrl: ${_this.externalUrl})';
}


}

/// @nodoc
abstract mixin class $LineupSongCopyWith<$Res>  {
  factory $LineupSongCopyWith(LineupSong value, $Res Function(LineupSong) _then) = _$LineupSongCopyWithImpl;
@useResult
$Res call({
 SongType type, String songTitle, String? trackId, String? artist, int? durationSeconds, String? albumImageUrl, String? externalUrl
});




}
/// @nodoc
class _$LineupSongCopyWithImpl<$Res>
    implements $LineupSongCopyWith<$Res> {
  _$LineupSongCopyWithImpl(this._self, this._then);

  final LineupSong _self;
  final $Res Function(LineupSong) _then;

/// Create a copy of LineupSong
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? songTitle = null,Object? trackId = freezed,Object? artist = freezed,Object? durationSeconds = freezed,Object? albumImageUrl = freezed,Object? externalUrl = freezed,}) {
  return _then(LineupSong(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SongType,songTitle: null == songTitle ? _self.songTitle : songTitle // ignore: cast_nullable_to_non_nullable
as String,trackId: freezed == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String?,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,albumImageUrl: freezed == albumImageUrl ? _self.albumImageUrl : albumImageUrl // ignore: cast_nullable_to_non_nullable
as String?,externalUrl: freezed == externalUrl ? _self.externalUrl : externalUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LineupSong].
extension LineupSongPatterns on LineupSong {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineupSong value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineupSong() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineupSong value)  $default,){
final _that = this;
switch (_that) {
case _LineupSong():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineupSong value)?  $default,){
final _that = this;
switch (_that) {
case _LineupSong() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SongType type,  String songTitle,  String? trackId,  String? artist,  int? durationSeconds,  String? albumImageUrl,  String? externalUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineupSong() when $default != null:
return $default(_that.type,_that.songTitle,_that.trackId,_that.artist,_that.durationSeconds,_that.albumImageUrl,_that.externalUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SongType type,  String songTitle,  String? trackId,  String? artist,  int? durationSeconds,  String? albumImageUrl,  String? externalUrl)  $default,) {final _that = this;
switch (_that) {
case _LineupSong():
return $default(_that.type,_that.songTitle,_that.trackId,_that.artist,_that.durationSeconds,_that.albumImageUrl,_that.externalUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SongType type,  String songTitle,  String? trackId,  String? artist,  int? durationSeconds,  String? albumImageUrl,  String? externalUrl)?  $default,) {final _that = this;
switch (_that) {
case _LineupSong() when $default != null:
return $default(_that.type,_that.songTitle,_that.trackId,_that.artist,_that.durationSeconds,_that.albumImageUrl,_that.externalUrl);case _:
  return null;

}
}

}

/// @nodoc


class _LineupSong implements LineupSong {
  const _LineupSong({required this.type, required this.songTitle, this.trackId, this.artist, this.durationSeconds, this.albumImageUrl, this.externalUrl});
  

@override final  SongType type;
@override final  String songTitle;
@override final  String? trackId;
@override final  String? artist;
@override final  int? durationSeconds;
@override final  String? albumImageUrl;
@override final  String? externalUrl;

/// Create a copy of LineupSong
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineupSongCopyWith<_LineupSong> get copyWith => __$LineupSongCopyWithImpl<_LineupSong>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineupSong&&(identical(other.type, type) || other.type == type)&&(identical(other.songTitle, songTitle) || other.songTitle == songTitle)&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.albumImageUrl, albumImageUrl) || other.albumImageUrl == albumImageUrl)&&(identical(other.externalUrl, externalUrl) || other.externalUrl == externalUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,type,songTitle,trackId,artist,durationSeconds,albumImageUrl,externalUrl);
}

@override
String toString() {
    return 'LineupSong(type: $type, songTitle: $songTitle, trackId: $trackId, artist: $artist, durationSeconds: $durationSeconds, albumImageUrl: $albumImageUrl, externalUrl: $externalUrl)';
}


}

/// @nodoc
abstract mixin class _$LineupSongCopyWith<$Res> implements $LineupSongCopyWith<$Res> {
  factory _$LineupSongCopyWith(_LineupSong value, $Res Function(_LineupSong) _then) = __$LineupSongCopyWithImpl;
@override @useResult
$Res call({
 SongType type, String songTitle, String? trackId, String? artist, int? durationSeconds, String? albumImageUrl, String? externalUrl
});




}
/// @nodoc
class __$LineupSongCopyWithImpl<$Res>
    implements _$LineupSongCopyWith<$Res> {
  __$LineupSongCopyWithImpl(this._self, this._then);

  final _LineupSong _self;
  final $Res Function(_LineupSong) _then;

/// Create a copy of LineupSong
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? songTitle = null,Object? trackId = freezed,Object? artist = freezed,Object? durationSeconds = freezed,Object? albumImageUrl = freezed,Object? externalUrl = freezed,}) {
  return _then(_LineupSong(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SongType,songTitle: null == songTitle ? _self.songTitle : songTitle // ignore: cast_nullable_to_non_nullable
as String,trackId: freezed == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String?,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,albumImageUrl: freezed == albumImageUrl ? _self.albumImageUrl : albumImageUrl // ignore: cast_nullable_to_non_nullable
as String?,externalUrl: freezed == externalUrl ? _self.externalUrl : externalUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
