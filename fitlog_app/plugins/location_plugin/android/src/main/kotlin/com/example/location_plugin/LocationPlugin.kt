package com.example.location_plugin

import android.annotation.SuppressLint
import android.content.Context
import android.os.Looper
import com.google.android.gms.location.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

class LocationPlugin : FlutterPlugin, EventChannel.StreamHandler {
    companion object {
        const val EVENT_CHANNEL = "com.example.fitlog_app/location"
    }

    private var eventChannel: EventChannel? = null
    private var fusedClient: FusedLocationProviderClient? = null
    private var locationCallback: LocationCallback? = null
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
        eventChannel!!.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopUpdates()
        eventChannel?.setStreamHandler(null)
        eventChannel = null
    }

    @SuppressLint("MissingPermission")
    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        fusedClient = LocationServices.getFusedLocationProviderClient(context)

        val request = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 1000L)
            .setMinUpdateDistanceMeters(0f)
            .build()

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                for (loc in result.locations) {
                    sink.success(mapOf(
                        "timestamp" to loc.time,
                        "latitude"  to loc.latitude,
                        "longitude" to loc.longitude,
                        "altitude"  to loc.altitude,
                        "accuracy"  to loc.accuracy.toDouble(),
                        "speed"     to loc.speed.toDouble()
                    ))
                }
            }
        }

        fusedClient!!.requestLocationUpdates(request, locationCallback!!, Looper.getMainLooper())
    }

    override fun onCancel(arguments: Any?) = stopUpdates()

    private fun stopUpdates() {
        locationCallback?.let { fusedClient?.removeLocationUpdates(it) }
        locationCallback = null
        fusedClient = null
    }
}
