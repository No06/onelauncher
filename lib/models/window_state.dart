import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/main.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/debouncer.dart';
import 'package:one_launcher/utils/json_converter/offset_json_converter.dart';
import 'package:one_launcher/utils/json_converter/size_json_converter.dart';
import 'package:window_manager/window_manager.dart';

part 'window_state.g.dart';

@JsonSerializable()
class WindowState {
  const WindowState(this.position, this.size);

  factory WindowState.fromJson(JsonMap json) => _$WindowStateFromJson(json);

  static const storageKey = "windowState";
  static Future<WindowState?> get() async {
    final jsonString = storage.read<String>(storageKey);
    if (jsonString == null) return null;
    final jsonData = jsonDecode(jsonString) as JsonMap;
    final windowState = WindowState.fromJson(jsonData);
    return windowState;
  }

  static Future<void> save(WindowState windowState) =>
      storage.write(storageKey, jsonEncode(windowState.toJson()));

  @OffsetJsonConverter()
  final Offset position;

  @SizeJsonConverter()
  final Size size;

  JsonMap toJson() => _$WindowStateToJson(this);
}

class WindowStateListener extends WindowListener {
  late final _debouncer = Debouncer(const Duration(milliseconds: 500));

  Future<void> _updateState() async {
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
