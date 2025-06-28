import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../services/merchant_service.dart';

class MerchantQRWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onMerchantScanned;
  final String? selectedMerchantId;

  const MerchantQRWidget({
    super.key,
    required this.onMerchantScanned,
    this.selectedMerchantId,
  });

  @override
  State<MerchantQRWidget> createState() => _MerchantQRWidgetState();
}

class _MerchantQRWidgetState extends State<MerchantQRWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  final MerchantService _merchantService = MerchantService();
  bool _isScanning = false;
  Map<String, dynamic>? _selectedMerchant;

  @override
  void initState() {
    super.initState();
    _loadSelectedMerchant();
  }

  void _loadSelectedMerchant() async {
    if (widget.selectedMerchantId != null) {
      try {
        // In a real implementation, we'd load the merchant by ID
        // For now, we'll use mock data
        setState(() {
          _selectedMerchant = {
            'id': widget.selectedMerchantId,
            'name': 'Selected Merchant',
            'category': 'Food & Dining',
            'location': 'Downtown',
          };
        });
      } catch (e) {
        // Handle error
      }
    }
  }

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      _handleQRCodeScanned(scanData.code);
    });
  }

  void _handleQRCodeScanned(String? qrCode) async {
    if (qrCode == null || qrCode.isEmpty) return;

    try {
      HapticFeedback.mediumImpact();

      final merchant = await _merchantService.getMerchantByQRCode(qrCode);

      if (merchant != null) {
        setState(() {
          _selectedMerchant = merchant;
          _isScanning = false;
        });

        widget.onMerchantScanned(merchant);

        // Close scanner
        qrController?.pauseCamera();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Merchant verified: ${merchant['name']}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Merchant not found. Please check the QR code.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scanning QR code: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
    qrController?.resumeCamera();
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    qrController?.pauseCamera();
  }

  void _clearMerchant() {
    setState(() {
      _selectedMerchant = null;
    });
    widget.onMerchantScanned({});
  }

  void _generateMerchantQR() {
    showDialog(
      context: context,
      builder: (context) => _buildGenerateQRDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Merchant QR Code',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _generateMerchantQR,
                  icon: CustomIconWidget(
                    iconName: 'qr_code_2',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  tooltip: 'Generate QR',
                ),
                IconButton(
                  onPressed: _selectedMerchant != null ? _clearMerchant : null,
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    color: _selectedMerchant != null
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant.withAlpha(128),
                    size: 20,
                  ),
                  tooltip: 'Clear',
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        if (_selectedMerchant != null) ...[
          _buildSelectedMerchant(theme),
        ] else if (_isScanning) ...[
          _buildQRScanner(theme),
        ] else ...[
          _buildScanButton(theme),
        ],
      ],
    );
  }

  Widget _buildSelectedMerchant(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(77),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'store',
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedMerchant!['name'] as String,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _selectedMerchant!['category'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (_selectedMerchant!['location'] != null) ...[
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 12,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        _selectedMerchant!['location'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(26),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'verified',
                  color: Colors.green,
                  size: 12,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Verified',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(ThemeData theme) {
    return GestureDetector(
      onTap: _startScanning,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withAlpha(77),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(50),
              ),
              child: CustomIconWidget(
                iconName: 'qr_code_scanner',
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Scan Merchant QR Code',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Scan to auto-fill merchant details and enable verification',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRScanner(ThemeData theme) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: theme.colorScheme.primary,
                borderRadius: 12,
                borderLength: 30,
                borderWidth: 4,
                cutOutSize: 50.w,
              ),
            ),

            // Top overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(128),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scan QR Code',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: _stopScanning,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom instructions
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withAlpha(128),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  'Position the QR code within the frame',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateQRDialog() {
    final theme = Theme.of(context);
    final qrData =
        'QR_SAMPLE_MERCHANT_${DateTime.now().millisecondsSinceEpoch}';

    return AlertDialog(
      title: Text('Generate Merchant QR'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'This QR code can be used by customers to identify your merchant.',
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 40.w,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            // In a real implementation, this would save the QR code
            // and create a merchant profile
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('QR code generated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: Text('Save QR'),
        ),
      ],
    );
  }
}
