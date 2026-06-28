// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_sports_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentSportsHash() => r'3eea462b4228172595cb4333f638cac9ba6ecc25';

/// Provider exposing a list of the 5 most recently used unique [SportType]s.
///
/// Copied from [recentSports].
@ProviderFor(recentSports)
final recentSportsProvider =
    AutoDisposeStreamProvider<List<SportType>>.internal(
  recentSports,
  name: r'recentSportsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$recentSportsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecentSportsRef = AutoDisposeStreamProviderRef<List<SportType>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
