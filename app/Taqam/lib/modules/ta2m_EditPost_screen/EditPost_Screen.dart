import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colornames/colornames.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taqam/models/posture/postModel.dart';
import 'package:taqam/modules/ta2m_EditPost_screen/ConfirmImageUpdated_edit_screen.dart';
import 'package:taqam/modules/ta2m_EditPost_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_EditPost_screen/cubit/states.dart';
import 'package:taqam/modules/ta2m_MyAds_screen/cubit/cubit.dart';

import '../../layout/ta2m_layout_screen/ta2m_Layout_screen.dart';
import '../../shared/component/componanets.dart';
import '../../shared/style/color.dart';
import '../ta2m_Home_screen/CustomDropdownFormField_screen.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel postModel;
  final int index;
  EditPostScreen(this.postModel,this.index);
  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
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
    _widthFromController.text = '${widget.postModel.productWidth}';
    _heightToController.text = '${widget.postModel.productHeight}';
    _descriptionToController.text = '${widget.postModel.description}';
    _priceToController.text = '${widget.postModel.price}';

    return BlocConsumer<EditPostCubit, EditPostState>(
      listener: (context, state) {
        if(state is EditPostConnectivityErrorState){
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
        if(state is EditPostSuccessState){
          showToast(message: "The data has been saved successfully!", toast: ToastStates.Sucsess);
        }
      },
      builder: (context, state) {
        var cubit = EditPostCubit.get(context);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorsManager.mainBackgroundColor,
            leading: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: IconButton(
                onPressed: () {
                  cubit.editPostImage=null;
                  cubit.selectedColorEdit=null;
                  Navaigatetofinsh(context, const Ta2mLayoutScreen());
                },
                icon: Icon(Icons.close, color: Theme
                    .of(context)
                    .primaryColor, size: 30,),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(right: 30, left: 30,bottom: 30),
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
                        children: [cubit.editPostImage != null ? Image.file(
                          cubit.editPostImage!,
                          fit: BoxFit.fill,
                          height: 278,
                          width: double.infinity,
                        ) :
                          CachedNetworkImage(
                            imageUrl: widget.postModel.image!,
                            fit: BoxFit.fill,
                            height: 278,
                            width: double.infinity,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ColorsManager.mainColor,
                                ),
                              ),
                            ), // Placeholder widget while loading
                            errorWidget: (context, url, error) => Icon(Icons.error), // Widget to display when image fails to load
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: ColorsManager.mainBackgroundColor,
                              border: Border.all(
                                width: 2.0, // Border width
                                color: ColorsManager.mainColor,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(35.0)),
                            ),
                            child: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      SimpleDialog(
                                        alignment: const Alignment(0, 0.8),
                                        children: [
                                          SimpleDialogOption(
                                            onPressed: () async {
                                              final ImagePicker picker = ImagePicker();
                                              // Pick an image
                                              final XFile? image = await picker.pickImage(
                                                  source: ImageSource.camera, imageQuality: 50);
                                              if (image != null) {
                                                cubit.editPostImage = File(image.path);
                                                Navaigateto(context, ConfirmImageUpdatedScreen_Edit(widget.postModel,widget.index));
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.camera_alt_rounded,
                                                  color: Theme
                                                      .of(context)
                                                      .primaryColor, size: 30,),
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
                                              final ImagePicker picker = ImagePicker();
                                              // Pick an image
                                              final XFile? image = await picker.pickImage(
                                                  source: ImageSource.gallery, imageQuality: 50);
                                              if (image != null) {
                                                cubit.editPostImage = File(image.path);
                                                Navaigateto(context, ConfirmImageUpdatedScreen_Edit(widget.postModel,widget.index));
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.image, color: Theme
                                                    .of(context)
                                                    .primaryColor, size: 30,),
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
                  Text('Category'),
                  CustomDropdownFormField(
                    hintText: widget.postModel.category,
                    itemList: categoryList,
                    selectedItem: widget.postModel.category,
                    onChanged: (item) {
                      widget.postModel.category = item;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text('Gender'),
                  CustomDropdownFormField(
                    hintText: widget.postModel.gender,
                    itemList: genderList,
                    selectedItem: widget.postModel.gender,
                    onChanged: (item) {
                      widget.postModel.gender = item;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text('Season'),
                  CustomDropdownFormField(
                    hintText: widget.postModel.season,
                    itemList: seasonList,
                    selectedItem: widget.postModel.season,
                    onChanged: (item) {
                      widget.postModel.season = item;
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
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .secondary,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Text(
                              '${cubit.selectedColorEdit != null? ColorNames.guess(cubit.selectedColorEdit!):widget.postModel.coloredName!}',
                              style: TextStyle(
                                color:
                                cubit.selectedColorEdit != null ?cubit.selectedColorEdit: hexToColor(widget.postModel.color!),
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              color: cubit.selectedColorEdit != null ?cubit.selectedColorEdit: hexToColor(widget.postModel.color!),
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
                  Text('Condition'),
                  CustomDropdownFormField(
                    hintText: widget.postModel.condition,
                    itemList: conditionList,
                    selectedItem: widget.postModel.condition,
                    onChanged: (item) {
                      widget.postModel.condition = item;
                    },

                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text('Size'),
                  CustomDropdownFormField(
                    hintText: widget.postModel.size,
                    itemList: sizeList,
                    selectedItem: widget.postModel.size,
                    onChanged: (item) {
                      widget.postModel.size = item;
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
                          style: TextStyle(color: Theme
                              .of(context)
                              .colorScheme
                              .secondary),
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
                              borderSide: BorderSide(
                                  color: Colors
                                      .white),
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
                              return 'Width must not be empty';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 30,),
                      Expanded(
                        child: TextFormField(
                          controller: _heightToController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Theme
                              .of(context)
                              .colorScheme
                              .secondary),
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
                              borderSide: BorderSide(
                                  color: Colors
                                      .white),
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
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(color: Theme
                              .of(context)
                              .colorScheme
                              .secondary, fontSize: 18),
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
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors
                                      .white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Theme
                                      .of(context)
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
                          style: TextStyle(color: Theme
                              .of(context)
                              .colorScheme
                              .secondary, fontSize: 20),
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
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors
                                      .white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Theme
                                      .of(context)
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
                      condition: !(state is EditPostLoadingState || state is UploadPostImageLoadingState),
                      builder: (context) {
                        return ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Theme
                                    .of(context)
                                    .primaryColor),
                            // Change background color here
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Adjust the value as needed
                              ),
                            ),
                          ),
                          onPressed: () async{
                            if (cubit.editPostImage != null){
                              await cubit.putSaveImageToUpdatedPost(cubit.editPostImageUrl!);
                              await cubit.deleteImagePostUpdated(image: widget.postModel.image!);
                            }
                            await cubit.editPost(postId: widget.postModel.postId!, userId: widget.postModel.userId!, price: double.parse(_priceToController.text), color: widget.postModel.color!, image: cubit.editPostImageUrl == null ? widget.postModel.image! : cubit.editPostImageUrl!, season: widget.postModel.season!, postDate: widget.postModel.postDate!, condition: widget.postModel.condition!, gender: widget.postModel.gender!, isSold: widget.postModel.isSold!, category: widget.postModel.category!, productHeight: double.parse(_heightToController.text), productWidth: double.parse(_widthFromController.text), size: widget.postModel.size!, description: _descriptionToController.text,coloredName: widget.postModel.coloredName!);
                            cubit.editPostImage = null;
                            cubit.selectedColorEdit=null;
                            MyAdsCubit.get(context).allMyPosts.removeAt(widget.index);
                            MyAdsCubit.get(context).allMyPosts.insert(0, cubit.postModel!);
                            Navaigatetofinsh(context, const Ta2mLayoutScreen());
                          },
                          child: const Text('Edit', style: TextStyle(
                              color: Colors.white, fontSize: 20)),
                        );
                      },
                      fallback: (context) =>
                          Center(child: CircularProgressIndicator(
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
    var cubit = EditPostCubit.get(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: cubit.selectedColorEdit ?? Colors.black,
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
                if(cubit.selectedColorEdit!=null){
                  widget.postModel.color = colorToHexString(cubit.selectedColorEdit!);
                }
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
