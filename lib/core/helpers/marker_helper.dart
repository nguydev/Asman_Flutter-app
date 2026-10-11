import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerHelper {
  static Future<BitmapDescriptor> createCustomMarkerBitmap(
      IconData iconData, {
        Color iconColor = Colors.white,
        Color circleColor = const Color(0xFF3B82F6), // Blue like the screenshot
        Color borderColor = Colors.white,
        double size = 100.0,
      }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = circleColor;
    final double radius = size / 2;

    // Draw the circle background
    canvas.drawCircle(Offset(radius, radius), radius, paint);

    // Draw the border
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = size * 0.08
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(radius, radius), radius - borderPaint.strokeWidth / 2, borderPaint);

    // Draw the icon
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size * 0.6,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: iconColor,
      ),
    );
    textPainter.layout();
    
    // Center the icon inside the circle
    textPainter.paint(
      canvas,
      Offset(
        radius - textPainter.width / 2,
        radius - textPainter.height / 2,
      ),
    );

    // Draw the small triangle at the bottom (pin shape)
    final path = Path();
    path.moveTo(radius - size * 0.15, size - borderPaint.strokeWidth);
    path.lineTo(radius + size * 0.15, size - borderPaint.strokeWidth);
    path.lineTo(radius, size + size * 0.2);
    path.close();
    canvas.drawPath(path, paint);

    // Convert to Image
    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      (size + size * 0.2).toInt(),
    );
    
    // Convert to ByteData
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    
    // Return BitmapDescriptor
    return BitmapDescriptor.bytes(data!.buffer.asUint8List());
  }
}
