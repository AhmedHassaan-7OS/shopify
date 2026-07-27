import 'package:equatable/equatable.dart';

import 'json_reader.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
  });

  final String uid;
  final String name;
  final String phone;
  final String email;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'name': name,
    'phone': phone,
    'email': email,
  };

  factory AppUser.fromDoc(String uid, Map<String, dynamic>? data) {
    final json = JsonReader.asMap(data);
    return AppUser(
      uid: uid,
      name: JsonReader.string(json, 'name'),
      phone: JsonReader.string(json, 'phone'),
      email: JsonReader.string(json, 'email'),
    );
  }

  AppUser copyWith({String? uid, String? name, String? phone, String? email}) =>
      AppUser(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
      );

  @override
  List<Object?> get props => <Object?>[uid, name, phone, email];

  @override
  bool get stringify => true;
}
