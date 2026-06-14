// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isarHash() => r'047b349018d4de736936045374d488f8d698ea53';

/// Provider for the local Isar database singleton.
///
/// Copied from [isar].
@ProviderFor(isar)
final isarProvider = AutoDisposeFutureProvider<Isar>.internal(
  isar,
  name: r'isarProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isarHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsarRef = AutoDisposeFutureProviderRef<Isar>;
String _$navigationIndexHash() => r'd414893e1ca6a80fb2253812d81d3fbffa99ea74';

/// Provider to manage the active index of the bottom navigation shell.
///
/// Copied from [NavigationIndex].
@ProviderFor(NavigationIndex)
final navigationIndexProvider =
    AutoDisposeNotifierProvider<NavigationIndex, int>.internal(
  NavigationIndex.new,
  name: r'navigationIndexProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$navigationIndexHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NavigationIndex = AutoDisposeNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
