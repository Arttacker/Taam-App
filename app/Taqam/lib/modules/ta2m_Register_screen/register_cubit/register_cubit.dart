import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/user/userModel.dart';
part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());
  static RegisterCubit get(context) => BlocProvider.of(context);

  bool showPassword = true;
  void changePasswordVisibility() {
    showPassword = !showPassword;
    emit(RegisterPasswordVisibility(showPassword));
  }

  bool checkBox = true;
  void changeCheckBox() {
    checkBox = !checkBox;
    emit(CheckBoxSuccess());
  }
  // Firebase (Register)
  Future UserRegister({
    required String email,
    required String password,
    required String fName,
    required String lName,
  }) async{
    emit(RegisterLoadingState());

    FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, password: password).then((value) async{
      await UserCreate(email: email,password: password,fName: fName,lName: lName,uId: value.user!.uid);
      FirebaseAuth.instance.currentUser!.sendEmailVerification().then((value){
        emit(RegisterSuccessState());
      }).catchError((error){
        emit(RegisterErrorState(error.toString()));
      });
    }).catchError((error) {
      emit(RegisterErrorState(error.toString()));
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
}
