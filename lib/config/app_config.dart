import 'dart:ui';
import 'package:matrix/matrix.dart';

abstract class AppConfig {
  static const Color primaryColor = Color(0xFF5625BA);
  static const Color primaryColorLight = Color(0xFFCCBDEA);
  static const Color secondaryColor = Color(0xFF41a2bc);
  static const Color chatColor = primaryColor;
  static Color? colorSchemeSeed = primaryColor;

  static String _applicationName = 'ZazzyChat';
  static String? _applicationWelcomeMessage;
  static String _defaultHomeserver = 'https://zazzy.chat:12345';
  static String _privacyUrl = 'https://zazzy.chat/privacy';
  static String _webBaseUrl = ''; // TODO: подключить веб-клиент или удалить

  static double fontSizeFactor = 1;
  static const double messageFontSize = 16.0;
  static const bool allowOtherHomeservers = true;
  static const bool enableRegistration = true;

  static const Set<String> defaultReactions = {'👍', '❤️', '😂', '😮', '😢'};

  static String get applicationName => _applicationName;
  static String? get applicationWelcomeMessage => _applicationWelcomeMessage;
  static String get defaultHomeserver => _defaultHomeserver;
  static String get privacyUrl => _privacyUrl;
  static String get webBaseUrl => _webBaseUrl;

  static const String website = 'https://zazzy.chat';

  static const String enablePushTutorial =
      'https://github.com/ZazzyChat/wiki/Push-Notifications-without-Google-Services';
  static const String encryptionTutorial =
      'https://github.com/ZazzyChat/wiki/How-to-use-end-to-end-encryption-in-ZazzyChat';
  static const String startChatTutorial =
      'https://github.com/ZazzyChat/wiki/How-to-Find-Users-in-ZazzyChat';

  static const String appId = 'chat.zazzychat.client';
  static const String appOpenUrlScheme = 'chat.zazzychat';

  static const String sourceCodeUrl = 'https://github.com/ZazzyChat';
  static const String supportUrl = 'https://github.com/ZazzyChat/client/issues';
  static const String changelogUrl = 'https://github.com/ZazzyChat/client/blob/main/CHANGELOG.md';

  static final Uri newIssueUrl = Uri(
    scheme: 'https',
    host: 'github.com',
    path: '/ZazzyChat/client/issues/new',
  );

  static bool renderHtml = true;
  static bool hideRedactedEvents = false;
  static bool hideUnknownEvents = true;
  static bool separateChatTypes = false;
  static bool autoplayImages = true;
  static bool sendTypingNotifications = true;
  static bool sendPublicReadReceipts = true;
  static bool swipeRightToLeftToReply = true;
  static bool? sendOnEnter;
  static bool showPresences = true;
  static bool displayNavigationRail = false;
  static bool experimentalVoip = false;

  static const bool hideTypingUsernames = false;

  static const String inviteLinkPrefix = 'https://matrix.to/#/';
  static const String deepLinkPrefix = 'chat.zazzychat://chat/';
  static const String schemePrefix = 'matrix:';
  static const String pushNotificationsChannelId = 'zazzychat_push';
  static const String pushNotificationsAppId = 'chat.zazzy.chat';

  static const double borderRadius = 18.0;
  static const double columnWidth = 360.0;

  static final Uri homeserverList = Uri(
    scheme: 'https',
    host: 'servers.joinmatrix.org',
    path: 'servers.json',
  );

  static void loadFromJson(Map<String, dynamic> json) {
    if (json['chat_color'] != null) {
      try {
        colorSchemeSeed = Color(json['chat_color']);
      } catch (e) {
        Logs().w(
          'Invalid color in config.json! Please make sure to define the color in this format: "0xffdd0000"',
          e,
        );
      }
    }
    if (json['application_name'] is String) {
      _applicationName = json['application_name'];
    }
    if (json['application_welcome_message'] is String) {
      _applicationWelcomeMessage = json['application_welcome_message'];
    }
    if (json['default_homeserver'] is String) {
      _defaultHomeserver = json['default_homeserver'];
    }
    if (json['privacy_url'] is String) {
      _privacyUrl = json['privacy_url'];
    }
    if (json['web_base_url'] is String) {
      _webBaseUrl = json['web_base_url'];
    }
    if (json['render_html'] is bool) {
      renderHtml = json['render_html'];
    }
    if (json['hide_redacted_events'] is bool) {
      hideRedactedEvents = json['hide_redacted_events'];
    }
    if (json['hide_unknown_events'] is bool) {
      hideUnknownEvents = json['hide_unknown_events'];
    }
  }
}
