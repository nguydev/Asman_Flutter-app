import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/core/helpers/floatingErrorBar.dart';
import 'package:flutter_task/core/helpers/floatingSuccessbar.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:flutter_task/features/profile/presentation/document_preview_screen.dart';
import 'package:flutter_task/features/profile/presentation/controllers/vault_controller.dart';
import 'package:flutter_task/features/profile/data/models/vault_document_model.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late final VaultController _vaultController;
  final _titleController = TextEditingController();
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    try {
      _vaultController = Get.find<VaultController>();
    } catch (_) {
      _vaultController = Get.put(VaultController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          // Set initial title from file name without extension
          final fileName = result.files.single.name;
          final dotIndex = fileName.lastIndexOf('.');
          _titleController.text = dotIndex != -1 ? fileName.substring(0, dotIndex) : fileName;
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> _uploadDocument() async {
    if (_selectedFile == null) return;
    final name = _titleController.text.trim();
    if (name.isEmpty) {
      FloatingErrorBar.show(context, message: 'Please enter a document name');
      return;
    }

    final success = await _vaultController.uploadDocument(_selectedFile!, name);
    if (success) {
      setState(() {
        _selectedFile = null;
        _titleController.clear();
      });
      if (mounted) {
        FloatingSuccessBar.show(context, message: 'Document uploaded successfully');
      }
    } else {
      if (mounted) {
        FloatingErrorBar.show(context, message: _vaultController.errorMessage.value);
      }
    }
  }

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(isoString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    } catch (_) {
      return isoString;
    }
  }

  String _getFileLetter(String title) {
    if (title.isEmpty) return 'D';
    final dotIndex = title.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < title.length - 1) {
      return title.substring(dotIndex + 1).toUpperCase().substring(0, 1);
    }
    return title.toUpperCase().substring(0, 1);
  }

  Future<void> _confirmDelete(BuildContext context, VaultDocument doc) async {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete ${doc.name} from your vault?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await _vaultController.deleteDocument(doc.id);
              if (success) {
                if (context.mounted) {
                  FloatingSuccessBar.show(context, message: 'Document deleted successfully');
                }
              } else {
                if (context.mounted) {
                  FloatingErrorBar.show(context, message: _vaultController.errorMessage.value);
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: CustomText(
          text: 'Documents',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20.r),
          onPressed: () => Get.back(),
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Color(0xFFDFE3E7),
            width: 1,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32.r),
            bottomRight: Radius.circular(32.r),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _vaultController.fetchDocuments(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            children: [
              // Upload Section Card
              Obx(() {
                final loading = _vaultController.isLoading.value;
                return IgnorePointer(
                  ignoring: loading,
                  child: CustomContainer(
                    color: AppColors.white,
                    radiusAll: 12.r,
                    paddingAll: 16.r,
                    marginBottom: 24.h,
                    border: Border.all(color: const Color(0xFFDFE3E7), width: 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Upload New Document',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: _pickDocument,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: const Color(0xFFDFE3E7),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 36.r,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: 8.h),
                                CustomText(
                                  text: _selectedFile == null
                                      ? 'Select Document File'
                                      : _selectedFile!.path.split(Platform.pathSeparator).last,
                                  fontSize: 13.sp,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_selectedFile != null) ...[
                          SizedBox(height: 12.h),
                          CustomTextField(
                            controller: _titleController,
                            labelText: 'Document Name',
                            hintText: 'Enter document name',
                            filColor: const Color(0xFFF8F9FA),
                            borderRadio: 8.r,
                          ),
                          SizedBox(height: 16.h),
                          CustomButton(
                            onPressed: _uploadDocument,
                            label: 'Upload Document',
                            backgroundColor: const Color(0xFF0f172a),
                            foregroundColor: AppColors.white,
                            radius: 8.r,
                            height: 44.h,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            child: loading
                                ? const CupertinoActivityIndicator(color: Colors.white)
                                : null,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),

              // List of added documents
              Obx(() {
                if (_vaultController.isFetching.value && _vaultController.documents.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CupertinoActivityIndicator(),
                    ),
                  );
                }

                if (_vaultController.documents.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open_outlined,
                            size: 64.r,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          SizedBox(height: 16.h),
                          CustomText(
                            text: 'No documents added yet.',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 8.h),
                          CustomText(
                            text: 'Use the section above to upload your first document.',
                            fontSize: 13.sp,
                            color: AppColors.textSecondary.withValues(alpha: 0.8),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _vaultController.documents.length,
                  itemBuilder: (context, index) {
                    final doc = _vaultController.documents[index];
                    return _buildDocumentCard(doc);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(VaultDocument doc) {
    final letter = _getFileLetter(doc.name);
    return CustomContainer(
      color: AppColors.white,
      radiusAll: 12.r,
      paddingAll: 16.r,
      marginBottom: 16.h,
      border: Border.all(color: const Color(0xFFDFE3E7), width: 1),
      child: Stack(
        children: [
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomContainer(
                    color: const Color(0xFF0f172a),
                    radiusAll: 6.r,
                    height: 28.r,
                    width: 28.r,
                    alignment: Alignment.center,
                    child: CustomText(
                      text: letter,
                      color: const Color(0xFF3b82f6),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: doc.name,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4B5563),
                        ),
                        SizedBox(height: 4.h),
                        CustomText(
                          text: _formatDate(doc.createdAt),
                          fontSize: 13.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 36.w), // Space for delete icon
                ],
              ),
              SizedBox(height: 16.h),
              CustomButton(
                onPressed: () {
                  if (doc.fileObjectId.isEmpty) {
                    FloatingErrorBar.show(
                      context,
                      message: 'This document has no file attached.',
                    );
                    return;
                  }
                  Get.to(
                    () => DocumentPreviewScreen(
                      documentTitle: doc.name,
                      fileObjectId: doc.fileObjectId,
                      fileHint: doc.previewHint,
                    ),
                  );
                },
                label: 'Preview',
                backgroundColor: const Color(0xFF0f172a),
                foregroundColor: AppColors.white,
                radius: 8.r,
                height: 44.h,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _confirmDelete(context, doc),
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFDFE3E7), width: 0.5),
                ),
                child: SvgPicture.asset(
                  'assets/icons/deleteIcon.svg',
                  width: 20.r,
                  height: 20.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
