import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/modules/ta2m_Chats_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Chats_screen/cubit/states.dart';

import '../../shared/style/my_flutter_app_icons.dart';

class NoMessageScreen extends StatelessWidget {
  const NoMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = ChatCubit.get(context);
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(

          body: Padding(
            padding:
            const EdgeInsets.only(top: 42, right: 42, left: 42, bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  MyFlutterApp.nomessagesicon,
                  color: Theme.of(context).primaryColor,
                  size: 200,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'No messages yet...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,fontSize: 25),
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Send the first message',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,fontSize: 16),
                      ),
                    ),

                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
