import '../models/auth_exceptions.dart';
import '../models/user.dart';
import 'email_normalizer.dart';
import 'password_hasher.dart';
import 'user_repository.dart';

class AuthService {
  AuthService(this._userRepository, this._passwordHasher);

  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  final UserRepository _userRepository;
  final PasswordHasher _passwordHasher;

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedName = name.trim();
    final normalizedEmail = normalizeEmail(email);

    if (normalizedName.isEmpty) {
      throw const AuthValidationException('Ingresa tu nombre.');
    }
    if (!_emailPattern.hasMatch(normalizedEmail)) {
      throw const AuthValidationException('Ingresa un correo válido.');
    }
    if (password.length < minPasswordLength) {
      throw const AuthValidationException(
        'La contraseña debe tener al menos 8 caracteres.',
      );
    }
    if (password.length > maxPasswordLength) {
      throw const AuthValidationException(
        'La contraseña no puede superar 128 caracteres.',
      );
    }

    final existing = await _userRepository.findByEmail(normalizedEmail);
    if (existing != null) {
      throw const EmailAlreadyRegisteredException();
    }

    final result = await _passwordHasher.hash(password);

    try {
      return await _userRepository.createUser(
        name: normalizedName,
        email: normalizedEmail,
        passwordHash: result.hash,
        passwordSalt: result.salt,
      );
    } on EmailAlreadyRegisteredException {
      throw const EmailAlreadyRegisteredException();
    }
  }

  Future<User> login({required String email, required String password}) async {
    final normalizedEmail = normalizeEmail(email);
    if (normalizedEmail.isEmpty || password.isEmpty) {
      throw const InvalidCredentialsException();
    }

    final credentials = await _userRepository.findCredentialsByEmail(
      normalizedEmail,
    );
    if (credentials == null) {
      throw const InvalidCredentialsException();
    }

    final valid = await _passwordHasher.verify(
      password: password,
      storedHash: credentials.passwordHash,
      storedSalt: credentials.passwordSalt,
    );
    if (!valid) {
      throw const InvalidCredentialsException();
    }

    return credentials.user;
  }
}
