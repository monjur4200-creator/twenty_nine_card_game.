enum ConnectionType {
  local,       // ✅ Offline
  bluetooth,   // ✅ Offline
  wifi,        // ✅ Offline
  hotspot,     // ❌ Requires Internet
  mobileData,  // ❌ Requires Internet
  online,      // ❌ Requires Internet
}

extension ConnectionTypeMeta on ConnectionType {
  bool get offlineCapable {
    switch (this) {
      case ConnectionType.local:
      case ConnectionType.bluetooth:
      case ConnectionType.wifi:
        return true;
      case ConnectionType.hotspot:
      case ConnectionType.mobileData:
      case ConnectionType.online: // ✅ Added
        return false;
    }
  }

  String get label {
    switch (this) {
      case ConnectionType.local:
        return 'Local';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
      case ConnectionType.wifi:
        return 'Wi-Fi';
      case ConnectionType.hotspot:
        return 'Hotspot';
      case ConnectionType.mobileData:
        return 'Mobile Data';
      case ConnectionType.online: // ✅ Added
        return 'Online';
    }
  }
}