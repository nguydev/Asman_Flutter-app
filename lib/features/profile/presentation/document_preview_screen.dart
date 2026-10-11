import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/helpers/floatingErrorBar.dart';
import 'package:flutter_task/core/services/file_service.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';

enum _PreviewKind { image, pdf, unsupported }

class DocumentPreviewScreen extends StatefulWidget {
  final String documentTitle;
  final String fileObjectId;
  /// Optional extension/MIME hint (e.g. original filename) when title has none.
  final String? fileHint;

  const DocumentPreviewScreen({
    super.key,
    required this.documentTitle,
    required this.fileObjectId,
    this.fileHint,
  });

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  final FileService _fileService = Get.find<FileService>();

  bool _loading = true;
  String? _error;
  String? _downloadUrl;

  @override
  void initState() {
    super.initState();
    _load();
  }

  _PreviewKind get _kind {
    final hint =
        '${widget.fileHint ?? ''} ${widget.documentTitle} ${_downloadUrl ?? ''}'
            .toLowerCase();
    if (hint.contains('application/pdf') || hint.contains('.pdf')) {
      return _PreviewKind.pdf;
    }
    if (hint.contains('image/') ||
        RegExp(r'\.(jpe?g|png|gif|webp)(\?|$|\s)').hasMatch(hint)) {
      return _PreviewKind.image;
    }
    return _PreviewKind.unsupported;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (widget.fileObjectId.trim().isEmpty) {
        throw Exception('Missing file reference for this document.');
      }
      final url = await _fileService.getDownloadUrl(widget.fileObjectId);
      if (!mounted) return;
      if (url == null || url.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'Could not load a preview URL for this document.';
        });
        return;
      }
      setState(() {
        _downloadUrl = url;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _openExternally() async {
    final url = _downloadUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      FloatingErrorBar.show(
        context,
        message: 'Could not open this document externally.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: CustomText(
          text: widget.documentTitle,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20.r,
          ),
          onPressed: () => Get.back(),
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFDFE3E7), width: 1),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32.r),
            bottomRight: Radius.circular(32.r),
          ),
        ),
        actions: [
          if (_downloadUrl != null)
            IconButton(
              tooltip: 'Open externally',
              icon: Icon(
                Icons.open_in_new_rounded,
                color: AppColors.textPrimary,
                size: 22.r,
              ),
              onPressed: _openExternally,
            ),
          SizedBox(width: 8.w),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 40.r, color: Colors.redAccent),
              SizedBox(height: 12.h),
              CustomText(
                text: _error!,
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
                textHeight: 1.4,
              ),
              SizedBox(height: 16.h),
              CustomButton(
                onPressed: _load,
                label: 'Retry',
                height: 40.h,
                fontSize: 13.sp,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                radius: 8.r,
              ),
            ],
          ),
        ),
      );
    }

    switch (_kind) {
      case _PreviewKind.image:
        return InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: _downloadUrl!,
              fit: BoxFit.contain,
              placeholder: (_, __) =>
                  const Center(child: CupertinoActivityIndicator()),
              errorWidget: (_, __, ___) => Center(
                child: CustomText(
                  text: 'Failed to load image preview.',
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      case _PreviewKind.pdf:
        return PdfViewer.uri(
          Uri.parse(_downloadUrl!),
          params: const PdfViewerParams(
            margin: 8,
          ),
        );
      case _PreviewKind.unsupported:
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomContainer(
                  height: 80.r,
                  width: 80.r,
                  radiusAll: 40.r,
                  color: const Color(0xFFF1F5F9),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.insert_drive_file_outlined,
                    size: 40.r,
                    color: const Color(0xFF9ca3af),
                  ),
                ),
                SizedBox(height: 20.h),
                CustomText(
                  text: 'Preview not available',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text:
                      'This file type can’t be previewed in the app. Open it externally instead.',
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                  textHeight: 1.4,
                ),
                SizedBox(height: 20.h),
                CustomButton(
                  onPressed: _openExternally,
                  label: 'Open Document',
                  backgroundColor: const Color(0xFF0f172a),
                  foregroundColor: AppColors.white,
                  radius: 8.r,
                  height: 44.h,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        );
    }
  }
}
