import 'package:flutter/material.dart';

abstract class AuthService {
  Future<bool> signInWithGithub(BuildContext context);

  String? user();
}
