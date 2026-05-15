# Card and Passbook OCR Scanner

A Flutter Android application that scans payment cards and bank passbooks using on-device OCR and manual parsing logic only. The app uses Material 3 UI, Provider state management, ML Kit text recognition, and custom regex plus heuristic parsers.

## Features

- Capture credit/debit card images with the camera.
- Extract card number, expiry date, and card holder name.
- Validate card numbers with a manually implemented Luhn algorithm.
- Mask valid card numbers as `XXXX XXXX XXXX 1234`.
- Capture or select passbook/bank document images.
- Extract account holder name, account number, and IFSC code.
- Show image preview, loading state, parsed structured data, errors, and optional raw OCR text.

## Setup

1. Install the latest stable Flutter SDK.
2. Run `flutter pub get`.
3. Connect an Android device or start an emulator.
4. Run `flutter run`.
5. Run tests with `flutter test`.

## Libraries Used

- `google_mlkit_text_recognition`: on-device OCR.
- `image_picker`: camera capture and gallery selection.
- `provider`: state management via `ChangeNotifier`.
- `flutter_test`: parser and widget tests.

## Architecture

```text
lib/
  core/          shared scan status types
  models/        CardDetails and BankDetails data models
  services/      image picking and OCR wrappers
  parsers/       pure Dart manual parsers and Luhn validation
  controllers/   Provider ChangeNotifier state controllers
  screens/       Home, card scanner, and passbook scanner screens
  widgets/       reusable UI building blocks
  utils/         OCR cleanup helpers
```

The OCR flow is:

1. Pick or capture an image.
2. Run ML Kit text recognition on-device.
3. Pass raw OCR text into a custom parser.
4. Display structured parsed fields and raw OCR text.

## Parsing Assumptions

- Card numbers are accepted only when they are 13 to 19 digits and pass Luhn validation.
- Card parser normalizes common OCR digit mistakes: `O -> 0`, `I/l/| -> 1`, and `S -> 5`.
- Expiry detection supports `MM/YY`, `MM-YY`, and compact `MMYY` values with years from `20` through `40`.
- Card holder names are inferred from uppercase-like lines while ignoring common network and bank words.
- Account numbers prefer 9 to 18 digit values and reject likely phone numbers, dates, and repeated digit noise.
- IFSC detection follows `[A-Z]{4}0[A-Z0-9]{6}` and tolerates OCR reading the fifth `0` as `O`.
- Missing or partial fields are returned as `null` and shown as `Not found`.

## Limitations

- OCR quality depends on lighting, focus, glare, document angle, and crop quality.
- Embossed or stylized card fonts may be misread by OCR.
- Bank documents vary widely, so account holder name extraction is heuristic.
- No backend verification, BIN lookup, bank API, or cloud OCR is used.
- The app is Android-focused for the assignment, though the Flutter project still contains generated iOS/web folders.

## Future Improvements

- Add guided camera overlays for card/passbook framing.
- Add image crop and rotation correction before OCR.
- Add per-bank parsing profiles for common passbook templates.
- Add confidence UI that highlights fields parsed from labeled lines.
- Add integration tests with fixture images.
