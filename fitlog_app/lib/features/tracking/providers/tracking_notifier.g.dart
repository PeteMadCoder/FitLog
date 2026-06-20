// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trackingNotifierHash() => r'7b9eaec67f2348db8e64bc4f1486624e980f5ad6';

/// Notifier responsible for managing the active tracking session state
/// and processing real-time telemetry coordinates.
///
/// Copied from [TrackingNotifier].
@ProviderFor(TrackingNotifier)
final trackingNotifierProvider =
    AutoDisposeNotifierProvider<TrackingNotifier, TrackingState>.internal(
  TrackingNotifier.new,
  name: r'trackingNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trackingNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TrackingNotifier = AutoDisposeNotifier<TrackingState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
