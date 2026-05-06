import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class AppToast {
  AppToast._();

  static void show(
    BuildContext context, {
    required String message,
    required ContentType type,
    String? title,
  }) {
    final defaultTitle = switch (type) {
      ContentType.success => '¡Éxito!',
      ContentType.failure => 'Error',
      ContentType.warning => 'Advertencia',
      ContentType.help => 'Información',
      _ => 'Aviso',
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: title ?? defaultTitle,
            message: message,
            contentType: type,
          ),
        ),
      );
  }

  static void success(BuildContext context, String message, {String? title}) =>
      show(context, message: message, type: ContentType.success, title: title);

  static void error(BuildContext context, String message, {String? title}) =>
      show(context, message: message, type: ContentType.failure, title: title);

  static void warning(BuildContext context, String message, {String? title}) =>
      show(context, message: message, type: ContentType.warning, title: title);

  static void info(BuildContext context, String message, {String? title}) =>
      show(context, message: message, type: ContentType.help, title: title);
}
