import 'package:fitness/widgets/confirm_message.dart';
import 'package:fitness/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fitness/services/auth_service.dart';
import 'package:fitness/models/user.dart';
import 'package:fitness/pages/screens/progress_screen.dart';
import 'package:fitness/pages/screens/user_profile.dart';
import 'package:fitness/theme/theme.dart';
import 'package:fitness/pages/screens/edit_profile.dart';
import 'package:fitness/pages/screens/stats_screen.dart';
import 'package:fitness/pages/screens/stats_screen_for_profil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness/pages/loginsignup.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fitness/pages/screens/home_screen.dart';

import '../../widgets/success_message.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> _userFuture;
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _userFuture =
        Future.error('User not authenticated'); // Initialize with error state
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final token = await AuthService.getToken();
    if (token != null) {
      setState(() {
        _userFuture = _authService.getUserInfo(token);
      });
    } else {
      setState(() {
        _userFuture = Future.error('User not authenticated');
      });
    }
  }

  Future<void> _pickAndUpdateProfilePicture() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      // Get current user data
      final currentUser = await _userFuture;

      // Update profile with new picture
      final updatedUser = await _authService.updateProfile(
        token: token,
        firstName: currentUser.f_name ?? '',
        lastName: currentUser.l_name ?? '',
        email: currentUser.email ?? '',
        username: currentUser.username ?? '',
        sex: currentUser.sex ?? '',
        age: currentUser.age ?? '',
        weight: currentUser.weight ?? '',
        height: currentUser.height ?? '',
        actual_level: currentUser.actual_level ?? '',
        daily_training_type: currentUser.daily_training_type ?? '',
        profilePicture: File(image.path),
      );

      // Refresh user data
      setState(() {
        _userFuture = Future.value(updatedUser);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profil mis à jour avec succès.'),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la mise à jour de la photo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: FutureBuilder<User>(
                    future: _userFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        if (snapshot.error
                                .toString()
                                .contains('Token invalide') ||
                            snapshot.error.toString().contains('401')) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const LoginSignupPage()),
                              (route) => false,
                            );
                          });
                          return const SizedBox.shrink();
                        }
                        return Center(
                          child: Text('Erreur: ${snapshot.error}'),
                        );
                      }

                      final user = snapshot.data!;

                      return Column(
                        children: [
                          // Top Bar
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    // Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HomeScreen()));
                                  },
                                  icon: const Icon(Icons.arrow_back),
                                ),
                                Text(
                                  'Mon profil',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4CD964),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(LucideIcons.user,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),

                          // Profile Picture and Name
                          Column(
                            children: [
                              GestureDetector(
                                onTap: _pickAndUpdateProfilePicture,
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primary,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.white,
                                        backgroundImage: NetworkImage(user
                                                    .profile_picture !=
                                                null
                                            ? '${AuthService.baseUrlImage}${user.profile_picture}'
                                            : 'https://img.freepik.com/premium-vector/collection-3d-sport-icon-collection-isolated-blue-sport-recreation-concept_112554-928.jpg'),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          LucideIcons.camera,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${user.username}',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          // Stats
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 24, horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Flexible(
                                    child: _buildStat(
                                        'Taille', '${user.height}cm')),
                                Flexible(
                                    child: _buildStat(
                                        'Poids', '${user.weight}kg')),
                                Flexible(
                                    child: _buildStat('Age', '${user.age}ans')),
                              ],
                            ),
                          ),

                          // Account Section
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Compte',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 30),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UserProfile(user: user)),
                                          );
                                        },
                                        child: _buildMenuItem(
                                            LucideIcons.user,
                                            'Données Personnelles',
                                            Colors.pink),
                                      ),
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProgressScreen()));
                                        },
                                        child: _buildMenuItem(
                                            LucideIcons.pieChart,
                                            'Historique',
                                            Colors.pink),
                                      ),
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const HomeScreen(
                                                      selectedIndex: 1),
                                            ),
                                            (route) => false,
                                          );
                                        },
                                        child: _buildMenuItem(
                                            LucideIcons.barChartBig,
                                            'Progression',
                                            Colors.pink),
                                      ),
                                      const SizedBox(height: 30),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Other Section
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Autre',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const EditProfile()));
                                        },
                                        child: _buildMenuItem(
                                            LucideIcons.settings,
                                            'Paramètres',
                                            Colors.pink),
                                      ),
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                ConfirmMessage(
                                              message:
                                                  'Voulez-vous vraiment supprimer votre compte ? Cette action est irréversible.',
                                              confirmText: "OUI",
                                              cancelText: "NON",
                                              onConfirm: () {
                                                Navigator.pop(context);
                                                _deleteAccount();
                                              },
                                            ),
                                          );
                                        },
                                        child: _buildMenuItem(
                                            LucideIcons.trash,
                                            'Supprimer votre compte',
                                            Colors.pink,
                                            textColor: Colors.red),
                                      ),
                                      GestureDetector(
                                        onTap: _logout,
                                        child: _buildMenuItem(
                                            LucideIcons.logOut,
                                            'Déconnexion',
                                            Colors.pink),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Bottom Navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Color(0xff9DCEFF), Color(0xffE9062F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color color,
      {Color? textColor}) {
    return Container(
      height: 70,
      color: Colors.white, // Added background color
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 16, color: textColor),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => ConfirmMessage(
        message: 'Voulez-vous vraiment vous déconnecter ?',
        confirmText: "OUI",
        cancelText: "NON",
        onConfirm: () async {
          Navigator.pop(context);
          await AuthService.removeToken();
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginSignupPage()),
            (Route<dynamic> route) => false,
          );
        },
      ),
    );
  }

  void _deleteAccount() async {
    final token = await AuthService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Non authentifié.')),
      );
      return;
    }
    showLoadingDialog(context);
    try {
      // Recharge le user à la dernière seconde pour garantir les bonnes infos
      final user = await AuthService().getUserInfo(token);
      final response = await AuthService().requestDeleteAccount(
        token: token,
        f_name: user.f_name ?? '',
        l_name: user.l_name ?? '',
        email: user.email ?? '',
      );

      print('la reponse est: ${response}');
      Navigator.pop(context); // Fermer loading
      if (response['status'] == 200) {
        showDialog(
          context: context,
          builder: (context) => SuccessMessage(
            message:
                "${response?['message'] ?? response.toString()}",
            onContinue: () async {
              await AuthService.removeToken();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginSignupPage()),
                (route) => false,
              );
            },
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => SuccessMessage(
            message: 'Erreur lors de la demande de suppression :\n${response?['message'] ?? response.toString()}',
            onContinue: () => Navigator.pop(context),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Fermer loading
      showDialog(
        context: context,
        builder: (context) => SuccessMessage(
          message: 'Erreur lors de la demande de suppression :\n${e.toString()}',
          onContinue: () => Navigator.pop(context),
        ),
      );
    }
  }
}
