import 'package:flutter/material.dart';
import 'package:taqam/shared/style/color.dart';

class CustomDropdownFormField extends StatefulWidget {
  final List<String> itemList;
  final String? selectedItem;
  final ValueChanged<String?>? onChanged;
  final String ? hintText;

  const CustomDropdownFormField({
    Key? key,
    required this.itemList,
    required this.selectedItem,
     this.hintText,
    this.onChanged,
  }) : super(key: key);

  @override
  _CustomDropdownFormFieldState createState() => _CustomDropdownFormFieldState();
}

class _CustomDropdownFormFieldState extends State<CustomDropdownFormField> {
  @override
  Widget build(BuildContext context) {
    String? _selectedItem = widget.selectedItem;


    if (_selectedItem == null && widget.itemList.isNotEmpty) {
      _selectedItem = widget.itemList.first;
    }
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      value: widget.hintText!=null?widget.selectedItem:widget.itemList.first,
      dropdownColor: Theme.of(context).primaryColor,
      isExpanded: true,
      iconSize: 30,
      isDense: true,
      focusColor: Theme.of(context).colorScheme.secondary,
      icon: const Icon(Icons.keyboard_arrow_down, color: ColorsManager.mainColor),
      hint: widget.hintText!=null?Text(
        widget.hintText!,
        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 20),
      ):null,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      items: widget.itemList
          .asMap()
          .entries
          .map((entry) => DropdownMenuItem(
        value: entry.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.value),
            if (entry.key != widget.itemList.length - 1)
              const SizedBox(
                height: 8,
              ),
            if (entry.key != widget.itemList.length - 1)
              SizedBox(
                width: double.infinity,
                height: 1,
                child: Container(
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ))
          .toList(),
      onChanged: widget.onChanged,
      selectedItemBuilder: (BuildContext context) {
        return widget.itemList.map<Widget>((String item) {
          return Text(
            item,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 20),
          );
        }).toList();
      },
    );
  }
}
