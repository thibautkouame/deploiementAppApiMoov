import 'package:fitness/pages/forgotPassword.dart';
import 'package:fitness/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:fitness/widgets/input_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness/theme/theme.dart';
import 'package:fitness/pages/welcome.dart';
import 'package:fitness/pages/screens/home_screen.dart';

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


  // Ajout d'une map pour suivre les erreurs de champs
  final Map<String, bool> _fieldErrors = {
    'firstName': false,
    'lastName': false,
    'username': false,
    'email': false,
    'password': false,
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    bool hasError = false;
    bool emailFormatError = false;
    bool passwordLengthError = false;
    setState(() {
      if (_isSignup) {
        _fieldErrors['firstName'] = _firstNameController.text.trim().isEmpty;
        _fieldErrors['lastName'] = _lastNameController.text.trim().isEmpty;
        _fieldErrors['username'] = _usernameController.text.trim().isEmpty;
      } else {
        _fieldErrors['firstName'] = false;
        _fieldErrors['lastName'] = false;
        _fieldErrors['username'] = false;
      }
      _fieldErrors['email'] = _emailController.text.trim().isEmpty;
      _fieldErrors['password'] = _passwordController.text.isEmpty;


      // Vérification du format email
      final email = _emailController.text.trim();
      final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
      emailFormatError = email.isNotEmpty && !emailRegex.hasMatch(email);
      if (emailFormatError) _fieldErrors['email'] = true;


      // Vérification longueur mot de passe UNIQUEMENT à l'inscription
      final password = _passwordController.text;
      passwordLengthError = _isSignup && password.isNotEmpty && password.length < 6;
      if (passwordLengthError) _fieldErrors['password'] = true;
      hasError = _fieldErrors.values.any((e) => e);
    });
    if (emailFormatError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir une adresse email valide pour continuer.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      );
      return false;
    }
    if (passwordLengthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le mot de passe doit contenir au moins 6 caractères.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      );
      return false;
    }
    return !hasError;
  }

  Future<void> _handleSignup() async {
    if (_isLoading) return;
    if (!_validateFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez remplir tous les champs obligatoires pour continuer.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

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
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Votre inscription a été effectuée avec succès, veuillez maintenant vous connecter."),
            backgroundColor: AppColors.primary,
            duration:  Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        );
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
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vérifiez si vous êtes bien connecté à internet et que votre email et votre mot de passe sont corrects pour continuer."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    if (!_validateFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires pour continuer.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_auth_token', response['token']);
        bool hasSeenWelcome = prefs.getBool('has_seen_welcome') ?? false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Text('Bienvenue ${response['user']['username']}'),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        );
        Future.delayed(Duration(seconds: 3), () {
          if (!hasSeenWelcome) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        });
        _emailController.clear();
        _passwordController.clear();
      }
    } catch (e) {
      // print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vérifiez si vous êtes bien connecté à internet et que votre email et votre mot de passe sont corrects pour continuer."),
            backgroundColor: Colors.red,
            duration:  Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin:  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        );
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
                    error: _fieldErrors['firstName']!,
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
                    error: _fieldErrors['lastName']!,
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
                    error: _fieldErrors['username']!,
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
                  error: _fieldErrors['email']!,
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
                  error: _fieldErrors['password']!,
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
                            builder: (context) => const ForgotPasswordPage(),
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
                // Row(
                //   children: const [
                //     Expanded(child: Divider()),
                //     Padding(
                //       padding: EdgeInsets.symmetric(horizontal: 16),
                //       child: Text('Or'),
                //     ),
                //     Expanded(child: Divider()),
                //   ],
                // ),

                const SizedBox(height: 15),

                // Google sign in button
                // OutlinedButton(
                //   onPressed:
                //       _isLoading
                //           ? null
                //           : () {
                //             // Add Google sign in logic here
                //           },
                //   style: OutlinedButton.styleFrom(
                //     padding: const EdgeInsets.symmetric(vertical: 16),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     side: const BorderSide(color: Color(0xFFD0D0D0)),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Image.asset('assets/images/googleImage.png', height: 24),
                //       const SizedBox(width: 8),
                //       Text(
                //         "S'inscrire avec Google",
                //         style: GoogleFonts.poppins(
                //           fontSize: 16,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.black,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
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
