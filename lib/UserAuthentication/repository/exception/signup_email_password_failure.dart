class SignUpWithEmailAndPasswordFailure(){
  final String message;

  const SignUpWithEmailAndPasswordFailure([this.message = "An unknown error occured"]);

  factory SignUpWithEmailAndPasswordFailure.code(String code)
  {
    switch(code){
      case 'weak-password' : return const SignUpWithEmailAndPasswordFailure('Please Enter a Strong Code');
      case 'invalid-email' : return const SignUpWithEmailAndPasswordFailure('Email is not Valid or Bad Format');
      case 'email-already-in-use' : return const SignUpWithEmailAndPasswordFailure('An account already exit for that email');
      case 'operation-not-allowed' : return const SignUpWithEmailAndPasswordFailure('Operation is not allowed. Please contact support');
      case 'user-disabled' : return const SignUpWithEmailAndPasswordFailure('This user has been disable. Contact to Support Team');
      default : return const SignUpWithEmailAndPasswordFailure();
    }
  }
}