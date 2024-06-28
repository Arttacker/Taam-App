import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/modules/ta2m_Home_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Home_screen/cubit/states.dart';
import 'package:taqam/shared/style/color.dart';

import '../../layout/ta2m_layout_screen/ta2m_Layout_screen.dart';
import '../../shared/component/componanets.dart';

class SortByScreen extends StatelessWidget {
  const SortByScreen({super.key});

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
            padding:
                const EdgeInsets.only(right: 20, top: 20, left: 20,bottom: 20,),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildFilterItem(0, 'Most relevant',context),
                const SizedBox(height: 20),
                buildFilterItem(1, 'Newly listed',context),
                const SizedBox(height: 20),
                buildFilterItem(2, 'Lowest price',context),
                const SizedBox(height: 20),
                buildFilterItem(3, 'Highest Price',context),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor), // Change background color here
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Adjust the value as needed
                        ),
                      ),
                    ),
                    onPressed: (){
                      cubit.sortPosts(cubit.selectedSortByIndex);
                      AwesomeDialog(
                        context: context,
                        animType: AnimType.leftSlide,
                        headerAnimationLoop: false,
                        dialogType: DialogType.success,
                        showCloseIcon: true,
                        title: 'Success',
                        desc:
                        'Sort Successfully!',
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
                    child: const Text('Apply',style: TextStyle(color: Colors.white,fontSize: 20)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildFilterItem(int index, String title,context) {
    var cubit= HomeCubit.get(context);
    return InkWell(
      onTap: () {
        cubit.onSortBySelected(index);
      },
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                    fontSize: 20,
                  ),
                ),
              ),
              Visibility(
                visible: cubit.selectedSortByIndex == index,
                child: Icon(
                  Icons.check,
                  color: Theme.of(context).primaryColor,
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 2,
            child: Container(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

