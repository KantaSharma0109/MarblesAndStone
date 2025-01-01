import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/config.dart';
import '../utils/utility.dart';
import 'image_placeholder_new.dart';

class TextToHtml extends StatelessWidget {
  final String description;
  final Color textColor;
  final double fontSize;
  const TextToHtml({
    Key? key,
    required this.description,
    required this.textColor,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Html(
    //   data: description.toString(),
    //   style: {
    //     'p': Style(
    //       fontSize: FontSize(fontSize),
    //       fontFamily: 'EuclidCircularA Regular',
    //       padding: const EdgeInsets.all(0.0),
    //       margin: const EdgeInsets.only(top: 0.0, bottom: 10.0),
    //       color: textColor,
    //     ),
    //     'body': Style(
    //       padding: const EdgeInsets.all(0.0),
    //       margin: const EdgeInsets.all(0.0),
    //     )
    //   },
    //   customImageRenders: {
    //     networkSourceMatcher(domains: ["flutter.dev"]):
    //         (context, attributes, element) {
    //       return const FlutterLogo(size: 36);
    //     },
    //     networkSourceMatcher(domains: ["mydomain.com"]): networkImageRender(
    //       headers: {"Custom-Header": "some-value"},
    //       altWidget: (alt) => Text(alt ?? ""),
    //       loadingWidget: () => Text("Loading..."),
    //     ),
    //     // On relative paths starting with /wiki, prefix with a base url
    //     (attr, _) => attr["src"] != null && attr["src"]!.startsWith("/wiki"):
    //         networkImageRender(
    //             mapUrl: (url) => "https://upload.wikimedia.org" + url!),
    //     // Custom placeholder image for broken links
    //     networkSourceMatcher():
    //         networkImageRender(altWidget: (_) => const FlutterLogo()),
    //   },
    //   onLinkTap: (url, _, __, ___) {
    //     print("Opening $url...");
    //     launchUrl(Uri.parse(url ?? ""));
    //   },
    //   onImageTap: (src, _, __, ___) {
    //     print(src);
    //     launchUrl(Uri.parse(src ?? ""));
    //   },
    //   onImageError: (exception, stackTrace) {
    //     print(exception);
    //   },
    //   onCssParseError: (css, messages) {
    //     print("css that errored: $css");
    //     print("error messages:");
    //     messages.forEach((element) {
    //       print(element);
    //     });
    //   },
    // );
    return HtmlWidget(
      //to show HTML as widget.
      description.toString(),
      textStyle: TextStyle(
        fontSize: fontSize,
        fontFamily: 'EuclidCircularA Regular',
        color: textColor,
        fontStyle: FontStyle.normal,
      ),
      customWidgetBuilder: (element) {
        if (element.attributes['src'] != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: ImagePlaceholder(
              url: Constants.finalUrl +
                  (element.attributes['src'] ?? '/images/local/logo.png'),
              height: 200.0,
              width: double.infinity,
              openImage: true,
            ),
          );
        }

        return null;
      },
      onErrorBuilder: (context, element, error) =>
          Text('$element error: $error'),
      onLoadingBuilder: (context, element, loadingProgress) =>
          const CircularProgressIndicator(),
      onTapUrl: (url) {
        Utility.printLog("Opening $url...");
        launchUrl(Uri.parse(url ?? ""));
        return true;
      },
    );
  }
}
