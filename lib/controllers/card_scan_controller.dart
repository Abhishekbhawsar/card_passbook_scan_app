import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../core/scan_status.dart';
import '../models/card_details.dart';
import '../parsers/card_parser.dart';
import '../services/image_pick_service.dart';
import '../services/ocr_service.dart';

class CardScanController extends ChangeNotifier {
  CardScanController({
    ImagePickService? imagePickService,
    OcrService? ocrService,
  }) : _imagePickService = imagePickService ?? ImagePickService(),
       _ocrService = ocrService ?? OcrService();

  final ImagePickService _imagePickService;
  final OcrService _ocrService;

  ScanStatus status = ScanStatus.idle;
  XFile? image;
  CardDetails? cardDetails;
  String rawText = '';
  String? errorMessage;

  bool get isLoading =>
      status == ScanStatus.pickingImage || status == ScanStatus.recognizingText;

  Future<void> scanCard() async {
    await _runScan(_imagePickService.captureImage);
  }

  void reset() {
    status = ScanStatus.idle;
    image = null;
    cardDetails = null;
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
      cardDetails = null;
      rawText = '';
      errorMessage = null;
      _setStatus(ScanStatus.recognizingText);

      rawText = await _ocrService.recognizeText(selectedImage.path);
      final parsed = parseCard(rawText);
      cardDetails = parsed;

      if (!parsed.hasValidCard) {
        errorMessage =
            'No valid card number was found. Try a sharper, front-facing image.';
        status = ScanStatus.error;
      } else {
        status = ScanStatus.parsed;
      }
      notifyListeners();
    } catch (error) {
      errorMessage = 'Unable to scan the card. ${error.toString()}';
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
