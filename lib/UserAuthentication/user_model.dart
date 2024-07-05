
class UserModel{
  final String? id;
  final String email;
  final String fullname;
  final String username;
  final String password;

  const UserModel({
   this.id,
    required this.email,
    required this.fullname,
    required this.username,
    required this.password,
});

  toJson(){
    return {
      "Email": email,
      "FullName": fullname,
      "UserName": username,
      "Password": password,
    };
  }
}