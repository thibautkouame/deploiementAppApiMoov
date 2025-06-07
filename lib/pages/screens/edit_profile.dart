import 'package:fitness/pages/screens/home_screen.dart';
import 'package:fitness/widgets/success_message.dart';
import 'package:flutter/material.dart';
import 'package:fitness/models/user.dart';
import 'package:fitness/services/auth_service.dart';
import 'package:fitness/theme/theme.dart';
import 'package:fitness/pages/screens/profile_screen.dart';
import 'package:fitness/pages/welcome.dart';
import 'package:fitness/pages/loginsignup.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();

  bool _loading = false;
  User? _user;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() {
          _error = 'Token manquant';
          _loading = false;
        });
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginSignupPage()),
            (route) => false,
          );
        }
        return;
      }
      final user = await AuthService().getUserInfo(token);
      setState(() {
        _user = user;
        _usernameController.text = user.username ?? '';
        _ageController.text = user.age ?? '';
        _weightController.text = user.weight ?? '';
        _heightController.text = user.height ?? '';
        _sexController.text = user.sex ?? '';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      if (e.toString().contains('Token invalide') || e.toString().contains('401')) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginSignupPage()),
            (route) => false,
          );
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _user == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Token manquant');
      final updatedUser = await AuthService().updateProfile(
        token: token,
        firstName: _user!.f_name ?? '',
        lastName: _user!.l_name ?? '',
        email: _user!.email ?? '',
        username: _usernameController.text,
        sex: _sexController.text,
        age: _ageController.text,
        weight: _weightController.text,
        height: _heightController.text,
        actual_level: _user!.actual_level ?? '',
        daily_training_type: _user!.daily_training_type ?? '',
      );
      setState(() {
        _user = updatedUser;
        _loading = false;
      });
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SuccessMessage(
              message: 'Modifications effectuées avec succès.',
              onContinue: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomeScreen()),
                );
              },
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          ),
        ),
        title: const Text('Modification du profil'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _user == null
                  ? const Center(child: Text('Aucune donnée'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Nom d\'Utilisateur',
                                labelStyle: TextStyle(color: Colors.black),
                                suffixIcon: Icon(Icons.edit),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.primary),
                                ),
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Champ requis'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _ageController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Âge',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                    ),
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Champ requis'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _weightController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Poids',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      suffixText: 'Kg',
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.edit),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                    ),
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Champ requis'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _heightController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Taille(cm)',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      suffixText: 'cm',
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                    ),
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Champ requis'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _sexController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Sexe',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.edit),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                    ),
                                    onTap: () async {
                                      final sex = await showDialog<String>(
                                        context: context,
                                        builder: (ctx) => SimpleDialog(
                                          title: const Text(
                                              'Sélectionnez le sexe'),
                                          children: [
                                            SimpleDialogOption(
                                              child: const Text('Femme'),
                                              onPressed: () =>
                                                  Navigator.pop(ctx, 'Femme'),
                                            ),
                                            SimpleDialogOption(
                                              child: const Text('Homme'),
                                              onPressed: () =>
                                                  Navigator.pop(ctx, 'Homme'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (sex != null)
                                        _sexController.text = sex;
                                    },
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Champ requis'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _loading ? null : _saveProfile,
                              child: const Text('ENREGISTRER'),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _sexController.dispose();
    super.dispose();
  }
}
