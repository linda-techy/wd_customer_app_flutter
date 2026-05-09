import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/change_request_summary.dart';
import '../services/cr_otp_service.dart';

/// Visual states for `CrOtpApprovalScreen`. Each maps to a distinct
/// branch in the screen's `build()`.
///
/// Transitions:
///   idle → (requestOtp) → sending → sent
///   sent → (verifyOtp wrong) → verifying → sent (attempts++)
///   sent → (verifyOtp correct) → verifying → approved (terminal)
///   sent → (verifyOtp expired | maxAttempts) → locked
///   any → (requestOtp 429 / network) → error
enum CrOtpState {
  idle,
  sending,
  sent,
  verifying,
  approved,
  locked,
  error,
}

/// Manages the screen state for a single CR's OTP approval flow.
/// Route-scoped (instantiated by the screen route builder), so its
/// lifecycle matches the screen.
class CrOtpProvider with ChangeNotifier {
  /// Resend-cooldown duration. 60 s for email (longer than the 30 s
  /// push cadence — email may take a minute or two to arrive).
  static const int kResendCooldownSeconds = 60;

  final ChangeRequestSummary summary;
  CrOtpProvider(this.summary);

  CrOtpState _state = CrOtpState.idle;
  int _attempts = 0;
  int _resendCooldownSeconds = 0;
  String? _errorMessage;
  Timer? _cooldownTimer;

  CrOtpState get state => _state;
  int get attempts => _attempts;
  int get resendCooldownSeconds => _resendCooldownSeconds;
  String? get errorMessage => _errorMessage;

  /// True when the resend button should accept a tap.
  bool get canResend =>
      (_state == CrOtpState.sent || _state == CrOtpState.error) &&
      _resendCooldownSeconds == 0;

  /// Triggers a server-side OTP request. Transitions Idle/Error/Sent
  /// → Sending → Sent (success) or Error (rate-limit / network).
  Future<void> requestOtp() async {
    _state = CrOtpState.sending;
    _errorMessage = null;
    notifyListeners();
    try {
      await CrOtpService.requestOtp(summary.crId);
      _state = CrOtpState.sent;
      _attempts = 0; // fresh OTP resets the wrong-code counter
      _startCooldown();
    } on RateLimitException catch (e) {
      _state = CrOtpState.error;
      _errorMessage = e.message;
    } on ApiException catch (e) {
      _state = CrOtpState.error;
      _errorMessage = 'Could not send code (${e.statusCode}). Try again.';
    } catch (e) {
      _state = CrOtpState.error;
      _errorMessage = 'Could not send code. Try again.';
    }
    notifyListeners();
  }

  /// Verifies the typed code. On VERIFIED → approved. On WRONG_CODE
  /// stays Sent (attempts++). On EXPIRED / MAX_ATTEMPTS → Locked.
  Future<void> verifyOtp(String code) async {
    _state = CrOtpState.verifying;
    notifyListeners();
    try {
      final r = await CrOtpService.verifyOtp(summary.crId, code);
      switch (r) {
        case OtpVerifyResult.verified:
          _state = CrOtpState.approved;
          _stopCooldown();
          break;
        case OtpVerifyResult.wrongCode:
          _attempts += 1;
          _state = CrOtpState.sent;
          _errorMessage = 'Incorrect code (attempt $_attempts of 3)';
          break;
        case OtpVerifyResult.maxAttempts:
          _attempts = 3;
          _state = CrOtpState.locked;
          _errorMessage = 'Maximum attempts reached. Request a new code.';
          _stopCooldown();
          break;
        case OtpVerifyResult.expired:
          _state = CrOtpState.locked;
          _errorMessage = 'Code expired. Request a new code.';
          _stopCooldown();
          break;
        case OtpVerifyResult.noActiveToken:
          _state = CrOtpState.locked;
          _errorMessage = 'No active code. Request a new code.';
          _stopCooldown();
          break;
      }
    } on ApiException catch (e) {
      _state = CrOtpState.error;
      _errorMessage = 'Could not verify code (${e.statusCode}). Try again.';
    } catch (_) {
      _state = CrOtpState.error;
      _errorMessage = 'Could not verify code. Try again.';
    }
    notifyListeners();
  }

  void _startCooldown() {
    _resendCooldownSeconds = kResendCooldownSeconds;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_resendCooldownSeconds <= 0) {
        _stopCooldown();
        return;
      }
      _resendCooldownSeconds -= 1;
      notifyListeners();
    });
  }

  void _stopCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
  }

  /// Test-only seam to advance the cooldown without waiting on a real
  /// `Timer.periodic`. Mirrors the pattern used by other testable
  /// timer-driven providers.
  @visibleForTesting
  void tickCooldownForTest() {
    if (_resendCooldownSeconds > 0) {
      _resendCooldownSeconds -= 1;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopCooldown();
    super.dispose();
  }
}
