// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'app_page_path.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$AppPagePath {
  AppPageKinds get kind => throw _privateConstructorUsedError;
  String? get path => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppPagePathCopyWith<AppPagePath> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppPagePathCopyWith<$Res> {
  factory $AppPagePathCopyWith(
          AppPagePath value, $Res Function(AppPagePath) then) =
      _$AppPagePathCopyWithImpl<$Res>;
  $Res call({AppPageKinds kind, String? path});
}

/// @nodoc
class _$AppPagePathCopyWithImpl<$Res> implements $AppPagePathCopyWith<$Res> {
  _$AppPagePathCopyWithImpl(this._value, this._then);

  final AppPagePath _value;
  // ignore: unused_field
  final $Res Function(AppPagePath) _then;

  @override
  $Res call({
    Object? kind = freezed,
    Object? path = freezed,
  }) {
    return _then(_value.copyWith(
      kind: kind == freezed
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as AppPageKinds,
      path: path == freezed
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$AppPagePathCopyWith<$Res>
    implements $AppPagePathCopyWith<$Res> {
  factory _$AppPagePathCopyWith(
          _AppPagePath value, $Res Function(_AppPagePath) then) =
      __$AppPagePathCopyWithImpl<$Res>;
  @override
  $Res call({AppPageKinds kind, String? path});
}

/// @nodoc
class __$AppPagePathCopyWithImpl<$Res> extends _$AppPagePathCopyWithImpl<$Res>
    implements _$AppPagePathCopyWith<$Res> {
  __$AppPagePathCopyWithImpl(
      _AppPagePath _value, $Res Function(_AppPagePath) _then)
      : super(_value, (v) => _then(v as _AppPagePath));

  @override
  _AppPagePath get _value => super._value as _AppPagePath;

  @override
  $Res call({
    Object? kind = freezed,
    Object? path = freezed,
  }) {
    return _then(_AppPagePath(
      kind: kind == freezed
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as AppPageKinds,
      path: path == freezed
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$_AppPagePath extends _AppPagePath with DiagnosticableTreeMixin {
  const _$_AppPagePath({required this.kind, this.path}) : super._();

  @override
  final AppPageKinds kind;
  @override
  final String? path;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AppPagePath(kind: $kind, path: $path)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AppPagePath'))
      ..add(DiagnosticsProperty('kind', kind))
      ..add(DiagnosticsProperty('path', path));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AppPagePath &&
            const DeepCollectionEquality().equals(other.kind, kind) &&
            const DeepCollectionEquality().equals(other.path, path));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(kind),
      const DeepCollectionEquality().hash(path));

  @JsonKey(ignore: true)
  @override
  _$AppPagePathCopyWith<_AppPagePath> get copyWith =>
      __$AppPagePathCopyWithImpl<_AppPagePath>(this, _$identity);
}

abstract class _AppPagePath extends AppPagePath {
  const factory _AppPagePath(
      {required final AppPageKinds kind, final String? path}) = _$_AppPagePath;
  const _AppPagePath._() : super._();

  @override
  AppPageKinds get kind => throw _privateConstructorUsedError;
  @override
  String? get path => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$AppPagePathCopyWith<_AppPagePath> get copyWith =>
      throw _privateConstructorUsedError;
}
