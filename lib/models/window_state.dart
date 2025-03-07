import 'dart:io';
import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/config/preference.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/debouncer.dart';
import 'package:one_launcher/utils/json/converter/offset_json_converter.dart';
import 'package:one_launcher/utils/json/converter/size_json_converter.dart';
import 'package:window_manager/window_manager.dart';

part 'window_state.g.dart';

@JsonSerializable()
class WindowState {
  const WindowState(this.position, this.size);

  factory WindowState.fromJson(JsonMap json) => _$WindowStateFromJson(json);

  static const storageKey = "windowState";
  static WindowState? get() => prefs.windowState;

  static Future<bool> save(WindowState windowState) =>
      prefs.setWindowState(windowState);

  @OffsetJsonConverter()
  final Offset position;

  @SizeJsonConverter()
  final Size size;

  JsonMap toJson() => _$WindowStateToJson(this);
}

class WindowStateListener extends WindowListener {
  late final _debouncer = Debouncer(const Duration(milliseconds: 500));

  Future<bool> _updateState() async {
    final windowState = WindowState(
      await windowManager.getPosition(),
      await windowManager.getSize(),
    );
    return WindowState.save(windowState);
  }

  void _updateStateDebounced() => _debouncer.run(_updateState);

  /// Unavaliabe on Linux
  @override
  void onWindowMoved() => _updateState();

  /// Unavaliabe on Linux
  @override
  void onWindowResized() => _updateState();

  @override
  void onWindowMove() {
    if (Platform.isLinux) {
      _updateStateDebounced();
    }
  }

  @override
  void onWindowResize() {
    if (Platform.isLinux) {
      _updateStateDebounced();
    }
  }
}
