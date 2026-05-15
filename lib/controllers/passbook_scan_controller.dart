import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../core/scan_status.dart';
import '../models/bank_details.dart';
import '../parsers/passbook_parser.dart';
import '../services/image_pick_service.dart';
import '../services/ocr_service.dart';

class PassbookScanController extends ChangeNotifier {
  PassbookScanController({
    ImagePickService? imagePickService,
    OcrService? ocrService,
  }) : _imagePickService = imagePickService ?? ImagePickService(),
       _ocrService = ocrService ?? OcrService();

  final ImagePickService _imagePickService;
  final OcrService _ocrService;

  ScanStatus status = ScanStatus.idle;
  XFile? image;
  BankDetails? bankDetails;
  String rawText = '';
  String? errorMessage;

  bool get isLoading =>
      status == ScanStatus.pickingImage || status == ScanStatus.recognizingText;

  Future<void> capturePassbook() async {
    await _runScan(_imagePickService.captureImage);
  }

  Future<void> selectPassbook() async {
    await _runScan(_imagePickService.pickFromGallery);
  }

  void reset() {
    status = ScanStatus.idle;
    image = null;
    bankDetails = null;
    rawText = '';
    errorMessage = null;
    notifyListeners();
  }

  Future<void> _runScan(Future<XFile?> Function() pickImage) async {
    try {
      _setStatus(ScanStatus.pickingImage);
      final selectedImage = await pickImage();
      if (selectedImage == null) {
        _setStatus(ScanStatus.idle);
        return;
      }

      image = selectedImage;
      bankDetails = null;
      rawText = '';
      errorMessage = null;
      _setStatus(ScanStatus.recognizingText);

      rawText = await _ocrService.recognizeText(selectedImage.path);
      final parsed = parsePassbook(rawText);
      bankDetails = parsed;

      if (!parsed.hasAnyValue) {
        errorMessage =
            'No bank details were found. Try a clearer image or crop closer to the document.';
        status = ScanStatus.error;
      } else {
        status = ScanStatus.parsed;
      }
      notifyListeners();
    } catch (error) {
      errorMessage = 'Unable to scan the document. ${error.toString()}';
      status = ScanStatus.error;
      notifyListeners();
    }
  }

  void _setStatus(ScanStatus nextStatus) {
    status = nextStatus;
    notifyListeners();
  }

  @override
  void dispose() {
    _ocrService.close();
    super.dispose();
  }
}
