import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _badgeController = TextEditingController(text: "POLICE-2026-99A");
  final _passwordController = TextEditingController(text: "••••••••");
  bool _isScanning = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _triggerBiometricAuth() async {
    setState(() {
      _isScanning = true;
    });
    _animationController.repeat(reverse: true);

    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isScanning = false;
      });
      _animationController.stop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  void _showApiSettingsDialog() {
    final controller = TextEditingController(text: ApiService.baseUrl);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(
            "API Server Settings",
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter your live Backend API URL (e.g., from Render, localtunnel, ngrok, etc.):",
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Backend URL",
                  hintText: "https://your-api.onrender.com",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: AppTheme.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                ApiService.setBaseUrl(controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("API URL updated: ${ApiService.baseUrl}")),
                );
              },
              child: const Text("SAVE", style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E1E38),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                
                // Logo or Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(
                      Icons.security,
                      size: 64,
                      color: AppTheme.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                Center(
                  child: Text(
                    "POLICEMIND AI",
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "Next Gen Investigation Copilot",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),

                // Badge Number Input
                TextField(
                  controller: _badgeController,
                  decoration: const InputDecoration(
                    labelText: "Police ID / Badge Number",
                    prefixIcon: Icon(Icons.badge, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Input
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Security PIN / Password",
                    prefixIcon: Icon(Icons.lock, color: AppTheme.primary),
                  ),
                ),
                
                const SizedBox(height: 24),

                // Standard Login Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    );
                  },
                  child: const Text("ACCESS PORTAL"),
                ),
                
                const SizedBox(height: 24),
                
                Center(
                  child: Text(
                    "OR CONNECT VIA SECURE BIOMETRICS",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // Biometric Scan Area
                GestureDetector(
                  onTap: _isScanning ? null : _triggerBiometricAuth,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isScanning ? AppTheme.accent : Colors.white.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.fingerprint,
                                  size: 72,
                                  color: _isScanning
                                      ? Color.lerp(AppTheme.accent, AppTheme.primary, _animationController.value)
                                      : AppTheme.textSecondary,
                                ),
                                if (_isScanning)
                                  Positioned(
                                    top: 10 + (_animationController.value * 50),
                                    child: Container(
                                      width: 80,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: AppTheme.accent,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.accent.withOpacity(0.8),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isScanning ? "Scanning Local Face & Fingerprint..." : "Tap to Scan Bio-ID",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: _isScanning ? AppTheme.accent : AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),
                
                Center(
                  child: Text(
                    "SECURED WITH AES-256 ENCRYPTION",
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.settings, color: AppTheme.textSecondary),
              onPressed: _showApiSettingsDialog,
            ),
          ),
        ],
      ),
    ),
      ),
    );
  }
}
