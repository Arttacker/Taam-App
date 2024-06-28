import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/modules/ta2m_Login_screen/login_screen.dart';
import 'package:taqam/modules/ta2m_Register_screen/register_cubit/register_cubit.dart';
import 'package:taqam/shared/style/color.dart';

import '../../shared/component/componanets.dart';
import '../../shared/network/local/Cash_helper.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();

  RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var cubit = RegisterCubit.get(context);
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if(state is UserCreateSuccessState){
          AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            headerAnimationLoop: false,
            dialogType: DialogType.success,
            showCloseIcon: true,
            title: 'Success',
            desc:
            'Registration successfully, Please verify your email and log in',
            btnOkOnPress: () async {
              CashHelper.putbool(key: 'onboarding', value: true)
                  .then((value) {
                Navaigatetofinsh(
                    context, LoginScreen());
              });
            },
            btnOkIcon: Icons.check_circle,
            onDismissCallback: (type) {
              debugPrint('Dialog Dissmiss from callback $type');
            },
            btnOkColor: ColorsManager.mainColor,
          ).show();
        }
        else if(state is UserCreateErrorState){
          AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            headerAnimationLoop: false,
            dialogType: DialogType.error,
            showCloseIcon: true,
            title: 'Error',
            desc:
            state.error,
            btnOkOnPress: () {
            },
            btnOkIcon: Icons.check_circle,
            onDismissCallback: (type) {
              debugPrint('Dialog Dissmiss from callback $type');
            },
            btnOkColor: ColorsManager.mainColor,
          ).show();
        }
        else if(state is RegisterErrorState){
          AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            headerAnimationLoop: false,
            dialogType: DialogType.error,
            showCloseIcon: true,
            title: 'Error',
            desc:
            state.error,
            btnOkOnPress: () {
            },
            btnOkIcon: Icons.check_circle,
            onDismissCallback: (type) {
              debugPrint('Dialog Dissmiss from callback $type');
            },
            btnOkColor: ColorsManager.mainColor,
          ).show();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorsManager.mainBackgroundColor,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                    const EdgeInsets.only(right: 20,left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PERSONAL DETAILS',
                          style: TextStyle(fontSize: 24),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              // border: Border.all(
                              //   color: ColorsManager.mainColor,
                              //   width: 1.0,
                              // ),
                              color: ColorsManager.mainBackgroundColor),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .white), // Set the border color to white
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorsManager.mainColor), // Set the border color when focused
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email must not be empty';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              // border: Border.all(
                              //   color: ColorsManager.mainColor,
                              //   width: 1.0,
                              // ),
                              color: ColorsManager.mainBackgroundColor),
                          child: TextFormField(
                            controller: _passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: cubit.showPassword,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .white), // Set the border color to white
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorsManager.mainColor), // Set the border color when focused
                              ),
                              suffixIcon: GestureDetector(
                                child: Icon(
                                  cubit.showPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: ColorsManager.mainColor,
                                ),
                                onTap: () {
                                  cubit.changePasswordVisibility();
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Password must not be empty';
                              }
                              // Check for uppercase letters
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return 'Password should contain at least one uppercase letter';
                              }

                              // Check for numbers
                              if (!RegExp(r'\d').hasMatch(value)) {
                                return 'Password should contain at least one number';
                              }

                              // Check minimum length
                              if (value.length < 8) {
                                return 'Password should be at least 8 characters long';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              // border: Border.all(
                              //   color: ColorsManager.mainColor,
                              //   width: 1.0,
                              // ),
                              color: ColorsManager.mainBackgroundColor),
                          child: TextFormField(
                            controller: _firstNameController,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              hintText: 'First Name',
                              hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorsManager.mainColor),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'First Name must not be empty';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              // border: Border.all(
                              //   color: ColorsManager.mainColor,
                              //   width: 1.0,
                              // ),
                              color: ColorsManager.mainBackgroundColor),
                          child: TextFormField(
                            controller: _lastNameController,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              hintText: 'Last Name',
                              hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorsManager.mainColor),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Last Name must not be empty';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'An email will be sent to verify your account.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () {
                                cubit.changeCheckBox();
                              },
                              icon: cubit.checkBox
                                  ? Icon(
                                Icons
                                    .check_box_outline_blank_outlined,
                                color: ColorsManager.mainColor,
                              )
                                  : Icon(
                                Icons.check_box,
                                color: ColorsManager.mainColor,
                              ),
                              padding: const EdgeInsets.all(0),
                              alignment: Alignment.centerLeft,
                            ),
                            Expanded(
                              child: const Text(
                                'I accept the terms of use',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ConditionalBuilder(
                          condition: !(state is RegisterLoadingState),
                          builder: (context){return ElevatedButton(
                              onPressed: () async{
                                if (_formKey.currentState!.validate()) {
                                  if (!cubit.checkBox) {
                                    await cubit.UserRegister(email: _emailController.text, password: _passwordController.text, fName: _firstNameController.text, lName: _lastNameController.text);
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Please accept the terms of use'),
                                        backgroundColor:
                                        ColorsManager.mainColor,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ), backgroundColor: ColorsManager.mainColor,
                                // Use the primary color from the current theme
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                'REGISTER',
                                style: TextStyle(fontSize: 24),
                              ));},
                          fallback: (context) => Center(child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ColorsManager.mainColor,
                            ),
                          )),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}