import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taqam/modules/ta2m_Search_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Search_screen/cubit/states.dart';
import 'package:taqam/shared/maincubit/cubit.dart';
import 'package:taqam/shared/style/color.dart';

import '../../layout/ta2m_layout_screen/ta2m_Layout_screen.dart';
import '../../shared/component/componanets.dart';
import '../../shared/maincubit/states.dart';

import 'ConfirmImageFromSearch_screen.dart';
import 'ProductsSearch_screen.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var cubit = SearchCubit.get(context);
    cubit.searchImage=null;
    cubit.searchImageUrl='';
  }
  final _formKey = GlobalKey<FormState>();

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var cubit = SearchCubit.get(context);
    return BlocConsumer<SearchCubit, SearchState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorsManager.mainBackgroundColor,
            leading: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: IconButton(
                onPressed: () {
                  Navaigateto(context, const Ta2mLayoutScreen());
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text('Search',style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 30,fontWeight: FontWeight.bold),),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
                padding: const EdgeInsets.only(right: 15, top: 10, left: 15,bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(
                                maxHeight: 100),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: ColorsManager.mainColor,
                                  width: 1.0,
                                ),

                                color: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextFormField(
                                controller: _searchController,
                                keyboardType: TextInputType.emailAddress,
                                maxLines: null,

                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    onPressed: () async {
                                      await showOptionsDialog(context);
                                    },
                                    icon: Icon(Icons.camera_alt_rounded,color: Theme.of(context).primaryColor,size: 30,),
                                  ),
                                  hintText: 'Type Something...',
                                  hintStyle: TextStyle(
                                      color: Theme.of(context).colorScheme.secondary),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors
                                            .white), // Set the border color to white
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .primaryColor), // Set the border color when focused
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Search must not be empty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8,),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                              onPressed: (){
                                if(_formKey.currentState!.validate()){
                                  Navaigateto(context,  ProductsSearchScreen());
                                }
                              },
                              icon: const Icon(Icons.send,color: Colors.white,)
                          ),
                        )
                      ],
                    )
                  ],
                )),
          ),
        );
      },
    );
  }

  Future<void>showOptionsDialog(BuildContext context) {
    var cubit= SearchCubit.get(context);
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        //alignment: const Alignment(0,0.7),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              cubit.searchImage=null;
              final ImagePicker picker = ImagePicker();
              // Pick an image
              final XFile? image = await picker.pickImage(
                  source: ImageSource.camera, imageQuality: 70);
              if (image != null) {
                cubit.searchImage = File(image.path);
                Navaigateto(context, ConfirmImageFromSearchScreen());
              }
              else{
              }
            },
            child: Row(
              children: [
                Icon(Icons.camera_alt_rounded,color: Theme.of(context).primaryColor,size: 30,),
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
              cubit.searchImage=null;
              final ImagePicker picker = ImagePicker();
              // Pick an image
              final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery, imageQuality: 70);
              if (image != null) {
                cubit.searchImage = File(image.path);
                Navaigateto(context, ConfirmImageFromSearchScreen());
              }
              else{
              }
            },
            child: Row(
              children: [
                Icon(Icons.image,color: Theme.of(context).primaryColor,size: 30,),
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