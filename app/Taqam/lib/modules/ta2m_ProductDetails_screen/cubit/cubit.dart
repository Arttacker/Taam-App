import 'dart:io';
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/modules/ta2m_ProductDetails_screen/cubit/states.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(IntialProductState());

  static ProductCubit get(context) {
    return BlocProvider.of(context);
  }

  bool sizeProductDetailsFlag=true;

  void changsizeProductDetailsFlag() {
    sizeProductDetailsFlag = !sizeProductDetailsFlag;
    emit(ChangSizeProductDetailsFlagSuccessStates());
  }




}

