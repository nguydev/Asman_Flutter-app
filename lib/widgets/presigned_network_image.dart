import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_task/core/services/file_service.dart';
import 'package:flutter_task/widgets/custom_network_image.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class PresignedNetworkImage extends StatefulWidget {
  final String? imageUrl;
  final File? imageFile;
  final Widget? fallbackAsset;
  final double? height;
  final double? width;
  final Border? border;
  final double? borderRadius;
  final BoxShape boxShape;
  final Color? backgroundColor;
  final Widget? child;
  final ColorFilter? colorFilter;
  final List<BoxShadow>? boxShadow;
  final bool elevation;
  final BoxFit? fit;

  const PresignedNetworkImage({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.fallbackAsset,
    this.height,
    this.width,
    this.border,
    this.borderRadius,
    this.boxShape = BoxShape.rectangle,
    this.backgroundColor,
    this.child,
    this.colorFilter,
    this.boxShadow,
    this.elevation = false,
    this.fit,
  });

  @override
  State<PresignedNetworkImage> createState() => _PresignedNetworkImageState();
}

class _PresignedNetworkImageState extends State<PresignedNetworkImage> {
  late final FileService _fileService;
  
  String? _resolvedUrl;
  bool _isLoading = false;
  String? _lastLoadedId;

  @override
  void initState() {
    super.initState();
    try {
      _fileService = Get.find<FileService>();
    } catch (_) {
      _fileService = Get.put(FileService());
    }
    _resolveUrl();
  }

  @override
  void didUpdateWidget(covariant PresignedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _resolveUrl();
    }
  }

  Future<void> _resolveUrl() async {
    final url = widget.imageUrl;

    // Reset resolved URL if empty/null
    if (url == null || url.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _resolvedUrl = null;
          _isLoading = false;
          _lastLoadedId = null;
        });
      }
      return;
    }

    // If it's a direct web URL, use it directly
    if (url.startsWith('http://') || url.startsWith('https://')) {
      if (mounted) {
        setState(() {
          _resolvedUrl = url;
          _isLoading = false;
          _lastLoadedId = url;
        });
      }
      return;
    }

    // If we've already resolved this file ID, skip fetching again
    if (_lastLoadedId == url) {
      return;
    }

    // It's a file ID/UUID, resolve it using FileService
    if (mounted) {
      setState(() {
        _isLoading = true;
        _lastLoadedId = url;
      });
    }

    try {
      final downloadUrl = await _fileService.getDownloadUrl(url);
      if (mounted) {
        setState(() {
          _resolvedUrl = downloadUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to resolve presigned download URL for $url: $e');
      if (mounted) {
        setState(() {
          _resolvedUrl = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageFile != null) {
      return CustomNetworkImage(
        imageFile: widget.imageFile,
        height: widget.height,
        width: widget.width,
        border: widget.border,
        borderRadius: widget.borderRadius,
        boxShape: widget.boxShape,
        backgroundColor: widget.backgroundColor,
        colorFilter: widget.colorFilter,
        boxShadow: widget.boxShadow,
        elevation: widget.elevation,
        fit: widget.fit,
        child: widget.child,
      );
    }

    if (_isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.grey.shade300,
            shape: widget.boxShape,
            borderRadius: widget.boxShape == BoxShape.circle
                ? null
                : (widget.borderRadius != null ? BorderRadius.circular(widget.borderRadius!) : null),
          ),
        ),
      );
    }

    return CustomNetworkImage(
      imageUrl: _resolvedUrl,
      fallbackAsset: widget.fallbackAsset,
      height: widget.height,
      width: widget.width,
      border: widget.border,
      borderRadius: widget.borderRadius,
      boxShape: widget.boxShape,
      backgroundColor: widget.backgroundColor,
      colorFilter: widget.colorFilter,
      boxShadow: widget.boxShadow,
      elevation: widget.elevation,
      fit: widget.fit,
      child: widget.child,
    );
  }
}
