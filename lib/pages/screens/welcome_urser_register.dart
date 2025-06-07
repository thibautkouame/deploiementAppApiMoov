import 'package:flutter/material.dart';
import 'package:fitness/widgets/button_widget.dart';
import 'package:fitness/widgets/input_field.dart';
import 'package:fitness/widgets/space_widget.dart';
import 'package:fitness/widgets/success_message.dart';
import 'package:fitness/theme/theme.dart';
import 'package:fitness/services/app_services.dart';
import 'package:fitness/services/auth_service.dart';
import 'package:fitness/models/user.dart';
import 'package:fitness/pages/screens/home_screen.dart';
import 'package:fitness/pages/loginsignup.dart';

class WelcomeUserRegister extends StatefulWidget {
  const WelcomeUserRegister({super.key});

  @override
  State<WelcomeUserRegister> createState() => _WelcomeUserRegisterState();
}

class _WelcomeUserRegisterState extends State<WelcomeUserRegister> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  //controller pour les inputs
  TextEditingController _ageController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _activityController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();

  // Variables pour le sexe et le niveau
  String _selectedGender = '';
  String _selectedLevel = '';
  User? _userInfo;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeUserInfo();
  }

  Future<void> _initializeUserInfo() async {
    try {
      String? token = await _loadToken();
      if (token != null) {
        await _loadUserInfo(token);
      } else {
        print('Aucun token trouvé, l\'utilisateur n\'est pas connecté');
      }
    } catch (e) {
      print(
          'Erreur lors de l\'initialisation des informations utilisateur: $e');
      // Ne pas bloquer l'application si l'utilisateur n'est pas connecté
    }
  }

  Future<String?> _loadToken() async {
    try {
      TokenService tokenService = TokenService();
      String? token = await tokenService.getToken();
      if (token != null) {
        print('Token trouvé dans SharedPreferences');
      } else {
        print('Aucun token trouvé dans SharedPreferences');
      }
      return token;
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  Future<void> _loadUserInfo(String token) async {
    try {
      AuthService authService = AuthService();
      User userInfo = await authService.getUserInfo(token);
      print('Informations utilisateur chargées avec succès');
      print('Username: ${userInfo.username}');
      print('Email: ${userInfo.email}');
      print('Nom: ${userInfo.f_name}');
      print('Prénom: ${userInfo.l_name}');
      print('Age: ${userInfo.age}');
      print('Poids: ${userInfo.weight}');
      print('Taille: ${userInfo.height}');
      print('Niveau: ${userInfo.actual_level}');
      print('Activité: ${userInfo.daily_training_type}');
      setState(() {
        _userInfo = userInfo;
      });
    } catch (e) {
      print(
          'Erreur lors du chargement des informations utilisateur: ${e.toString()}');
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginSignupPage()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _updateUserInfo() async {
    try {
      String? token = await _loadToken();
      if (token == null) {
        throw Exception(
            'Aucun token trouvé, l\'utilisateur n\'est pas connecté');
      }

      AuthService authService = AuthService();

      // On conserve les anciennes données si les nouvelles sont vides
      await authService.updateProfile(
        token: token,
        firstName: _userInfo?.f_name ?? '',
        lastName: _userInfo?.l_name ?? '',
        email: _userInfo?.email ?? '',
        username: _usernameController.text.isNotEmpty
            ? _usernameController.text
            : _userInfo?.username ?? '',
        sex:
            _selectedGender.isNotEmpty ? _selectedGender : _userInfo?.sex ?? '',
        age: _ageController.text.isNotEmpty
            ? _ageController.text
            : _userInfo?.age.toString() ?? '',
        weight: _weightController.text.isNotEmpty
            ? _weightController.text
            : _userInfo?.weight.toString() ?? '',
        height: _heightController.text.isNotEmpty
            ? _heightController.text
            : _userInfo?.height.toString() ?? '',
        actual_level: _selectedLevel.isNotEmpty
            ? _selectedLevel
            : _userInfo?.actual_level ?? '',
        daily_training_type: _activityController.text.isNotEmpty
            ? _activityController.text
            : _userInfo?.daily_training_type ?? '',
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SuccessMessage(
              message:
                  'Félicitations, vos informations ont été enregistrées avec succès.',
              onContinue: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la mise à jour: ${e.toString()}')),
        );
      }
    }
  }

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _selectLevel(String level) {
    setState(() {
      _selectedLevel = level;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildFirstPage(),
          _buildThirdPage(),
          _buildFourthPage(),
          _buildSecondPage(),
        ],
      ),
    );
  }

  Widget _buildFirstPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0, left: 10.0, right: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image en haut de la page
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/randonnee.jpg', // Remplace par ton image
                fit: BoxFit.cover,
                height: 250,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 20),

            // Titre de la page
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Laisse nous mieux te connaitre',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Ligne 1 - Sexe et Age
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: InputFieldWidget(
                      controller: _ageController,
                      hintText: 'Age',
                      inputType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Ligne 2 - Poids et Taille
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: InputFieldWidget(
                      controller: _weightController,
                      hintText: 'Poids(kg)',
                      inputType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InputFieldWidget(
                      controller: _heightController,
                      hintText: 'Taille(cm)',
                      inputType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Champ d'activité
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3AE374)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3AE374)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF3AE374),
                      width: 2,
                    ),
                  ),
                ),
                hint: Text('Choisir une activité'),
                items: <String>[
                  'Sédentaire',
                  'Football',
                  'Basket-ball',
                  'Volley-ball',
                  'Jogging',
                  'Marathon',
                  'Yoga',
                  'Musculation',
                  'Natation',
                  'Cyclisme',
                  'Marche',
                  'Autre',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _activityController.text = newValue ?? '';
                  });
                },
              ),
            ),
            const SizedBox(height: 30),

            // Bouton Confirmer
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ButtonWidget(
                text: 'Confirmer',
                onPressed: () {
                  // Vérifier si tous les champs requis sont remplis
                  if (_ageController.text.isEmpty ||
                      _weightController.text.isEmpty ||
                      _heightController.text.isEmpty ||
                      _activityController.text.isEmpty) {
                    // Afficher un message d'erreur si un champ est vide
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Veuillez remplir tous les champs obligatoires pour continuer.'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  } else {
                    // Si tous les champs sont remplis, passer à la page suivante
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Widget _buildSecondPage() {
    String age = _ageController.text;
    String poids = _weightController.text;
    String taille = _heightController.text;
    String activite = _activityController.text;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFF3AE374).withOpacity(0.2)],
        ),
      ),
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/running_beach.jpg',
                fit: BoxFit.cover,
                height: 250,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Récapitulons tes données',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.person, 'Nom d\'utilisateur',
                      _userInfo?.username ?? 'Non défini'),
                  const Divider(height: 20),
                  _buildInfoRow(Icons.person, 'Sexe', _selectedGender),
                  const Divider(height: 20),
                  _buildInfoRow(Icons.calendar_today, 'Age', '$age ans'),
                  const Divider(height: 20),
                  _buildInfoRow(Icons.monitor_weight, 'Poids', '$poids kg'),
                  const Divider(height: 20),
                  _buildInfoRow(Icons.height, 'Taille', '$taille cm'),
                  const Divider(height: 20),
                  _buildInfoRow(Icons.directions_run, 'Activité', activite),
                  const Divider(height: 20),
                  _buildInfoRow(Icons.fitness_center, 'Niveau', _selectedLevel),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonWidget(
                      text: 'Modifier',
                      onPressed: () {
                        _pageController.jumpToPage(0);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ButtonWidget(
                      text: 'Confirmer',
                      onPressed: _updateUserInfo,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour afficher une ligne d'information (avec icône et valeur)
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF3AE374), size: 24),
        SizedBox(width: 15),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value.isEmpty
                    ? 'Non défini'
                    : value, // Si vide, afficher "Non défini"
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// Page avec sélection du genre
  Widget _buildThirdPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFF3AE374).withOpacity(0.2)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Es-tu?',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          SpaceWidget.height16,
          Text('Un Homme'),
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF3AE374), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 1.5,
                  right: 1.5,
                  top: 10,
                  bottom: 1.5,
                ),
                child: Image.asset(
                  'assets/images/man.png',
                  height: 80,
                  width: 80,
                ),
              ),
            ),
            iconSize: 100,
            onPressed: () => _selectGender('Homme'),
          ),
          SpaceWidget.height16,
          Text('Une Femme'),
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF3AE374), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 1.5,
                  right: 1.5,
                  top: 10,
                  bottom: 1.5,
                ),
                child: Image.asset(
                  'assets/images/woman.png',
                  height: 80,
                  width: 80,
                ),
              ),
            ),
            iconSize: 100,
            onPressed: () => _selectGender('Femme'),
          ),
          SpaceWidget.height16,
          Text('Autre'),
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF3AE374), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 1.5,
                  right: 1.5,
                  top: 10,
                  bottom: 1.5,
                ),
                child: Image.asset(
                  'assets/images/manorwoman.png',
                  height: 80,
                  width: 80,
                ),
              ),
            ),
            iconSize: 100,
            onPressed: () => _selectGender('Autre'),
          ),
          SpaceWidget.height16,
          SpaceWidget.height16,

          // Bouton Confirmer
          // Container(
          //   width: double.infinity,
          //   padding: EdgeInsets.symmetric(horizontal: 20),
          //   child: ButtonWidget(
          //     text: 'Confirmer',
          //     onPressed: () {
          //       // Vérification si un genre a été sélectionné
          //       if (_selectedGender.isEmpty) {
          //         // Afficher un message d'erreur si aucun genre sélectionné
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(content: Text('Veuillez sélectionner un genre.')),
          //         );
          //       } else {
          //         // Si un genre est sélectionné, passer à la page suivante
          //         _pageController.nextPage(
          //           duration: Duration(milliseconds: 300),
          //           curve: Curves.ease,
          //         );
          //       }
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildFourthPage() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 310,
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.green, Colors.black],
              ),
            ),
            child: Image.asset(
              'assets/images/image_level.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.6,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color.fromARGB(123, 189, 188, 188),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => _selectLevel('Débutant'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 40),
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3AE374), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: const Text(
                          'DEBUTANT',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _selectLevel('Intermédiaire'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 40),
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.8),
                            Colors.white.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: const Text(
                          'INTERMEDIAIRE',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _selectLevel('Avancé'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 40),
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.8),
                            Colors.white.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: const Text(
                          'AVANCE',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
