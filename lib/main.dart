import 'package:final_app_vision/home.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/emergency_gesture_detector.dart';

Future<void> main() async {
  CloudinaryContext.cloudinary =
      Cloudinary.fromCloudName(cloudName: 'dkglul7cz');
  await Supabase.initialize(
    url: 'https://qilmmwmfajorqfvxtnjx.supabase.co', // Replace with your URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpbG1td21mYWpvcnFmdnh0bmp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMTk5NjksImV4cCI6MjA1Nzg5NTk2OX0.YkEBGr-KIo3bonCZ2QxftwHc7jiSzIGZD6V9t5LUhrA', // Replace with your anon key
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmergencyGestureDetector(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Healthcare Login',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintStyle: TextStyle(color: Colors.white70),
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          ),
        ),
        home: const AuthWidget(),
      ),
    );
  }
}

class AuthWidget extends StatelessWidget {
  const AuthWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Listen to the authentication state changes.
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // While waiting for the auth state, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Check the current session.
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleAuth() {
    setState(() {
      if (isLogin) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A237E), // Deep indigo
                  Color(0xFF3949AB), // Indigo
                  Color(0xFF1976D2), // Blue
                ],
              ),
            ),
          ),

          // Background patterns
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),

          // Blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.medical_services_rounded,
                            size: 60,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: Text(
                          isLogin ? 'Welcome Back' : 'Create Account',
                          key: ValueKey(isLogin),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

                      // Subtitle with animation
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: Text(
                          isLogin
                              ? 'Sign in to access your account'
                              : 'Register to get started',
                          key: ValueKey(isLogin),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 40),

                      // Form with animation
                      AnimatedCrossFade(
                        firstChild: LoginForm(),
                        secondChild: RegisterForm(),
                        crossFadeState: isLogin
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: Duration(milliseconds: 400),
                        layoutBuilder: (topChild, topChildKey, bottomChild,
                            bottomChildKey) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                key: bottomChildKey,
                                top: 0,
                                child: bottomChild,
                              ),
                              Positioned(
                                key: topChildKey,
                                child: topChild,
                              ),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: 20),

                      // Toggle between login and register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLogin
                                ? "Don't have an account? "
                                : "Already have an account? ",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          TextButton(
                            onPressed: toggleAuth,
                            child: Text(
                              isLogin ? 'Sign Up' : 'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        final res = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (res.session != null) {
          final userId = res.user!.id;

          // ✅ Fetch user profile from Supabase
          final profile = await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('user_id', userId)
              .single();

          // ✅ Store user details in local state (optional)
          if (profile != null) {
            print("Guardian Name: ${profile['guardian_name']}");
            print("Username: ${profile['username']}");
            print("Patient Name: ${profile['patient_name']}");
          }

          setState(() {
            _isLoading = false;
          });

          // ✅ Navigate to HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login failed, please try again.")),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width > 500
          ? 500
          : MediaQuery.of(context).size.width * 0.9,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Guardian Email',
                prefixIcon:
                    const Icon(Icons.email_outlined, color: Colors.white70),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                // Additional email validation can be added here
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon:
                    const Icon(Icons.lock_outline, color: Colors.white70),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Login button
            ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A237E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF1A237E)),
                    )
                  : const Text(
                      'SIGN IN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  // Define controllers for each field.
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _guardianNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _patientNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final guardianName = _guardianNameController.text.trim();
      final username = _usernameController.text.trim();
      final patientName = _patientNameController.text.trim();

      try {
        // 1. Register user with metadata using Supabase Auth.
        final res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {
            'guardian_name': guardianName,
            'username': username,
            'patient_name': patientName,
          },
        );

        // 2. Even if email verification is required, res.user is created.
        if (res.user != null) {
          final userId = res.user!.id;

          // 3. Insert additional user details into the profiles table.
          //    If there's an error, it will throw an exception caught by the catch block.
          await Supabase.instance.client.from('profiles').insert({
            'user_id': userId,
            'guardian_name': guardianName,
            'username': username,
            'patient_name': patientName,
            'email': email,
          });
        }

        setState(() {
          _isLoading = false;
        });

        // 4. Navigate to HomeScreen regardless of email verification.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } catch (e) {
        // If any exception is thrown (including from the insert call), it lands here.
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width > 500
          ? 500
          : MediaQuery.of(context).size.width * 0.9,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Guardian Name Field
            TextFormField(
              controller: _guardianNameController,
              keyboardType: TextInputType.name,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Guardian Name',
                prefixIcon:
                    const Icon(Icons.person_outline, color: Colors.white70),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter guardian name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Username Field
            TextFormField(
              controller: _usernameController,
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Username',
                prefixIcon:
                    const Icon(Icons.alternate_email, color: Colors.white70),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter username';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Guardian Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Guardian Email',
                prefixIcon:
                    const Icon(Icons.email_outlined, color: Colors.white70),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter guardian email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Patient Name Field
            TextFormField(
              controller: _patientNameController,
              keyboardType: TextInputType.name,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Patient Name',
                prefixIcon:
                    const Icon(Icons.personal_injury, color: Colors.white70),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter patient name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscureText,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon:
                    const Icon(Icons.lock_outline, color: Colors.white70),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Register Button
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A237E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF1A237E)),
                    )
                  : const Text(
                      'SIGN UP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for background patterns
class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw some circles for decoration
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.1),
      size.width * 0.2,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      size.width * 0.25,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.7),
      size.width * 0.15,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.9),
      size.width * 0.3,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
