import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

Future main() async {
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelKey: "basic_channel",
            channelName: "Basic Notification",
            channelDescription: "Description")
      ],
      debug: true);


  WidgetsFlutterBinding.ensureInitialized();
  await Permission.storage.request();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Builder(builder: (context) {
          return SafeArea(
            child: InAppWebView(
              initialUrlRequest:
              URLRequest(url: Uri.parse("website_link")),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    useShouldOverrideUrlLoading: true,
                    useOnLoadResource: true,
                    supportZoom: false,

                    useOnDownloadStart: true),
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                _webViewController = controller;
              },
              onDownloadStart: (controller, url) async {
                print("onDownloadStart $url");
                final taskId = await FileDownloader.downloadFile(
                  url: url.toString(),
                  onDownloadCompleted: (String path) {
                    triggerNotification();
                    print('FILE DOWNLOADED TO PATH: $path');
                    showDownloadCompleteSnackbar(context, path);
                  },
                  onDownloadError: (String error) {
                    print('DOWNLOAD ERROR: $error');
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }

  void showDownloadCompleteSnackbar(BuildContext context, String filePath) {
    print('showDownloadCompleteSnackbar called'); // Add this line
    final snackBar = SnackBar(
      content: Text('File downloaded : $filePath'),
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void triggerNotification() {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 1101,
            channelKey: "basic_channel",
            title: 'File Downloaded',
            body: 'Click to open'));
  }
}