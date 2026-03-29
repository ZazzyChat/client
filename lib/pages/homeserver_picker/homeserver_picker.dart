import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:matrix/matrix.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'package:zazzychat/config/app_config.dart';
import 'package:zazzychat/l10n/l10n.dart';
import 'package:zazzychat/utils/platform_infos.dart';
import 'package:zazzychat/utils/tor_stub.dart'
    if (dart.library.html) 'package:tor_detector_web/tor_detector_web.dart';
import 'package:zazzychat/widgets/adaptive_dialogs/show_ok_cancel_alert_dialog.dart';
import 'package:zazzychat/widgets/matrix.dart';
import '../../utils/localized_exception_extension.dart';

class HomeserverPicker extends StatefulWidget {
  final bool addMultiAccount;
  const HomeserverPicker({required this.addMultiAccount, super.key});

  @override
  HomeserverPickerController createState() => HomeserverPickerController();
}

class HomeserverPickerController extends State<HomeserverPicker> {
  bool isLoading = false;
  String? error;
  bool isTorBrowser = false;
  List<LoginFlow>? loginFlows;

  @override
  void initState() {
    super.initState();
    _checkTorBrowser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoLoginToZazzy();
    });
  }

  Future<void> _checkTorBrowser() async {
    if (!kIsWeb) return;

    Hive.openBox('test').then((_) => null).catchError((e, s) async {
      await showOkAlertDialog(
        context: context,
        title: L10n.of(context).indexedDbErrorTitle,
        message: L10n.of(context).indexedDbErrorLong,
      );
      _checkTorBrowser();
    });

    final isTor = await TorBrowserDetector.isTorBrowser;
    isTorBrowser = isTor;
  }

  Future<void> _autoLoginToZazzy() async {
    setState(() {
      error = null;
      isLoading = true;
    });

    final l10n = L10n.of(context);
    final homeserver = Uri.https('zazzy.chat', '');

    try {
      final client = await Matrix.of(context).getLoginClient();
      final (_, _, flows) = await client.checkHomeserver(homeserver);
      loginFlows = flows;
      client.homeserver = homeserver;

      if (_supportsFlow('m.login.sso')) {
        if (!PlatformInfos.isMobile) {
          final consent = await showOkCancelAlertDialog(
            context: context,
            title: l10n.appWantsToUseForLogin('zazzy.chat'),
            message: l10n.appWantsToUseForLoginDescription,
            okLabel: l10n.continueText,
          );
          if (consent != OkCancelResult.ok) return;
        }
        return _ssoLogin(client);
      }

      context.go('/home/login', extra: client);
    } catch (e) {
      setState(() {
        error = e.toLocalizedString(
          context,
          ExceptionContext.checkHomeserver,
        );
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  bool _supportsFlow(String flowType) =>
      loginFlows?.any((flow) => flow.type == flowType) ?? false;

  Future<void> _ssoLogin(Client client) async {
    final redirectUrl = kIsWeb
        ? Uri.parse(html.window.location.href)
            .resolveUri(Uri(pathSegments: ['auth.html']))
            .toString()
        : PlatformInfos.isMobile || PlatformInfos.isWeb || PlatformInfos.isMacOS
            ? '${AppConfig.appOpenUrlScheme.toLowerCase()}://login'
            : 'http://localhost:3001//login';

    final url = client.homeserver!.replace(
      path: '/_matrix/client/v3/login/sso/redirect',
      queryParameters: {'redirectUrl': redirectUrl},
    );

    final urlScheme = Uri.parse(redirectUrl).scheme;
    final result = await FlutterWebAuth2.authenticate(
      url: url.toString(),
      callbackUrlScheme: urlScheme,
      options: const FlutterWebAuth2Options(),
    );

    final token = Uri.parse(result).queryParameters['loginToken'];
    if (token?.isEmpty ?? true) return;

    setState(() {
      error = null;
      isLoading = true;
    });

    try {
      await client.login(
        LoginType.mLoginToken,
        token: token,
        initialDeviceDisplayName: PlatformInfos.clientName,
      );
    } catch (e) {
      setState(() {
        error = e.toLocalizedString(context);
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Connecting to server zazzy.chat...'),
                ],
                if (error != null) ...[
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isLoading ? null : _autoLoginToZazzy,
                    child: const Text('REPEAT'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
