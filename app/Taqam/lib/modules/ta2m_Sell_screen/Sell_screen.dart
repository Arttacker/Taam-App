import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colornames/colornames.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taqam/modules/ta2m_Account_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Home_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_MyAds_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Sell_screen/ConfirmImageUpdated_sell_screen.dart';
import 'package:taqam/modules/ta2m_Sell_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Sell_screen/cubit/states.dart';

import '../../layout/ta2m_layout_screen/ta2m_Layout_screen.dart';
import '../../models/structModels/post_and_user/post_and_userModel.dart';
import '../../shared/component/componanets.dart';
import '../../shared/style/color.dart';
import '../ta2m_Home_screen/CustomDropdownFormField_screen.dart';

class SellScreen extends StatefulWidget {
  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  List<String> categoryList = ['Top', 'Other', 'Hoodie', 'Body', 'Dress', 'Polo', 'Shorts', 'Shirt', 'Shoes', 'Undershirt',
    'Skip', 'Long Sleeve', 'Blouse', 'T-Shirt', 'Pants', 'Skirt', 'Outwear', 'Blazer', 'Hat'];

  List<String> genderList = ['male', 'female'];

  List<String> seasonList = ['summer', 'winter'];

  List<String> conditionList = ['New', 'Used'];

  List<String> sizeList = ['XS',  'S',  'M', 'L', 'XL', 'XXL'];

  final _widthFromController = TextEditingController();

  final _heightToController = TextEditingController();

  final _descriptionToController = TextEditingController();

  final _priceToController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var cubit = SellCubit.get(context);
    var homeCubit = HomeCubit.get(context);
    if (homeCubit.isFetchProcessImageToSell == true) {
      cubit.selectedItemCategory = homeCubit.categoryToSell;
      cubit.selectedItemGender = homeCubit.genderToSell;
      cubit.selectedItemSeason = homeCubit.seasonToSell;
      cubit.selectedItemSize = homeCubit.sizeToSell;
      cubit.selectedColorSell = homeCubit.colorToSell == null ? null : hexToColor(homeCubit.colorToSell!);
      _widthFromController.text = homeCubit.widthToSell.toString();
      _heightToController.text = homeCubit.heightToSell.toString();
    } else {
      _widthFromController.text = '42';
      _heightToController.text = '58';
    }
    _descriptionToController.text = (homeCubit.categoryToSell==null || homeCubit.colorToSell==null)?'Top category':'${ColorNames.guess(cubit.selectedColorSell??Colors.black)} ${homeCubit.categoryToSell} ';
    _priceToController.text = '100';

    return BlocConsumer<SellCubit, SellState>(
      listener: (context, state) {
        if (state is SellConnectivityErrorState) {
          AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            headerAnimationLoop: false,
            dialogType: DialogType.error,
            showCloseIcon: true,
            title: 'Error',
            desc: 'No internet connection',
            btnOkOnPress: () {},
            btnOkIcon: Icons.check_circle,
            onDismissCallback: (type) {
              debugPrint('Dialog Dissmiss from callback $type');
            },
            btnOkColor: ColorsManager.mainColor,
          ).show();
        }
        if (state is CreateNewPostSuccessState) {
          cubit.postId++;
          showToast(
              message: "Apply post successfully!", toast: ToastStates.Sucsess);
        }
      },
      builder: (context, state) {
        var cubit = SellCubit.get(context);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorsManager.mainBackgroundColor,
            leading: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: IconButton(
                onPressed: () async {
                  if(cubit.sellImage!=null){
                    await cubit.deleteImagePostSell(image: cubit.sellImageUrl!);
                  }
                  Navaigatetofinsh(context, const Ta2mLayoutScreen());
                },
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(
                top: 30, right: 30, left: 30
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 278,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          cubit.sellImage != null
                              ? Image.file(
                                  cubit.sellImage!,
                                  fit: BoxFit.fill,
                                  height: 278,
                                  width: double.infinity,
                                )
                              : Image.asset(
                                  'assets/images/Men Solid Crew Neck Tee 2.png',
                                  fit: BoxFit.fill,
                                  height: 278,
                                  width: double.infinity,
                                ),
                          Container(
                            decoration: BoxDecoration(
                              color: ColorsManager.mainBackgroundColor,
                              border: Border.all(
                                width: 2.0, // Border width
                                color: ColorsManager.mainColor,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(35.0)),
                            ),
                            child: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => SimpleDialog(
                                    alignment: const Alignment(0, 0.8),
                                    children: [
                                      SimpleDialogOption(
                                        onPressed: () async {
                                          final ImagePicker picker =
                                              ImagePicker();
                                          // Pick an image
                                          final XFile? image =
                                              await picker.pickImage(
                                                  source: ImageSource.camera,
                                                  imageQuality: 50);
                                          if (image != null) {
                                            cubit.sellImage = File(image.path);
                                            Navaigateto(context,
                                                ConfirmImageUpdatedScreen());
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.camera_alt_rounded,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: 30,
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.all(7.0),
                                              child: Text(
                                                'Camera',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(),
                                      SimpleDialogOption(
                                        onPressed: () async {
                                          final ImagePicker picker =
                                              ImagePicker();
                                          // Pick an image
                                          final XFile? image =
                                              await picker.pickImage(
                                                  source: ImageSource.gallery,
                                                  imageQuality: 50);
                                          if (image != null) {
                                            cubit.sellImage = File(image.path);
                                            Navaigateto(context,
                                                ConfirmImageUpdatedScreen());
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.image,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: 30,
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.all(7.0),
                                              child: Text(
                                                'Gallery',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: Center(
                                child: Icon(
                                  Icons.add,
                                  color: ColorsManager.mainColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  // Text(
                  //   'Category',
                  // ),
                  CustomDropdownFormField(
                    hintText: cubit.selectedItemCategory??'Category',
                    itemList: categoryList,
                    selectedItem: cubit.selectedItemCategory,
                    onChanged: (item) {
                      cubit.changeComboBoxCategory(item!);
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Text(
                  //   'Gender',
                  // ),
                  CustomDropdownFormField(
                    hintText: cubit.selectedItemGender??'Gender',
                    itemList: genderList,
                    selectedItem: cubit.selectedItemGender,
                    onChanged: (item) {
                      cubit.changeComboBoxGender(item!);
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Text(
                  //   'Season',
                  // ),
                  CustomDropdownFormField(
                    hintText: cubit.selectedItemSeason??'Season',
                    itemList: seasonList,
                    selectedItem: cubit.selectedItemSeason,
                    onChanged: (item) {
                      cubit.changeComboBoxSeason(item!);
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      _showColorPicker(context); // Show color picker on tap
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Color',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Text(
                              '${ColorNames.guess(cubit.selectedColorSell??Colors.black)}',
                              style: TextStyle(
                                color:
                                cubit.selectedColorSell??Colors.black,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              color: cubit.selectedColorSell ?? Colors.black,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 1,
                          child: Container(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Text(
                  //   'Condition',
                  // ),
                  CustomDropdownFormField(
                    hintText: cubit.selectedItemCondition??'Condition',
                    itemList: conditionList,
                    selectedItem: cubit.selectedItemCondition,
                    onChanged: (item) {
                      cubit.changeComboBoxCondition(item!);
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Text(
                  //   'Size',
                  // ),
                  CustomDropdownFormField(
                    hintText: cubit.selectedItemSize??'Size',
                    itemList: sizeList,
                    selectedItem: cubit.selectedItemSize,
                    onChanged: (item) {
                      cubit.changeComboBoxSize(item!);
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                          controller: _widthFromController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Width',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            // hintStyle: TextStyle(
                            //     color: Theme.of(context)
                            //         .colorScheme
                            //         .secondary,fontSize: 20),
                            suffixText: 'cm',
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .primaryColor), // Set the border color when focused
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Width must not be empty';
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
                          controller: _heightToController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                          decoration: InputDecoration(
                            labelText: 'Height',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            // hintStyle: TextStyle(
                            //     color: Theme.of(context)
                            //         .colorScheme
                            //         .secondary,fontSize: 20),
                            suffixText: 'cm',
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
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
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 18),
                          controller: _descriptionToController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            // hintStyle: TextStyle(
                            //     color: Theme.of(context)
                            //         .colorScheme
                            //         .secondary,fontSize: 20),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(width: 2, color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Theme.of(context)
                                      .primaryColor), // Set the border color when focused
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Description must not be empty';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 20),
                          controller: _priceToController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            // hintText: 'Price',
                            labelText: 'Price',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            // hintStyle: TextStyle(
                            //     color: Theme.of(context)
                            //         .colorScheme
                            //         .secondary,fontSize: 20),
                            suffixText: 'EGP',
                            enabledBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(width: 2, color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Theme.of(context)
                                      .primaryColor), // Set the border color when focused
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Price must not be empty';
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
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ConditionalBuilder(
                      condition: !(state is UploadSellImageLoadingState),
                      builder: (context) {
                        return ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).primaryColor),
                            // Change background color here
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Adjust the value as needed
                              ),
                            ),
                          ),
                          onPressed: () async {
                            if (cubit.sellImage == null) {
                              AwesomeDialog(
                                context: context,
                                animType: AnimType.leftSlide,
                                headerAnimationLoop: false,
                                dialogType: DialogType.error,
                                showCloseIcon: true,
                                title: 'Error',
                                desc:
                                    'Please select an image from your gallery or camera.',
                                btnOkOnPress: () {},
                                btnOkIcon: Icons.check_circle,
                                onDismissCallback: (type) {
                                  debugPrint(
                                      'Dialog Dissmiss from callback $type');
                                },
                                btnOkColor: ColorsManager.mainColor,
                              ).show();
                            } else {
                              await cubit.createNewPost(
                                  postId: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  userId: UidTokenSave!,
                                  price: double.parse(_priceToController.text),
                                  color:
                                  cubit.selectedColorSell == null ? "#000000" : colorToString(cubit.selectedColorSell!)!,
                                  image: cubit.sellImageUrl!,
                                  season: cubit.selectedItemSeason!,
                                  postDate: Timestamp.now(),
                                  condition: cubit.selectedItemCondition!,
                                  gender: cubit.selectedItemGender!,
                                  isSold: false,
                                  category: cubit.selectedItemCategory!,
                                  productHeight:
                                      double.parse(_heightToController.text),
                                  productWidth:
                                      double.parse(_widthFromController.text),
                                  size: cubit.selectedItemSize!,
                                  description: _descriptionToController.text,
                                  colorName: cubit.selectedColorSell == null ? "Black" : ColorNames.guess(cubit.selectedColorSell!),
                              );
                              HomeCubit.get(context)
                                  .allPostsWithThemUsers
                                  .insert(
                                      0,
                                      PostAndUserModel(
                                          userModel: AccountCubit.get(context)
                                              .userModel,
                                          postModel: cubit.postModel!));
                              MyAdsCubit.get(context).getAllMyPosts();
                              await HomeCubit.get(context).putSaveImageToSellPost(cubit.sellImageUrl!);
                              Navaigatetofinsh(
                                  context, const Ta2mLayoutScreen());
                            }
                          },
                          child: const Text('Apply',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                        );
                      },
                      fallback: (context) => Center(
                          child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ColorsManager.mainColor,
                        ),
                      )),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showColorPicker(context) {
    var cubit = SellCubit.get(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: cubit.selectedColorSell ?? Colors.black,
              onColorChanged: (val) {
                cubit.changeSelectedColorSell(val);
              },
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: true,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsv,
              pickerAreaBorderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2.0),
                topRight: Radius.circular(2.0),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
