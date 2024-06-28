import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:taqam/modules/ta2m_Home_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_MyAds_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Sell_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_chats_module/api/apis.dart';
import 'package:taqam/shared/maincubit/cubit.dart';
import 'package:taqam/shared/style/color.dart';
import '../../layout/ta2m_layout_screen/ta2m_Layout_screen.dart';
import '../../shared/component/componanets.dart';
import '../../shared/network/local/Cash_helper.dart';
import '../ta2m_Account_screen/cubit/cubit.dart';
import '../ta2m_Register_screen/register_screen.dart';
import 'forgetPassword_screen.dart';
import 'login_cubit/login_cubit.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var cubit = LoginCubit.get(context);
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if(state is LoginSuccessState){
          showToast(message: "Login successfully!", toast: ToastStates.Sucsess);
          // AppCubit.get(context).getAllUsers();
          // HomeCubit.get(context).getAllPosts();
          AccountCubit.get(context).getUserData();
          // SellCubit.get(context).getNumberOfPosts();
          // MyAdsCubit.get(context).f();
          CashHelper.putbool(key: 'signed', value: true)
              .then((value) {
            CashHelper.savedata(key: 'uId', value: state.uId);
            Navaigatetofinsh(
                context, const Ta2mLayoutScreen());
          });
        }
        else if(state is GoogleSignInSuccessState){
          AccountCubit.get(context).getUserData();
          showToast(message: "Login With Google successfully!", toast: ToastStates.Sucsess);
          CashHelper.putbool(key: 'signed', value: true)
              .then((value) {
            CashHelper.savedata(key: 'uId', value: state.uId);
            Navaigatetofinsh(
                context, const Ta2mLayoutScreen());
          });
          CashHelper.putbool(key: 'isLoginWithGoogle', value: true);
        }
        else if(state is VerifyEmailErrorState){
          AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            headerAnimationLoop: false,
            dialogType: DialogType.error,
            showCloseIcon: true,
            title: 'Error',
            desc:
            'Please verify your email and log in',
            btnOkOnPress: () {
            },
            btnOkIcon: Icons.check_circle,
            onDismissCallback: (type) {
              debugPrint('Dialog Dissmiss from callback $type');
            },
            btnOkColor: ColorsManager.mainColor,
          ).show();
        }
        else if(state is LoginErrorState){
          AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            headerAnimationLoop: false,
            dialogType: DialogType.error,
            showCloseIcon: true,
            title: 'Error',
            desc:
            "Invalid email or password.",
            btnOkOnPress: () {
            },
            btnOkIcon: Icons.check_circle,
            onDismissCallback: (type) {
              debugPrint('Dialog Dissmiss from callback $type');
            },
            btnOkColor: ColorsManager.mainColor,
          ).show();
        }
        else if(state is GoogleSignInErrorState){
          AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            headerAnimationLoop: false,
            dialogType: DialogType.error,
            showCloseIcon: true,
            title: 'Error',
            desc:
            "Google sign in failed, Please check connectivity or try again.",
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
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SIGN IN TO YOUR ACCOUNT',
                          style: TextStyle(fontSize: 25),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 30,
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
                                  color: Theme.of(context).colorScheme.secondary),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
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
                          height: 40,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: ColorsManager.mainBackgroundColor),
                          child: TextFormField(
                            controller: _passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: cubit.showPassword,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              suffixIcon: GestureDetector(
                                child: Icon(
                                  cubit.showPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Theme.of(context).primaryColor,
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

                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextButton(
                          onPressed: () {
                            Navaigateto(context, ForgetPasswordScreen());
                          },
                          child: Text(
                            'Forget your password?',
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ConditionalBuilder(
                          condition: !(state is LoginLoadingState),
                          builder: (context){return ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  cubit.UserLogin(email: _emailController.text,
                                      password: _passwordController.text);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
                                // Use the primary color from the current theme
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(fontSize: 24),
                              ));},
                          fallback: (context) => Center(child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          )),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ConditionalBuilder(
                          condition: !(state is GoogleSignInLoadingState),
                          builder: (context){return ElevatedButton(
                            onPressed: () async {
                              cubit.signInWithGoogle();
                              if(await userExists()){
                              }
                              else{
                                await createUser();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                              // Use the primary color from the current theme
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              // Center the icon and text
                              children: <Widget>[
                                // Optional: Add some space between the icon and the text
                                const Text(
                                  'Login With Google',
                                  style: TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 10),
                                Image.asset('assets/images/google.png', width: 20, height: 20),
                              ],
                            ),
                          );},
                          fallback: (context) => Center(child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          )),
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        Row(
                          children: [
                            const Expanded(
                                child: Text(
                              'Don\'t have an account?',
                              style: TextStyle(fontSize: 16),
                            )),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Navaigateto(context, RegisterScreen());
                                },
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ],
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
