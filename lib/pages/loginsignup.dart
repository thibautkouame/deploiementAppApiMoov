import 'package:fitness/pages/forgotPassword.dart';
import 'package:fitness/pages/screens/welcome_urser_register.dart';
import 'package:fitness/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:fitness/widgets/input_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  bool _isSignup = true; // true pour l'inscription, false pour la connexion
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      await _authService.signup(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Inscription réussie!')));
        // Réinitialiser les champs après l'inscription
        _firstNameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _usernameController.clear();
        _passwordController.clear();
        // Basculer vers l'onglet de connexion
        setState(() => _isSignup = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final response = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        // Store the token in shared preferences
        // final prefs = await SharedPreferences.getInstance();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_auth_token', response['token']);

        // Afficher les réponses de l'API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bienvenue ${response['user']['username']}')),
        );
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WelcomeUserRegister()),
          );
        });
        // Réinitialiser les champs après la connexion
        _emailController.clear();
        _passwordController.clear();
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tabs
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTab(' Inscription', true),
                      const SizedBox(width: 15),
                      _buildTab(' Connexion', false),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                if (_isSignup) ...[
                   Text(
                    'Prénom',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InputFieldWidget(
                    controller: _firstNameController,
                    hintText: '',
                  ),
                  const SizedBox(height: 15),

                  Text(
                    'Nom',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InputFieldWidget(
                    controller: _lastNameController,
                    hintText: '',
                  ),
                  const SizedBox(height: 15),
                ],

                if (_isSignup) ...[
                  Text(
                    "Nom d'utilisateur",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InputFieldWidget(
                    controller: _usernameController,
                    hintText: '',
                  ),
                  const SizedBox(height: 15),
                ],

                Text(
                  'Email',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InputFieldWidget(
                  controller: _emailController,
                  hintText: '',
                  isPassword: false,
                  isEmail: true,
                ),
                const SizedBox(height: 15),

                Text(
                  'Mot de passe',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InputFieldWidget(
                  controller: _passwordController,
                  hintText: '********',
                  isPassword: true,
                  isEmail: false,
                ),

                // Mot de passe oublié (only shown on login screen)
                if (!_isSignup) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Mot de passe oublié?',
                        style: GoogleFonts.poppins(
                          color: Color(0xFF3AE374),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Sign up/Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : (_isSignup ? _handleSignup : _handleLogin),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3AE374),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              _isSignup ? "Je m'inscris" : 'Je me connecte',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 15),

                // Or divider
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Or'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 15),

                // Google sign in button
                OutlinedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            // Add Google sign in logic here
                          },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/googleImage.png', height: 24),
                      const SizedBox(width: 8),
                      Text(
                        "S'inscrire avec Google",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isSignup) {
    final isSelected = _isSignup == isSignup;
    return GestureDetector(
      onTap: () => setState(() => _isSignup = isSignup),
      child: Column(
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: isSelected ? const Color(0xFF2ECC71) : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(height: 2, width: 100, color: const Color(0xFF2ECC71)),
        ],
      ),
    );
  }

  // Widget _buildTextField({
  //   required TextEditingController controller,
  //   required String hintText,
  //   bool isPassword = false,
  // }) {
  //   return TextField(
  //     controller: controller,
  //     obscureText: isPassword && _obscurePassword,
  //     decoration: InputDecoration(
  //       hintText: hintText,
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: const BorderSide(color: Color(0xFF3AE374)),
  //       ),
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: const BorderSide(color: Color(0xFF3AE374)),
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: const BorderSide(color: Color(0xFF3AE374), width: 2),
  //       ),
  //       suffixIcon:
  //           isPassword
  //               ? IconButton(
  //                 icon: Icon(
  //                   _obscurePassword ? Icons.visibility_off : Icons.visibility,
  //                   color: Colors.grey,
  //                 ),
  //                 onPressed:
  //                     () =>
  //                         setState(() => _obscurePassword = !_obscurePassword),
  //               )
  //               : null,
  //     ),
  //   );
  // }
}
