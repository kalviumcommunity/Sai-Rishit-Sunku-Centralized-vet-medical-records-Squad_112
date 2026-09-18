import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/medical_records_service.dart';
import '../../services/storage_service.dart';

/// DAY 12 — Documents Screen with Firebase Storage Integration
class DocumentsScreen extends StatefulWidget {
  final PetModel? pet;
  final String? petId;

  const DocumentsScreen({
    super.key,
    this.pet,
    this.petId,
  });

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _storageService = StorageService();
  bool _isLoading = true;
  bool _isUploading = false;
  List<MedicalDocumentModel> _documents = [];

  late PetModel _activePet;

  @override
  void initState() {
    super.initState();
    _activePet = widget.pet ?? _getDefaultPet(widget.petId);
    _loadDocuments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is PetModel) {
      _activePet = args;
      _loadDocuments();
    }
  }

  PetModel _getDefaultPet(String? id) {
    final now = DateTime.now();
    return PetModel(
      id: id ?? 'pet_milo_default',
      name: 'Milo',
      species: 'Dog',
      breed: 'Golden Retriever',
      gender: 'male',
      dateOfBirth: DateTime(now.year - 3, now.month, now.day),
      microchipId: '98514',
      ownerId: 'owner_sarah',
      weightKg: 28.0,
      createdAt: now.subtract(const Duration(days: 365 * 3)),
    );
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    try {
      final list = await _storageService.fetchPetDocuments(_activePet.id);
      if (mounted) {
        setState(() {
          _documents = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _documents = _storageService.getFallbackDocuments(_activePet.id);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleUploadDocument() async {
    try {
      final pickedFile = await _storageService.pickDocument();
      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Unable to read selected file data.');
      }

      setState(() => _isUploading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      final userModel = authService.currentUserModel;
      final branchId = userModel?.branchId?.isNotEmpty == true
          ? userModel!.branchId!
          : 'branch_koramangala';
      final uploadedBy = userModel?.id ?? authService.currentUser?.uid ?? 'user_dr_sharma';

      final newDoc = await _storageService.uploadDocument(
        petId: _activePet.id,
        fileName: pickedFile.name,
        bytes: bytes,
        branchId: branchId,
        uploadedBy: uploadedBy,
      );

      if (!mounted) return;

      setState(() {
        _documents.insert(0, newDoc);
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Uploaded "${pickedFile.name}" to Storage & Firestore!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          content: Text('Upload failed: $e'),
        ),
      );
    }
  }

  Future<void> _openDocumentUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening document: $url')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open document: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2937), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            // Bone icon header per Day 12 spec
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.pets_rounded, // Mascot / bone icon styling
                color: Color(0xFFF97316),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${_activePet.name}\'s Documents',
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDocuments,
          color: const Color(0xFFF97316),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // 1. Dashed-Border Upload Area
              _buildDashedUploadArea(),
              const SizedBox(height: 16),

              // 2. Storage Security / Accuracy Banner
              // NOTE: Firebase Storage security rules govern document access control.
              // Client-side end-to-end encryption is not implemented; copy has been softened
              // to accurately reflect enterprise cloud storage security without overstating capabilities.
              _buildSecurityBanner(),
              const SizedBox(height: 24),

              // 3. Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Uploaded Records & Scans',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    '${_documents.length} files',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Document List
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(color: Color(0xFFF97316)),
                  ),
                )
              else if (_documents.isEmpty)
                _buildEmptyState()
              else
                ..._documents.map(_buildDocumentCard),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Dashed-Border Upload Area with 15MB file note
  Widget _buildDashedUploadArea() {
    return InkWell(
      onTap: _isUploading ? null : _handleUploadDocument,
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        painter: DashedRectPainter(
          color: const Color(0xFFF97316),
          strokeWidth: 1.5,
          gap: 5.0,
          borderRadius: 16,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              if (_isUploading)
                const Column(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Uploading to Firebase Storage...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC2410C),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        color: Color(0xFFF97316),
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Upload Prescription / X-ray',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PDF, JPG or PNG (up to 15MB)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Select Document',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 2. Softened Security Banner
  Widget _buildSecurityBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: Color(0xFF16A34A), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Securely Stored & Synced across VetCare Clinics',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Document Item Card
  Widget _buildDocumentCard(MedicalDocumentModel doc) {
    final branchName = MedicalRecordsService.branchNameMap[doc.branchId] ?? 'VetCare Clinic';
    final dateStr = '${doc.createdAt.day.toString().padLeft(2, '0')}/${doc.createdAt.month.toString().padLeft(2, '0')}/${doc.createdAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Document type icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: doc.isPdf
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              doc.isPdf
                  ? Icons.picture_as_pdf_rounded
                  : Icons.image_rounded,
              color: doc.isPdf ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.fileName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$branchName \u2022 $dateStr',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons: View / Download Icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 20, color: Color(0xFF4B5563)),
                tooltip: 'View Document',
                onPressed: () => _openDocumentUrl(doc.fileUrl),
              ),
              IconButton(
                icon: const Icon(Icons.download_rounded, size: 20, color: Color(0xFFF97316)),
                tooltip: 'Download File',
                onPressed: () => _openDocumentUrl(doc.fileUrl),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.folder_open_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No documents uploaded yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Upload lab tests, diagnostic scans, or prescription PDFs above.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for dashed rounded border
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double borderRadius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.borderRadius = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = _dashPath(path, 8.0, gap);

    canvas.drawPath(dashedPath, paint);
  }

  Path _dashPath(Path source, double dashLength, double dashGap) {
    final Path dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = draw ? dashLength : dashGap;
        if (distance + len > metric.length) {
          if (draw) {
            dest.addPath(
              metric.extractPath(distance, metric.length),
              Offset.zero,
            );
          }
          break;
        }
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(DashedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.borderRadius != borderRadius;
  }
}
