import 'package:device_info_plus/device_info_plus.dart';

abstract class IDeviceModelProvider {
  Future<String> readDisplayModel();
}

class DeviceModelProvider implements IDeviceModelProvider {
  DeviceModelProvider({DeviceInfoPlugin? deviceInfoPlugin})
    : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfoPlugin;

  @override
  Future<String> readDisplayModel() async {
    try {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      return _normalize(androidInfo.model);
    } catch (_) {
      return 'Unknown device';
    }
  }

  String _normalize(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      return 'Unknown device';
    }

    final parts = trimmed.split('-').where((part) => part.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0]}-${parts[1]}';
    }

    return trimmed;
  }
}
