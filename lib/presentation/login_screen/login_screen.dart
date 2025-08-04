import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        // Get user profile to determine role-based navigation
        final profile = await _authService.getCurrentUserProfile();

        if (profile != null) {
          _navigateBasedOnRole(profile.role);
        } else {
          // If no profile found, navigate to counter dashboard as default
          Navigator.of(context)
              .pushReplacementNamed(AppRoutes.counterDashboard);
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Login failed: ${error.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateBasedOnRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'manager':
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
        break;
      case 'waiter':
        Navigator.of(context).pushReplacementNamed(AppRoutes.menuSelection);
        break;
      case 'kitchen':
        Navigator.of(context).pushReplacementNamed(AppRoutes.kitchenQueue);
        break;
      case 'counter':
      default:
        Navigator.of(context).pushReplacementNamed(AppRoutes.counterDashboard);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.sp),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo section
                  Container(
                    height: 100.sp,
                    margin: EdgeInsets.only(bottom: 32.sp),
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 48.sp,
                          color: Colors.deepOrange,
                        ),
                        SizedBox(height: 8.sp),
                        Text(
                          'Restaurant Flow',
                          style: GoogleFonts.inter(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.deepOrange,
                          ),
                        ),
                        Text(
                          'Staff Login Portal',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                        borderSide: const BorderSide(color: Colors.deepOrange),
                      ),
                    ),
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

                  SizedBox(height: 16.sp),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                        borderSide: const BorderSide(color: Colors.deepOrange),
                      ),
                    ),
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

                  SizedBox(height: 24.sp),

                  // Login button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.sp),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20.sp,
                            width: 20.sp,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),

                  SizedBox(height: 24.sp),

                  // Demo accounts section
                  Container(
                    padding: EdgeInsets.all(16.sp),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12.sp),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16.sp,
                              color: Colors.blue[700],
                            ),
                            SizedBox(width: 8.sp),
                            Text(
                              'Demo Accounts',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.sp),
                        _buildDemoAccount(
                            'Admin', 'admin@restaurantflow.com', 'admin123'),
                        _buildDemoAccount('Waiter',
                            'waiter1@restaurantflow.com', 'waiter123'),
                        _buildDemoAccount('Counter',
                            'counter@restaurantflow.com', 'counter123'),
                        _buildDemoAccount('Kitchen',
                            'kitchen@restaurantflow.com', 'kitchen123'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoAccount(String role, String email, String password) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.sp),
      child: GestureDetector(
        onTap: () {
          _emailController.text = email;
          _passwordController.text = password;
        },
        child: Row(
          children: [
            Text(
              '$role: ',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: Colors.blue[800],
              ),
            ),
            Expanded(
              child: Text(
                email,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: Colors.blue[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
