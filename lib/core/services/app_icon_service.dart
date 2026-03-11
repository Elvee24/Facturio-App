import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:universal_io/io.dart';

import '../models/app_theme.dart';

enum AppIconSyncStatus {
  synced,
  alreadySynced,
  launcherNotFound,
  unsupportedPlatform,
  invalidIcon,
  failed,
}

class AppIconSyncResult {
  final AppIconSyncStatus status;

  const AppIconSyncResult(this.status);

  bool get isSuccess =>
      status == AppIconSyncStatus.synced ||
      status == AppIconSyncStatus.alreadySynced;
}

class AppIconService {
  static const MethodChannel _channel = MethodChannel('facturio/app_icon');

  static bool get supportsManualSync =>
      !kIsWeb && (Platform.isLinux || Platform.isAndroid || Platform.isIOS);

  static bool get supportsNativeMobileIcon =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<AppIconSyncResult> syncLauncherIcon(AppIcon appIcon) async {
    if (kIsWeb) {
      return const AppIconSyncResult(AppIconSyncStatus.unsupportedPlatform);
    }

    if (Platform.isAndroid || Platform.isIOS) {
      return _syncMobileIcon(appIcon);
    }

    if (!Platform.isLinux || appIcon.assetPath == null) {
      return const AppIconSyncResult(
        AppIconSyncStatus.unsupportedPlatform,
      );
    }

    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      return const AppIconSyncResult(AppIconSyncStatus.failed);
    }

    final iconFile = File('$home/.local/share/icons/hicolor/scalable/apps/Facturio.svg');
    final desktopFile = File('$home/.local/share/applications/Facturio.desktop');

    try {
      if (!await desktopFile.exists()) {
        return const AppIconSyncResult(AppIconSyncStatus.launcherNotFound);
      }

      final svgContent = await rootBundle.loadString(appIcon.assetPath!);
      final desktopContent = await desktopFile.readAsString();
      final iconLine = 'Icon=${iconFile.path}';
      final updatedContent = desktopContent.contains(RegExp(r'^Icon=.*$', multiLine: true))
          ? desktopContent.replaceFirst(RegExp(r'^Icon=.*$', multiLine: true), iconLine)
          : '$desktopContent\n$iconLine\n';
      final currentIconContent = await iconFile.exists()
          ? await iconFile.readAsString()
          : null;
      final iconNeedsUpdate = currentIconContent != svgContent;
      final desktopNeedsUpdate = updatedContent != desktopContent;

      if (!iconNeedsUpdate && !desktopNeedsUpdate) {
        return const AppIconSyncResult(AppIconSyncStatus.alreadySynced);
      }

      await iconFile.parent.create(recursive: true);
      if (iconNeedsUpdate) {
        await iconFile.writeAsString(svgContent);
      }

      if (desktopNeedsUpdate) {
        await desktopFile.writeAsString(updatedContent);
      }

      await _runIfAvailable('gtk-update-icon-cache', ['-f', '$home/.local/share/icons/hicolor']);
      await _runIfAvailable('update-desktop-database', ['$home/.local/share/applications']);
      return const AppIconSyncResult(AppIconSyncStatus.synced);
    } catch (_) {
      return const AppIconSyncResult(AppIconSyncStatus.failed);
    }
  }

  static Future<void> _runIfAvailable(String command, List<String> args) async {
    try {
      await Process.run(command, args);
    } catch (_) {
      return;
    }
  }

  static Future<AppIconSyncResult> _syncMobileIcon(AppIcon appIcon) async {
    try {
      final status = await _channel.invokeMethod<String>(
        'applyIcon',
        {'iconKey': appIcon.key},
      );

      switch (status) {
        case 'synced':
          return const AppIconSyncResult(AppIconSyncStatus.synced);
        case 'alreadySynced':
          return const AppIconSyncResult(AppIconSyncStatus.alreadySynced);
        case 'invalidIcon':
          return const AppIconSyncResult(AppIconSyncStatus.invalidIcon);
        case 'unsupportedPlatform':
          return const AppIconSyncResult(AppIconSyncStatus.unsupportedPlatform);
        default:
          return const AppIconSyncResult(AppIconSyncStatus.failed);
      }
    } on MissingPluginException {
      return const AppIconSyncResult(AppIconSyncStatus.unsupportedPlatform);
    } on PlatformException {
      return const AppIconSyncResult(AppIconSyncStatus.failed);
    } catch (_) {
      return const AppIconSyncResult(AppIconSyncStatus.failed);
    }
  }
}