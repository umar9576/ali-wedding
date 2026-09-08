import 'package:flutter/material.dart';

import 'invitation_layout.dart';

class InvitationCard extends StatelessWidget {
  const InvitationCard({super.key, required this.prefix, required this.name});

  final String prefix;
  final String name;

  static const double width = InvitationLayout.canvasWidth;
  static const double height = InvitationLayout.canvasHeight;

  @override
  Widget build(BuildContext context) {
    final line = InvitationLayout.guestLine(prefix, name);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Image(
                image: AssetImage(InvitationLayout.imageAsset),
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
              ),
              Positioned(
                left:
                    InvitationLayout.guestBoxLeft +
                    InvitationLayout.contentPaddingHorizontal,
                top:
                    InvitationLayout.guestBoxTop +
                    InvitationLayout.contentPaddingVertical,
                width:
                    InvitationLayout.guestBoxWidth -
                    (InvitationLayout.contentPaddingHorizontal * 2),
                height:
                    InvitationLayout.guestBoxHeight -
                    (InvitationLayout.contentPaddingVertical * 2),
                child: _GuestName(text: line),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestName extends StatelessWidget {
  const _GuestName({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var fontSize = InvitationLayout.fontSize;
        final minSize = InvitationLayout.minFontSize;

        while (fontSize > minSize) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: _style(fontSize)),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            maxLines: 2,
            ellipsis: '…',
          )..layout(maxWidth: constraints.maxWidth);

          if (!painter.didExceedMaxLines &&
              painter.height <= constraints.maxHeight) {
            break;
          }
          fontSize -= 1;
        }

        return Center(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: _style(fontSize),
          ),
        );
      },
    );
  }

  static TextStyle _style(double fontSize) {
    return TextStyle(
      fontFamily: InvitationLayout.fontFamily,
      fontWeight: InvitationLayout.fontWeight,
      fontSize: fontSize,
      height: 1.15,
      color: InvitationLayout.textColor,
    );
  }
}
