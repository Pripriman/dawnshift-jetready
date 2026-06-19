import 'package:flutter/material.dart';

import '../../config/journey_env.dart';
import '../../runtime/circadian_bridge.dart';
import '../../runtime/phase_beacon.dart';
import '../../runtime/pulse_relay.dart';
import '../../theme/dawn_palette.dart';
import '../../theme/dawn_type.dart';
import '../../widgets/dawn_card.dart';
import '../../widgets/glide_button.dart';

class AccessDeck extends StatefulWidget {
  final VoidCallback onDone;
  const AccessDeck({super.key, required this.onDone});

  @override
  State<AccessDeck> createState() => _AccessDeckState();
}

class _AccessDeckState extends State<AccessDeck> {
  final _email = TextEditingController();
  final _secret = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _registerMode = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _secret.dispose();
    super.dispose();
  }

  void _notice(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (!JourneyEnv.hasBackend) {
      _notice('Profiles are unavailable right now.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      if (_registerMode) {
        final res =
            await CircadianBridge.register(_email.text.trim(), _secret.text);
        PhaseBeacon.registration();
        final uid = res.user?.id;
        if (uid != null) await PulseRelay.linkTraveler(uid);
        _notice('Profile created. Check your inbox to confirm.');
      } else {
        final res =
            await CircadianBridge.signIn(_email.text.trim(), _secret.text);
        PhaseBeacon.login();
        final uid = res.user?.id;
        if (uid != null) await PulseRelay.linkTraveler(uid);
      }
      if (!mounted) return;
      widget.onDone();
    } catch (e) {
      _notice(_readableError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _readableError(Object e) {
    final s = e.toString();
    if (s.contains('Invalid login')) return 'Wrong email or password.';
    if (s.contains('already registered')) {
      return 'This email already has a profile.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> _recover() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      _notice('Enter your email first, then tap recover.');
      return;
    }
    try {
      await CircadianBridge.recoverAccess(email);
      _notice('Recovery link sent.');
    } catch (_) {
      _notice('Could not send a recovery link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: DawnPalette.skylineGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: QuietLink(
                    label: 'Skip for now',
                    onPressed: _busy ? null : widget.onDone,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    gradient: DawnPalette.horizonGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.brightness_5_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                Text(_registerMode ? 'Create your profile' : 'Welcome back',
                    style: DawnType.title()),
                const SizedBox(height: 8),
                Text(
                  'A profile syncs your checklist and plans across devices and powers gentle travel reminders. It is optional — the companion works fully offline.',
                  style: DawnType.body(),
                ),
                const SizedBox(height: 24),
                DawnCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          validator: (v) {
                            final t = (v ?? '').trim();
                            if (t.isEmpty || !t.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _secret,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          decoration: const InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                          validator: (v) {
                            if ((v ?? '').length < 6) {
                              return 'At least 6 characters';
                            }
                            return null;
                          },
                        ),
                        if (!_registerMode) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: QuietLink(
                              label: 'Forgot password?',
                              onPressed: _busy ? null : _recover,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        GlideButton(
                          label:
                              _registerMode ? 'Create profile' : 'Sign in',
                          busy: _busy,
                          onPressed: _busy ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() => _registerMode = !_registerMode),
                  child: Text(
                    _registerMode
                        ? 'I already have a profile'
                        : 'New here? Create a profile',
                    style: DawnType.label(color: DawnPalette.duskDeep),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
