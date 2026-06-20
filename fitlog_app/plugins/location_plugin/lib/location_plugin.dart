
import 'location_plugin_platform_interface.dart';

class LocationPlugin {
  Future<String?> getPlatformVersion() {
    return LocationPluginPlatform.instance.getPlatformVersion();
  }
}
