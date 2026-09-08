import 'package:flutter/material.dart';

import '../models/invitation_kind.dart';
import 'invitation_layout.dart';

class InvitationCard extends StatelessWidget {
  const InvitationCard({
    super.key,
    required this.kind,
    required this.prefix,
    required this.name,
    required this.seatCount,
    required this.reservationNumber,
  });

  final InvitationKind kind;
  final String prefix;
  final String name;
  final int seatCount;
  final String reservationNumber;

  static const double width = InvitationLayout.canvasWidth;
  static const double height = InvitationLayout.canvasHeight;

  @override
  Widget build(BuildContext context) {
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
              Image(
                image: AssetImage(InvitationLayout.assetFor(kind)),
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
              ),
              Positioned(
                left: InvitationLayout.guestTextLeft,
                top: InvitationLayout.guestTextTop,
                width: InvitationLayout.guestTextWidth,
                height: InvitationLayout.guestTextHeight,
                child: _OverlayText(
                  text: InvitationLayout.guestLine(prefix, name),
                  fontSize: InvitationLayout.guestFontSize,
                  minFontSize: InvitationLayout.guestMinFontSize,
                ),
              ),
              Positioned(
                left: InvitationLayout.seatValueLeft,
                top: InvitationLayout.seatValueTop,
                width: InvitationLayout.seatValueWidth,
                height: InvitationLayout.seatValueHeight,
                child: _OverlayText(
                  text: InvitationLayout.seatLine(seatCount),
                  fontSize: InvitationLayout.seatFontSize,
                  minFontSize: InvitationLayout.seatMinFontSize,
                ),
              ),
              Positioned(
                left: InvitationLayout.reservationLeft,
                top: InvitationLayout.reservationTop,
                width: InvitationLayout.reservationWidth,
                height: InvitationLayout.reservationHeight,
                child: _OverlayText(
                  text: InvitationLayout.reservationLine(reservationNumber),
                  fontSize: InvitationLayout.reservationFontSize,
                  minFontSize: InvitationLayout.reservationMinFontSize,
                  fill: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayText extends StatelessWidget {
  const _OverlayText({
    required this.text,
    required this.fontSize,
    required this.minFontSize,
    this.fill = true,
  });

  final String text;
  final double fontSize;
  final double minFontSize;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final child = LayoutBuilder(
      builder: (context, constraints) {
        var size = fontSize;
        while (size > minFontSize) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: _style(size)),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            maxLines: 1,
            ellipsis: '…',
          )..layout(maxWidth: constraints.maxWidth);

          if (!painter.didExceedMaxLines &&
              painter.height <= constraints.maxHeight) {
            break;
          }
          size -= 1;
        }

        return Center(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: _style(size),
          ),
        );
      },
    );

    if (!fill) {
      return child;
    }

    return ColoredBox(color: InvitationLayout.overlayFill, child: child);
  }

  static TextStyle _style(double fontSize) {
    return TextStyle(
      fontFamily: InvitationLayout.fontFamily,
      fontWeight: InvitationLayout.fontWeight,
      fontSize: fontSize,
      height: 1.1,
      color: InvitationLayout.textColor,
    );
  }
}
