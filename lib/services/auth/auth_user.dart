import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  AuthUser();
  factory AuthUser.fromFirebase(User user) => AuthUser();
}
