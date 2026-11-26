// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'term.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Term {

/// 동의 저장 때 `termId`로 보낸다.
 int get id;/// 화면에 보이는 제목 (예: `서비스 이용약관`).
 String get title;/// 필수 약관이면 동의해야 다음으로 갈 수 있다.
 bool get required;/// 본문 페이지 주소. 없으면 "보기"를 보이지 않는다 (예: 만 14세 이상 확인).
 String? get contentUrl;
/// Create a copy of Term
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TermCopyWith<Term> get copyWith => _$TermCopyWithImpl<Term>(this as Term, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Term;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Term&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.required, _this.required) || other.required == _this.required)&&(identical(other.contentUrl, _this.contentUrl) || other.contentUrl == _this.contentUrl));
}


@override
int get hashCode {
  final _this = this as Term;
  return Object.hash(runtimeType,_this.id,_this.title,_this.required,_this.contentUrl);
}

@override
String toString() {
  final _this = this as Term;
  return 'Term(id: ${_this.id}, title: ${_this.title}, required: ${_this.required}, contentUrl: ${_this.contentUrl})';
}


}

/// @nodoc
abstract mixin class $TermCopyWith<$Res>  {
  factory $TermCopyWith(Term value, $Res Function(Term) _then) = _$TermCopyWithImpl;
@useResult
$Res call({
 int id, String title, bool required, String? contentUrl
});




}
/// @nodoc
class _$TermCopyWithImpl<$Res>
    implements $TermCopyWith<$Res> {
  _$TermCopyWithImpl(this._self, this._then);

  final Term _self;
  final $Res Function(Term) _then;

/// Create a copy of Term
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? required = null,Object? contentUrl = freezed,}) {
  return _then(Term(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,required: null == required ? _self.required : required // ignore: cast_nullable_to_non_nullable
as bool,contentUrl: freezed == contentUrl ? _self.contentUrl : contentUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Term].
extension TermPatterns on Term {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Term value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Term() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Term value)  $default,){
final _that = this;
switch (_that) {
case _Term():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Term value)?  $default,){
final _that = this;
switch (_that) {
case _Term() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  bool required,  String? contentUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Term() when $default != null:
return $default(_that.id,_that.title,_that.required,_that.contentUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  bool required,  String? contentUrl)  $default,) {final _that = this;
switch (_that) {
case _Term():
return $default(_that.id,_that.title,_that.required,_that.contentUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  bool required,  String? contentUrl)?  $default,) {final _that = this;
switch (_that) {
case _Term() when $default != null:
return $default(_that.id,_that.title,_that.required,_that.contentUrl);case _:
  return null;

}
}

}

/// @nodoc


class _Term implements Term {
  const _Term({required this.id, required this.title, required this.required, this.contentUrl});
  

/// 동의 저장 때 `termId`로 보낸다.
@override final  int id;
/// 화면에 보이는 제목 (예: `서비스 이용약관`).
@override final  String title;
/// 필수 약관이면 동의해야 다음으로 갈 수 있다.
@override final  bool required;
/// 본문 페이지 주소. 없으면 "보기"를 보이지 않는다 (예: 만 14세 이상 확인).
@override final  String? contentUrl;

/// Create a copy of Term
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TermCopyWith<_Term> get copyWith => __$TermCopyWithImpl<_Term>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Term&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.required, required) || other.required == required)&&(identical(other.contentUrl, contentUrl) || other.contentUrl == contentUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,required,contentUrl);
}

@override
String toString() {
    return 'Term(id: $id, title: $title, required: $required, contentUrl: $contentUrl)';
}


}

/// @nodoc
abstract mixin class _$TermCopyWith<$Res> implements $TermCopyWith<$Res> {
  factory _$TermCopyWith(_Term value, $Res Function(_Term) _then) = __$TermCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, bool required, String? contentUrl
});




}
/// @nodoc
class __$TermCopyWithImpl<$Res>
    implements _$TermCopyWith<$Res> {
  __$TermCopyWithImpl(this._self, this._then);

  final _Term _self;
  final $Res Function(_Term) _then;

/// Create a copy of Term
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? required = null,Object? contentUrl = freezed,}) {
  return _then(_Term(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,required: null == required ? _self.required : required // ignore: cast_nullable_to_non_nullable
as bool,contentUrl: freezed == contentUrl ? _self.contentUrl : contentUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
