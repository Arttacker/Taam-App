import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taqam/modules/ta2m_chats_module/api/apis.dart';
import 'package:taqam/shared/component/componanets.dart';
import 'package:taqam/shared/network/local/Cash_helper.dart';

import '../../../models/user/userModel.dart';
import '../../../shared/component/constans.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  static LoginCubit get(context) => BlocProvider.of(context);

  LoginCubit() : super(LoginInitial());
  bool showPassword = true;

  void changePasswordVisibility() {
    showPassword = !showPassword;
    emit(LoginPasswordVisibility(showPassword));
  }

  Future<void> UserLogin({
    required String email,
    required String password,
  }) async{
    emit(LoginLoadingState());
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async{
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        UidTokenSave = value.user!.uid;
        await getUserModel();
        if (await userExists()) {}
      else {
      await createUser();
      }
        emit(LoginSuccessState(value.user!.uid));
      } else {
        emit(VerifyEmailErrorState());
      }
    }).catchError((error) {
      emit(LoginErrorState(error.toString()));
    });
  }

  Future<void> signInWithGoogle() async {
    emit(GoogleSignInLoadingState()); // Emit loading state

    // Configure GoogleSignIn to prompt the user to select an account
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: scopes);

    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      emit(GoogleSignInErrorState(
          'Sign-in cancelled by user.')); // Emit error state if sign-in is cancelled
      return;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
    await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Attempt to sign in with the credential
    FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((UserCredential userCredential) async {
      // Check if the user's email is verified
      if (userCredential.user!.emailVerified) {
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid).collection('profile').doc(userCredential.user!.uid)
            .get();
        if (!(docSnapshot.exists)) {
          String? firstName;
          String? lastName;
          List<String> nameParts = userCredential.user!.displayName!.split(' ');
          firstName = nameParts[0];
          lastName = nameParts.sublist(1).join(' ');
          await UserCreate(
              uId: userCredential.user!.uid,
              email: userCredential.user!.email!,
              password: 'Password_123',
              fName: firstName,
              lName: lastName,
              image: '${userCredential.user!.photoURL}');
        }
        UidTokenSave = userCredential.user!.uid;
        emit(GoogleSignInSuccessState(userCredential.user!.uid));
      }
    }).catchError((error) {
      emit(GoogleSignInErrorState(
          error.toString()));
    });
  }


  Future UserCreate({
    required String uId,
    required String email,
    required String password,
    required String fName,
    required String lName,
    String? gender,
    String? image = 'https://img.freepik.com/free-psd/3d-illustration-person-with-sunglasses_23-2149436188.jpg?w=740&t=st=1710512872~exp=1710513472~hmac=969c5633c858adc36b4615ca6fd2a06209407d20d22b494a8b81c6752fee124f',
    int? age = 20,
    double? height = 170,
    double? weight = 60,
    int? NFollowers,
    String? phone,
    String? town,
    String? city,
    bool? isAdmin,
  })async{
    UserModel model = UserModel(
      userId: uId,
      fName: fName,
      lName: lName,
      email: email,
      password: password,
      registrationDate: Timestamp.now(),
      lastSeen: Timestamp.now(),
      gender: "Male",
      image: image,
      age: age,
      height: height,
      weight: weight,
      NFollowers: 0,
      phone: "unknown",
      town: "unknown",
      city: "unknown",
      isAdmin: false,
    );
    await FirebaseFirestore.instance.collection('users').doc(uId).set({});
    await FirebaseFirestore.instance.collection('users').doc(uId).collection('profile').doc(uId)
        .set(model.toMap())
        .then((value) {
      emit(UserCreateSuccessState());
    }).catchError((error) {
      emit(UserCreateErrorState(error.toString()));
    });
  }

  Future resetEmail({
    required String email,
  }) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((value){
      emit(ResetEmailSuccessState());
    }).catchError((error){
      emit(ResetEmailErrorState());
    });
  }

}

