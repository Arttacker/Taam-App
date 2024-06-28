import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:taqam/layout/ta2m_layout_screen/ta2m_Layout_screen.dart';
import 'package:taqam/modules/ta2m_Home_screen/Home_screen.dart';
import 'package:taqam/modules/ta2m_Home_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Home_screen/cubit/states.dart';
import 'package:taqam/shared/component/componanets.dart';

import '../../shared/style/color.dart';
import 'CustomDropdownFormField_screen.dart';

class FilterScreen extends StatefulWidget {
  FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List<String> categoryList = [
    'Top',
    'Other',
    'Hoodie',
    'Body',
    'Dress',
    'Polo',
    'Shorts',
    'Shirt',
    'Shoes',
    'Undershirt',
    'Skip',
    'Long Sleeve',
    'Blouse',
    'T-Shirt',
    'Pants',
    'Skirt',
    'Outwear',
    'Blazer',
    'Hat'
  ];

  List<String> genderList = ['male', 'female'];

  List<String> seasonList = ['summer', 'winter'];

  List<String> conditionList = ['New', 'Used'];

  List<String> sizeList = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  final _colorNameFromController = TextEditingController();

  final _priceFromController = TextEditingController();
  final _priceToController = TextEditingController();

  final _widthFromController = TextEditingController();
  final _widthToController = TextEditingController();

  final _heightFromController = TextEditingController();
  final _heightToController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var cubit = HomeCubit.get(context);
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorsManager.mainBackgroundColor,
            leading: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: IconButton(
                onPressed: () {
                  cubit.selectedItemCategoryFilter = null;
                  cubit.selectedItemGenderFilter = null;
                  cubit.selectedItemSeasonFilter = null;
                  cubit.selectedItemConditionFilter = null;
                  cubit.selectedItemSizeFilter = null;
                  cubit.selectedColorFilter = null;
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(
              right: 20,
              top: 20,
              left: 20,
              bottom: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomDropdownFormField(
                    itemList: categoryList,
                    selectedItem: cubit.selectedItemCategoryFilter,
                    onChanged: (item) {
                      cubit.changeComboBoxCategory(item!);
                    },
                    hintText: 'Category',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomDropdownFormField(
                    itemList: genderList,
                    selectedItem: cubit.selectedItemGenderFilter,
                    onChanged: (item) {
                      cubit.changeComboBoxGender(item!);
                    },
                    hintText: 'Gender',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomDropdownFormField(
                    itemList: seasonList,
                    selectedItem: cubit.selectedItemSeasonFilter,
                    onChanged: (item) {
                      cubit.changeComboBoxSeason(item!);
                    },
                    hintText: 'Season',
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  TextFormField(
                    controller: _colorNameFromController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Color Name',
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 20),
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
                        return 'Price must not be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  CustomDropdownFormField(
                    itemList: conditionList,
                    selectedItem: cubit.selectedItemConditionFilter,
                    onChanged: (item) {
                      cubit.changeComboBoxCondition(item!);
                    },
                    hintText: 'Condition',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomDropdownFormField(
                    itemList: sizeList,
                    selectedItem: cubit.selectedItemSizeFilter,
                    onChanged: (item) {
                      cubit.changeComboBoxSize(item!);
                    },
                    hintText: 'Size',
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    'Price',
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceFromController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'from',
                            hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20),
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
                              return 'Price must not be empty';
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
                          controller: _priceToController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'to',
                            hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20),
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
                              return 'Price must not be empty';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    'Width',
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _widthFromController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'from',
                            hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20),
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
                          controller: _widthToController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'to',
                            hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20),
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
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Height',
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightFromController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'from',
                            hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20),
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
                      const SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _heightToController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'to',
                            hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20),
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
                    height: 30,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ConditionalBuilder(
                      condition: !(state is ApplyFilterLoadingState),
                      builder: (context) => ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).primaryColor),
                          // Change background color here
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Adjust the value as needed
                            ),
                          ),
                        ),
                        onPressed: () {
                          cubit.filterPostAndUserModels(
                            size: cubit.selectedItemSizeFilter,
                            category: cubit.selectedItemCategoryFilter,
                            gender: cubit.selectedItemGenderFilter,
                            condition: cubit.selectedItemConditionFilter,
                            season: cubit.selectedItemSeasonFilter,
                            colorName: _colorNameFromController.text == ''
                                ? null
                                : _colorNameFromController.text,
                            minWidth: _widthFromController.text == ''
                                ? null
                                : double.parse(_widthFromController.text),
                            maxWidth: _widthToController.text == ''
                                ? null
                                : double.parse(_widthToController.text),
                            minHeight: _heightFromController.text == ''
                                ? null
                                : double.parse(_heightFromController.text),
                            maxHeight: _heightToController.text == ''
                                ? null
                                : double.parse(_heightToController.text),
                            minPrice: _priceFromController.text == ''
                                ? null
                                : double.parse(_priceFromController.text),
                            maxPrice: _priceToController.text == ''
                                ? null
                                : double.parse(_priceToController.text),
                          );
                          AwesomeDialog(
                            context: context,
                            animType: AnimType.leftSlide,
                            headerAnimationLoop: false,
                            dialogType: DialogType.success,
                            showCloseIcon: true,
                            title: 'Success',
                            desc: 'Filter Applied',
                            btnOkOnPress: () {
                              Navaigateto(context, Ta2mLayoutScreen());
                            },
                            btnOkIcon: Icons.check_circle,
                            onDismissCallback: (type) {
                              debugPrint('Dialog Dissmiss from callback $type');
                            },
                            btnOkColor: ColorsManager.mainColor,
                          ).show();
                        },
                        child: const Text('Apply',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                      fallback: (context) => Center(
                          child: CircularProgressIndicator(
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
    );
  }

  void _showColorPicker(context) {
    var cubit = HomeCubit.get(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: cubit.selectedColorFilter ?? Colors.black,
              onColorChanged: (val) {
                cubit.changeSelectedColorFilter(val);
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
