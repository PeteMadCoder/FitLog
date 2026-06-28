// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trackingNotifierHash() => r'f2c88c95aa3a0fa5ac30c7deae6e4c6eaee59272';

/// Notifier responsible for managing the active tracking session state
/// and processing real-time telemetry coordinates.
///
/// Copied from [TrackingNotifier].
@ProviderFor(TrackingNotifier)
final trackingNotifierProvider =
    NotifierProvider<TrackingNotifier, TrackingState>.internal(
  TrackingNotifier.new,
  name: r'trackingNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trackingNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TrackingNotifier = Notifier<TrackingState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
