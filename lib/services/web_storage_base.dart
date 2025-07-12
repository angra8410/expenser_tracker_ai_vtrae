// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show window;

class WebStorageBase {
  static void setItem(String key, String value) {
    window.localStorage[key] = value;
  }

  static String? getItem(String key) {
    return window.localStorage[key];
  }
}