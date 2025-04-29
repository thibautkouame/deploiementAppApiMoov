class User {
  final String? id;
  final String? f_name;
  final String? l_name;
  final String? email;
  final String? username;
  final String? password;  
  final String? sex;
  final String? age;
  final String? weight;
  final String? height;
  final String? actual_level;
  final String? daily_training_type;


  User({
    this.id,
    this.f_name,
    this.l_name,
    this.email,
    this.username,
    this.password,
    this.sex,
    this.age,
    this.weight,
    this.height,
    this.actual_level,
    this.daily_training_type,
  });

  static User fromJson(Map<String, dynamic> json) {
    // Si les données sont dans un objet 'user' imbriqué
    if (json.containsKey('user')) {
      final userData = json['user'];
      return User(
        id: userData['id']?.toString(),
        f_name: userData['f_name']?.toString(),
        l_name: userData['l_name']?.toString(),
        email: userData['email']?.toString(),
        username: userData['username']?.toString(),
        password: userData['password']?.toString(),
        sex: userData['sex']?.toString(),
        age: userData['age']?.toString(),
        weight: userData['weight']?.toString(),
        height: userData['height']?.toString(),
        actual_level: userData['actual_level']?.toString(),
        daily_training_type: userData['daily_training_type']?.toString(),
      );
    }
    
    // Si les données sont directement dans l'objet racine
    return User(
      id: json['id']?.toString(),
      f_name: json['f_name']?.toString(),
      l_name: json['l_name']?.toString(),
      email: json['email']?.toString(),
      username: json['username']?.toString(),
      password: json['password']?.toString(),
      sex: json['sex']?.toString(),
      age: json['age']?.toString(),
      weight: json['weight']?.toString(),
      height: json['height']?.toString(),
      actual_level: json['actual_level']?.toString(),
      daily_training_type: json['daily_training_type']?.toString(),
    );
  }
}
