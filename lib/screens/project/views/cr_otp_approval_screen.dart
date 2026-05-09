import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../design_tokens/app_colors.dart';
import '../../../providers/cr_otp_provider.dart';

/// Customer OTP approval entry screen. Consumes a route-scoped
/// `CrOtpProvider` (provided by the route builder in `router.dart`).
/// Auto-fires the initial OTP request on first build.
class CrOtpApprovalScreen extends StatefulWidget {
  const CrOtpApprovalScreen({super.key});

  @override
  State<CrOtpApprovalScreen> createState() => _CrOtpApprovalScreenState();
}

class _CrOtpApprovalScreenState extends State<CrOtpApprovalScreen> {
  final _ctrl = TextEditingController();
  bool _initialRequestFired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialRequestFired && mounted) {
        _initialRequestFired = true;
        // Only auto-fire when the provider is fresh — tests (and hot
        // restarts that reuse a provider) may inject one already in
        // `sent`/`approved`, in which case re-firing would trigger a
        // duplicate OTP request.
        final provider = context.read<CrOtpProvider>();
        if (provider.state == CrOtpState.idle) {
          provider.requestOtp();
        }
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CrOtpProvider>();
    final summary = p.summary;
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    // VERIFIED → pop true so co_review_screen can refresh + toast.
    if (p.state == CrOtpState.approved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Approve Change Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card: CR title + cost + time.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    if (summary.description != null) ...[
                      const SizedBox(height: 6),
                      Text(summary.description!,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.grey700)),
                    ],
                    const SizedBox(height: 12),
                    Row(children: [
                      const Text('Cost impact:',
                          style: TextStyle(color: AppColors.grey600)),
                      const Spacer(),
                      Text(
                        '${summary.costImpactRupees < 0 ? "- " : "+ "}${currency.format(summary.costImpactRupees.abs())}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: summary.costImpactRupees < 0
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Text('Time impact:',
                          style: TextStyle(color: AppColors.grey600)),
                      const Spacer(),
                      Text('+${summary.timeImpactWorkingDays} working days',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Body switches by state.
            if (p.state == CrOtpState.locked) ...[
              _LockedBody(
                message: p.errorMessage ?? 'Code expired',
                onRequestNew: () {
                  _ctrl.clear();
                  context.read<CrOtpProvider>().requestOtp();
                },
              ),
            ] else ...[
              const Text(
                'Check your email for an approval code (may take a minute or two).',
                style: TextStyle(color: AppColors.grey700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ctrl,
                maxLength: 6,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22, letterSpacing: 12, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(),
                  hintText: '------',
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (p.errorMessage != null && p.state != CrOtpState.error) ...[
                const SizedBox(height: 6),
                Text(p.errorMessage!,
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 12)),
              ],
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextButton(
                    onPressed: p.canResend
                        ? () => context.read<CrOtpProvider>().requestOtp()
                        : null,
                    child: Text(
                      p.canResend
                          ? 'Resend code'
                          : 'Resend code in ${p.resendCooldownSeconds}s',
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: (_ctrl.text.length == 6 &&
                        p.state != CrOtpState.verifying &&
                        p.state != CrOtpState.sending)
                    ? () => context.read<CrOtpProvider>().verifyOtp(_ctrl.text)
                    : null,
                child: p.state == CrOtpState.verifying
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Verify & Approve'),
              ),
              if (p.state == CrOtpState.error) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    border: Border.all(
                        color: AppColors.error.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(p.errorMessage ?? 'Something went wrong',
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12)),
                ),
              ],
            ],
            const SizedBox(height: 24),
            const Text(
              'By approving you agree to the change request. Logged with timestamp + your device IP.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey600, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedBody extends StatelessWidget {
  final String message;
  final VoidCallback onRequestNew;
  const _LockedBody({required this.message, required this.onRequestNew});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.lock_clock, size: 48, color: AppColors.error),
        const SizedBox(height: 8),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error)),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: onRequestNew,
          child: const Text('Request new code'),
        ),
      ],
    );
  }
}
