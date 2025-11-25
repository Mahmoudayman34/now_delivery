import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/connectivity_provider.dart';

/// Widget that displays connectivity status banners
/// 
/// Shows a red banner when offline (dismissible)
/// Shows a green banner when connection is restored (auto-dismisses after 1 second)
class OfflineBanner extends ConsumerStatefulWidget {
  const OfflineBanner({super.key});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  Timer? _onlineBannerTimer;
  bool? _previousConnectionState;
  bool _showOnlineBanner = false;
  bool _isOfflineBannerDismissed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from bottom (off-screen)
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _onlineBannerTimer?.cancel();
    super.dispose();
  }

  void _showOnlineBannerTemporarily() {
    setState(() {
      _showOnlineBanner = true;
      _isOfflineBannerDismissed = false;
    });
    _animationController.forward();

    _onlineBannerTimer?.cancel();
    _onlineBannerTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        _animationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _showOnlineBanner = false;
            });
          }
        });
      }
    });
  }

  void _dismissOfflineBanner() {
    _animationController.reverse();
    setState(() {
      _isOfflineBannerDismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return connectivityAsync.when(
      data: (isConnected) {
        // Reset dismissal state when connection state changes
        if (_previousConnectionState != isConnected) {
          _isOfflineBannerDismissed = false;
        }

        // Show online banner when transitioning from offline to online
        if (isConnected && _previousConnectionState == false) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showOnlineBannerTemporarily();
          });
        }

        _previousConnectionState = isConnected;

        // Show offline banner if disconnected and not dismissed
        if (!isConnected && !_isOfflineBannerDismissed && !_showOnlineBanner) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _animationController.forward();
          });
          return _buildOfflineBanner();
        }

        // Show online banner if connection restored
        if (_showOnlineBanner) {
          return _buildOnlineBanner();
        }

        // Hide banner if connected or dismissed
        if (isConnected || _isOfflineBannerDismissed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_showOnlineBanner) {
              _animationController.reverse();
            }
          });
        }

        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _buildOfflineBanner(),
    );
  }

  Widget _buildOfflineBanner() {
    return SlideTransition(
      position: _slideAnimation,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 212, 0, 0),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.signal_wifi_off,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You are currently offline',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _dismissOfflineBanner,
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineBanner() {
    return SlideTransition(
      position: _slideAnimation,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.signal_wifi_4_bar,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Back online',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

