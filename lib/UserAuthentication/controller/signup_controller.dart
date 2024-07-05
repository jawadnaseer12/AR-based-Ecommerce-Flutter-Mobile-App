import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:stitchhub_app/UserAuthentication/messageGenerated.dart';
// import 'package:stitchhub_app/UserAuthentication/repository/authentication_repository.dart';
// import 'package:stitchhub_app/UserAuthentication/repository/user_repository.dart';
// import 'package:stitchhub_app/UserAuthentication/user_model.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  final email = TextEditingController();
  final fullname = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();

  void registerUser(String email, String password)
  {
    // AuthenticationRepository.instance.createUserWithEmailAndPassword(email, password);
  }
  //
  // final userRepo = Get.put(UserRepository());
  //
  // Future<void> createUser(UserModel user) async {
  //   await userRepo.createUser(user);
  //   Get.to(() => const messageGenerated());
  // }

}