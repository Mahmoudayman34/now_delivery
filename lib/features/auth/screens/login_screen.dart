import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../providers/auth_provider.dart';
import '../models/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _passwordToggleController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _passwordToggleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _passwordToggleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _passwordToggleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _passwordToggleController,
      curve: Curves.elasticOut,
    ));

    // Start animations with delays
    _startAnimations();
  }

  void _startAnimations() async {
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _slideController.forward();

    // Start continuous animations after initial entrance
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _passwordToggleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final textTheme = AppTheme.getResponsiveTextTheme(context);
    final spacing = AppTheme.spacing(context);

    // Show error snackbar if there's an error
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.hasError && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: Responsive.builder(
          context: context,
          mobile: _buildMobileLayout(context, authState, textTheme, spacing),
          tablet: context.isLandscape
              ? _buildTabletLandscapeLayout(context, authState, textTheme, spacing)
              : _buildMobileLayout(context, authState, textTheme, spacing),
          desktop: _buildDesktopLayout(context, authState, textTheme, spacing),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    AuthState authState,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: spacing.lg),
            _buildHeader(context, textTheme, spacing),
            SizedBox(height: spacing.lg),
            _buildLoginForm(context, authState, textTheme, spacing),
            SizedBox(height: spacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLandscapeLayout(
    BuildContext context,
    AuthState authState,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return Row(
      children: [
        // Left side - Header/Image
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(spacing.xl),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(context, textTheme, spacing),
                  SizedBox(height: spacing.lg),
                  _buildWelcomeText(context, textTheme, spacing),
                ],
              ),
            ),
          ),
        ),
        // Right side - Form
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(spacing.xl),
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: _buildLoginForm(context, authState, textTheme, spacing),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    AuthState authState,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: context.responsive<double>(
            mobile: 400,
            desktop: 1000,
            largeDesktop: 1200,
          ),
        ),
        child: Row(
          children: [
            // Left side - Header/Image
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(spacing.xxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(context, textTheme, spacing),
                    SizedBox(height: spacing.xl),
                    _buildWelcomeText(context, textTheme, spacing),
                    SizedBox(height: spacing.lg),
                    Text(
                      'Manage your deliveries efficiently with our comprehensive platform designed for modern logistics.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppTheme.mediumGray,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: spacing.xxl),
            // Right side - Form
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(spacing.xl),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 450),
                    child: _buildLoginForm(context, authState, textTheme, spacing),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return Column(
      children: [
        _buildLogo(context, textTheme, spacing),
        SizedBox(height: spacing.md),
        _buildWelcomeText(context, textTheme, spacing),
      ],
    );
  }

  Widget _buildLogo(
    BuildContext context,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    final logoSize = context.responsive<double>(
      mobile: MediaQuery.of(context).size.width * 0.35,
      tablet: 180,
      desktop: 200,
      largeDesktop: 240,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: context.responsive<double>(
                    mobile: 20,
                    tablet: 25,
                    desktop: 30,
                  ),
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/login_image.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryOrange.withOpacity(0.8),
                          AppTheme.darkOrange,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.delivery_dining,
                      size: logoSize * 0.4,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeText(
    BuildContext context,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Text(
            'Welcome Back!',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Sign in to continue your delivery journey',
            style: textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(
    BuildContext context,
    AuthState authState,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: context.responsive<double>(
            mobile: 8,
            tablet: 0,
            desktop: 0,
          ),
        ),
        padding: EdgeInsets.all(spacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: Responsive.borderRadius(
            context,
            mobile: 24,
            tablet: 28,
            desktop: 32,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: context.responsive<double>(
                mobile: 20,
                tablet: 25,
                desktop: 30,
              ),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              CustomTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing.md),

              // Password Field
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
                prefixIcon: Icons.lock_outline,
                suffixIcon: _isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                suffixIconAnimation: _passwordToggleAnimation,
                onSuffixIconTap: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                  // Add a subtle bounce animation to the button
                  _passwordToggleController.reset();
                  _passwordToggleController.forward();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing.md),

              // Remember Me
              Row(
                children: [
                  Transform.scale(
                    scale: context.responsive<double>(
                      mobile: 0.8,
                      tablet: 0.9,
                      desktop: 1.0,
                    ),
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: AppTheme.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    'Remember me',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.lg),

              // Login Button
              LoadingButton(
                onPressed: _handleLogin,
                isLoading: authState.isLoading,
                text: 'Sign In',
              ),
            ],
          ),
        ),
      ),
    );
  }
}