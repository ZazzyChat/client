// settings_homeserver_view.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import 'package:zazzychat/config/themes.dart';
import 'package:zazzychat/l10n/l10n.dart';
import 'package:zazzychat/utils/localized_exception_extension.dart';
import 'package:zazzychat/widgets/layouts/max_width_body.dart';
import '../../widgets/matrix.dart';
import 'settings_homeserver.dart';

class SettingsHomeserverView extends StatelessWidget {
  final SettingsHomeserverController controller;

  const SettingsHomeserverView(this.controller, {super.key});

  Future<String> _fetchAboutText(Client client) async {
    final host = client.userID?.domain ?? client.homeserver?.host;
    if (host == null || host.isEmpty) {
      throw Exception('Homeserver host is not set');
    }
    final uri = Uri.https(host, '/about.txt');

    final http = HttpClient()..userAgent = 'zazzychat';
    try {
      final req = await http.getUrl(uri);
      req.headers.set(HttpHeaders.acceptHeader, 'text/plain');
      req.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
      final res = await req.close();
      if (res.statusCode != 200) {
        throw HttpException('HTTP ${res.statusCode}', uri: uri);
      }
      return await res.transform(utf8.decoder).join();
    } finally {
      http.close(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !ZazzyThemes.isColumnMode(context),
        centerTitle: ZazzyThemes.isColumnMode(context),
        title: Text(
          L10n.of(context)
              .aboutHomeserver(client.userID?.domain ?? 'Homeserver'),
        ),
      ),
      body: MaxWidthBody(
        withScrolling: true,
        child: FutureBuilder<String>(
          future: _fetchAboutText(client),
          builder: (context, snapshot) {
            final error = snapshot.error;
            if (error != null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  error.toLocalizedString(context),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            }
            final text = snapshot.data;
            if (text == null) {
              return const Center(
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                text,                        // Печатаем как есть
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.left,
              ),
            );
          },
        ),
      ),
    );
  }
}
