import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taqam/main.dart';
import 'package:taqam/modules/ta2m_Account_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Account_screen/cubit/states.dart';
import 'package:taqam/modules/ta2m_MyAds_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_chats_module/api/apis.dart';
import 'package:taqam/shared/maincubit/cubit.dart';
import 'package:taqam/shared/style/color.dart';
import 'package:taqam/shared/style/my_flutter_app_icons.dart';

import '../../shared/component/componanets.dart';
import '../ta2m_Home_screen/CustomDropdownFormField_screen.dart';
import '../ta2m_Login_screen/login_screen.dart';
import 'ConfirmImageProfile_screen.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

  final _firstNameFromController = TextEditingController();

  final _lastNameFromController = TextEditingController();

  final _townLocationController = TextEditingController();

  final _cityLocationFromController = TextEditingController();

  final _ageFromController = TextEditingController();

  final _heightFromController = TextEditingController();

  final _weightFromController = TextEditingController();

  final _phoneFromController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<String> genderList = ['Male', 'Female'];
    return BlocConsumer<AccountCubit, AccountState>(
      listener: (context, state) {
        if(state is ConnectivityErrorState){
          AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            headerAnimationLoop: false,
            dialogType: DialogType.error,
            showCloseIcon: true,
            title: 'Error',
            desc:
            'No internet connection',
            btnOkOnPress: () {
            },
            btnOkIcon: Icons.check_circle,
            onDismissCallback: (type) {
              debugPrint('Dialog Dissmiss from callback $type');
            },
            btnOkColor: ColorsManager.mainColor,
          ).show();
        }
        if (state is GetUserSuccessState) {
          AccountCubit.get(context).updateLastSeen();
        }
        if (state is SignOutSuccessState) {
          showToast(
              message: "Sign out successfully!", toast: ToastStates.Sucsess);
          AppCubit
              .get(context)
              .curentindex = 0;
          AccountCubit.get(context).profileImage = null;
          MyAdsCubit.get(context).allMyPosts.clear();
        }
        else if (state is SignOutErrorState) {
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
        else if(state is UpdateUserSuccessState){
          showToast(message: "The data has been saved successfully!", toast: ToastStates.Sucsess);
        }
      },
      builder: (context, state) {
        var cubit = AccountCubit.get(context);
        if(cubit.userModel != null){
          _firstNameFromController.text = cubit.userModel!.fName!;
          _lastNameFromController.text = cubit.userModel!.lName!;
          _townLocationController.text = cubit.userModel!.town!;
          _cityLocationFromController.text = cubit.userModel!.city!;
          _ageFromController.text = '${cubit.userModel!.age!}';
          _heightFromController.text = '${cubit.userModel!.height!}';
          _weightFromController.text = '${cubit.userModel!.weight!}';
          _phoneFromController.text = cubit.userModel!.phone!;
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorsManager.mainBackgroundColor,
            automaticallyImplyLeading: false,
            title: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text('Account Info',style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 24,fontWeight: FontWeight.bold),),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15,top: 15),
                child: IconButton(
                  onPressed: () async {
                    await updateActiveStatus(false);
                    cubit.SignOut(
                        key: "signed", context: context, widget: LoginScreen());
                  },
                  icon: Icon(
                    MyFlutterApp.vector,
                    color: Theme
                        .of(context)
                        .primaryColor,
                  ),
                ),
              ),
            ],
          ),
          body: ConditionalBuilder(
            condition: cubit.userModel != null,
            builder: (context){
              return Padding(
                padding: const EdgeInsets.only(
                  right: 20, top: 5, left: 20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: InkWell(
                                    onTap: () {
                                      // Action to perform on tap, e.g., open the image in a new screen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => cubit.profileImage != null
                                              ? Image.file(
                                            cubit.profileImage!,
                                            fit: BoxFit.cover,
                                          )
                                              : CachedNetworkImage(
                                            imageUrl: cubit.userModel!.image!,
                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      child: cubit.profileImage != null
                                          ? Image.file(
                                        cubit.profileImage!,
                                        fit: BoxFit.cover,
                                      )
                                          : CachedNetworkImage(
                                        imageUrl: cubit.userModel!.image!,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              child: IconButton(
                                onPressed: () async {
                                  await showOptionsDialog(context);
                                },
                                icon: Icon(
                                  Icons.camera_alt_rounded,
                                  color: Theme.of(context).primaryColor,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cubit.userModel!.email!,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            SizedBox(width: 4), // Add spacing between the icon and text
                            Text(
                              '${cubit.userModel!.NFollowers}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameFromController,
                                keyboardType: TextInputType.name,
                                style: TextStyle(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .secondary,
                                  fontSize: 20, // Set the desired font size
                                ),
                                decoration: InputDecoration(
                                  //hintText: 'From',
                                  labelText: 'First Name',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  hintStyle: TextStyle(
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 20),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme
                                            .of(context)
                                            .primaryColor), // Set the border color when focused
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Firstname must not be empty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: TextFormField(
                                style: TextStyle(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .secondary,
                                  fontSize: 20, // Set the desired font size
                                ),
                                controller: _lastNameFromController,
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  //hintText: 'Hossam',
                                  labelText: 'Last Name',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  hintStyle: TextStyle(
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 20),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme
                                            .of(context)
                                            .primaryColor), // Set the border color when focused
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lastname must not be empty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _townLocationController,
                                keyboardType: TextInputType.name,
                                style: TextStyle(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .secondary,
                                  fontSize: 20, // Set the desired font size
                                ),
                                decoration: InputDecoration(
                                  //hintText: 'From',
                                  labelText: 'Town',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  hintStyle: TextStyle(
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 20),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme
                                            .of(context)
                                            .primaryColor), // Set the border color when focused
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Town must not be empty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _cityLocationFromController,
                                keyboardType: TextInputType.name,
                                style: TextStyle(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .secondary,
                                  fontSize: 20, // Set the desired font size
                                ),
                                decoration: InputDecoration(
                                  //hintText: 'Hossam',
                                  labelText: 'City',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  hintStyle: TextStyle(
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 20),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme
                                            .of(context)
                                            .primaryColor), // Set the border color when focused
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'City must not be empty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Gender'),
                                  CustomDropdownFormField(
                                    itemList: genderList,
                                    selectedItem: cubit.userModel == null
                                        ? cubit.selectedItemGenderProfile
                                        : cubit.userModel!.gender == null
                                        ? cubit.selectedItemGenderProfile
                                        : cubit.userModel!.gender,
                                    onChanged: (item) {
                                      cubit.changeComboBoxGenderProfile(item!);
                                    },
                                    hintText: '',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _ageFromController,
                                keyboardType: TextInputType.name,
                                style: TextStyle(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .secondary,
                                  fontSize: 20, // Set the desired font size
                                ),
                                decoration: InputDecoration(
                                  //hintText: 'Hossam',
                                  labelText: 'Age',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  suffixText: ' Years',
                                  hintStyle: TextStyle(
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 20),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme
                                            .of(context)
                                            .primaryColor), // Set the border color when focused
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Age must not be empty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _heightFromController,
                                keyboardType: TextInputType.name,
                                style: TextStyle(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .secondary,
                                  fontSize: 20, // Set the desired font size
                                ),
                                decoration: InputDecoration(
                                  //hintText: 'From',
                                  labelText: 'Height',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  suffixText: ' cm',
                                  hintStyle: TextStyle(
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 20),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme
                                            .of(context)
                                            .primaryColor), // Set the border color when focused
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Height must not be empty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _weightFromController,
                                keyboardType: TextInputType.name,
                                style: TextStyle(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .secondary,
                                  fontSize: 20, // Set the desired font size
                                ),
                                decoration: InputDecoration(
                                  //hintText: 'Hossam',
                                  labelText: 'Weight',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  suffixText: ' kg',
                                  hintStyle: TextStyle(
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 20),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme
                                            .of(context)
                                            .primaryColor), // Set the border color when focused
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Weight must not be empty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: _phoneFromController,
                          keyboardType: TextInputType.name,
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .secondary,
                            fontSize: 20, // Set the desired font size
                          ),
                          decoration: InputDecoration(
                            //hintText: 'From',
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                            ),
                            hintStyle: TextStyle(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .secondary,
                                fontSize: 20),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme
                                      .of(context)
                                      .primaryColor), // Set the border color when focused
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'PhoneNumber must not be empty';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ConditionalBuilder(
                            condition: !(state is UpdateUserLoadingState || state is UploadProfileImageLoadingState),
                            builder: (context){return ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                    Theme
                                        .of(context)
                                        .primaryColor), // Change background color here
                                shape:
                                MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Adjust the value as needed
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                if (cubit.profileImage != null) {
                                  await cubit.uploadProfileImage();
                                  await updateProfilePicture(cubit.profileImage!);
                                }
                                await cubit.updateUser(
                                    fName: _firstNameFromController.text,
                                    lName: _lastNameFromController.text,
                                    town: _townLocationController.text,
                                    city: _cityLocationFromController.text,
                                    gender: cubit.selectedItemGenderProfile,
                                    age: int.parse(_ageFromController.text),
                                    height: double.parse(_heightFromController.text),
                                    weight: double.parse(_weightFromController.text),
                                    phone: _phoneFromController.text);
                                await MyAdsCubit.get(context).getAllMyPosts();
                                me.name = concatName(_firstNameFromController.text, _lastNameFromController.text);
                                await updateUserInfo();
                              },
                              child: const Text('Save',
                                  style: TextStyle(color: Colors.white, fontSize: 20)),
                            );},
                            fallback: (context) => Center(child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorsManager.mainColor,
                              ),
                            )),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            fallback: (context) => Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ColorsManager.mainColor,
              ),
            )),
          ),
        );
      },
    );
  }

  Future<void> showOptionsDialog(BuildContext context) {
    var cubit = AccountCubit.get(context);
    return showDialog(
      context: context,
      builder: (context) =>
          SimpleDialog(
            //alignment: const Alignment(0,0.7),
            children: [
              SimpleDialogOption(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  // Pick an image
                  final XFile? image = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 70);
                  if (image != null) {
                    cubit.profileImage = File(image.path);
                    Navaigateto(context, ConfirmImageProfileScreen());
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      color: Theme
                          .of(context)
                          .primaryColor,
                      size: 30,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(7.0),
                      child: Text(
                        'Camera',
                        //style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              SimpleDialogOption(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  // Pick an image
                  final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 70);
                  if (image != null) {
                    cubit.profileImage = File(image.path);
                    Navaigateto(context, ConfirmImageProfileScreen());
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.image,
                      color: Theme
                          .of(context)
                          .primaryColor,
                      size: 30,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(7.0),
                      child: Text(
                        'Gallery',
                        //style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}
