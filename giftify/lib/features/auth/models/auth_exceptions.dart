class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class EmailAlreadyRegisteredException extends AuthException {
  const EmailAlreadyRegisteredException()
    : super('Ya existe una cuenta con este correo.');
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
    : super('Correo o contraseña incorrectos.');
}

class AuthStorageException extends AuthException {
  const AuthStorageException()
    : super('No pudimos completar la operación. Intenta nuevamente.');
}

class AuthValidationException extends AuthException {
  const AuthValidationException(super.message);
}
