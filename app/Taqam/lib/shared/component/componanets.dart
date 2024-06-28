import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:taqam/shared/component/style.dart';
import 'package:taqam/shared/network/local/Cash_helper.dart';
import 'package:taqam/shared/style/color.dart';



String? UidTokenSave = CashHelper.getdata(key: 'uId');

Widget defaultbutton({
  double width = double.infinity,
  Color background = Colors.cyan,
  @required String? text,
  @required VoidCallback? function,
}) {
  return Container(
    width: width,
    color: background,
    child: MaterialButton(
      onPressed: function,
      child: Text(
        "$text",
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    ),
  );
}

Widget defaultTextForm({
  @required TextEditingController? textEditingController,
  @required TextInputType? type,
  bool obscureText = false,
  @required void Function(String? m)? onsubmit,
  void Function(String? m)? onchanged,
  void Function()? ontap,
  void Function()? suffux,
  @required String? text,
  @required IconData? prefix,
  IconData? suffix,
  @required String? Function(String? m)? validate,
  int? maxlength,
}) {
  return TextFormField(
    validator: validate,
    controller: textEditingController,
    keyboardType: type,
    obscureText: obscureText,
    onTap: ontap,
    onChanged: onchanged,
    maxLength: maxlength,
    onFieldSubmitted: onsubmit,
    decoration: InputDecoration(
      labelText: "${text}",
      counterText: "",
      border: const OutlineInputBorder(),
      prefixIcon: Icon(prefix),
      suffixIcon: suffix != null
          ? IconButton(onPressed: suffux, icon: Icon(suffix))
          : null,
    ),
  );
}

void showSnackBar({
  required BuildContext context,
  required String text,
  required Color color,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      backgroundColor: color,
      content: Text(
        text,
        textAlign: TextAlign.center,
      ),
    ),
  );
}

void Navaigateto(context, Widget) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Widget;
  }));
}

void Navaigatetofinsh(context, widget) {
  Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (context) => widget), (route) => false);
}

void showToast({@required String? message, @required ToastStates? toast}) {
  Fluttertoast.showToast(
      msg: '$message',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: choseColor(toast!),
      textColor: Colors.black,
      fontSize: 16.0,
  );
}

enum ToastStates { Sucsess, Erorr, Warning }

Color choseColor(ToastStates state1) {
  Color color;
  switch (state1) {
    case ToastStates.Sucsess:
      color = ColorsManager.mainColor;
      break;

    case ToastStates.Erorr:
      color = ColorsManager.mainBackgroundColor;
      break;

    case ToastStates.Warning:
      color = ColorsManager.warningColor;
      break;
  }
  return color;
}



Widget buildProfileItem(
        {@required title, required Widget shape, @required function}) =>
    Expanded(
      child: GestureDetector(
        onTap: function,
        child: Container(
          height: 140.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              15.0,
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 10,
                blurRadius: 15,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30.0,
                child: shape,
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                title.toString(),
                style: black16Bold(),
              ),
            ],
          ),
        ),
      ),
    );

String? colorToString(Color? color) {
  if(color == null){
    return null;
  }
  else{
    return color.value.toRadixString(16).padLeft(8, '0');
  }
}

String? colorToHexString(Color? color) {
  if (color == null) {
    return null;
  } else {
    String hex = color.value.toRadixString(16).padLeft(8, '0');
    return '#' + hex.substring(2); // Exclude the alpha component
  }
}

Color stringToColor(String colorString) {
  return Color(int.parse(colorString, radix: 16));
}

Color hexToColor(String hexColor) {
  // Remove '#' if it exists in the beginning of the string
  hexColor = hexColor.replaceAll("#", "");

  // Convert hexadecimal color code to integer
  int intValue = int.parse(hexColor, radix: 16);

  // Add alpha value (0xFF) to the integer color code
  intValue = 0xFF000000 + intValue;

  // Create and return Color object
  return Color(intValue);
}

String formatDate(Timestamp timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
  // Format date
  String formattedDate = DateFormat('MM/dd/yyyy').format(dateTime);
  return formattedDate;
}

String formatTime(Timestamp timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
  // Format time
  String formattedTime = DateFormat('hh:mm:ss a').format(dateTime);
  return formattedTime;
}

String concatName(String firstName, String lastName) {
  return '$firstName $lastName';
}

String extractPathFromUrl(String url) {
  // Find the index of 'o/' followed by '?alt=' in the URL
  int startIndex = url.indexOf('o/');
  int endIndex = url.indexOf('?alt=');

  if (startIndex != -1 && endIndex != -1) {
    // Extract the part of the URL between 'o/' and '?alt='
    String pathPart = url.substring(startIndex + 2, endIndex);

    // Decode any URL-encoded characters
    String decodedPath = Uri.decodeComponent(pathPart);

    return decodedPath;
  } else {
    // URL format is invalid
    return '';
  }
}
