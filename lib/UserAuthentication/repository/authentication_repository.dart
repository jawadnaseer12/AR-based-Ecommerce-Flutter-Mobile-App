import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:stitchhub_app/Dashboard/BuyerDashboard/buyerDashboard.dart';
import 'package:stitchhub_app/UserAuthentication/login.dart';
import 'package:stitchhub_app/UserAuthentication/repository/exception/signup_email_password_failure.dart';

class AuthenticationRepository extends GetxController{

  static AuthenticationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;

  @override
  void onReady(){
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user){
    user == null? Get.offAll(() => login()) : Get.offAll(() => buyerDashboard());
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    Try{
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      firebaseUser.value != null? Get.offAll(() => buyerDashboard()) : Get.offAll(() => login());
    } on FirebaseAuthException catch(e) {
      final ex = SignUpWithEmailAndPasswordFailure.code(e.code);
      print('FIREBASE AUTH EXCEPTION - ${ex.message}');
      throw ex;
    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    Try{
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(e) {
    } catch (_) {}
  }

  Future<void> logout() async => await _auth.signOut();

}