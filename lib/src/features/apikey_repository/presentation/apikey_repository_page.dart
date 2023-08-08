import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:liquid_art_ai/src/features/connection/presentation/page/connection_page.dart';
import 'package:liquid_art_ai/src/features/drawer/presentation/pages/drawer_page.dart';
import 'package:liquid_art_ai/src/features/gallery/presentation/pages/galley_page.dart';
import 'package:liquid_art_ai/src/features/home/presentation/page/home_page.dart';
import 'package:liquid_art_ai/src/utils/user_configurations.dart';
import 'package:liquid_art_ai/src/widgets/liquid_art_button.dart';
import 'package:liquid_art_ai/src/widgets/liquid_art_text_field.dart';

import '../../connection/infrastructure/galaxy_cubit.dart';

class ApiKeyRepositoryPage extends StatefulWidget {
  const ApiKeyRepositoryPage({Key? key}) : super(key: key);

  @override
  State<ApiKeyRepositoryPage> createState() => _ApiKeyRepositoryPageState();
}

class _ApiKeyRepositoryPageState extends State<ApiKeyRepositoryPage> {
  late GalaxyCubit _galaxyCubit;

  var dallEController = TextEditingController();

  @override
  void initState() {
    _galaxyCubit = context.read<GalaxyCubit>();

    dallEController = TextEditingController(text: _galaxyCubit.state.dalleKey);

    super.initState();
  }

  popDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                    "Do you want to save those information's inside your device?", style: TextStyle(fontSize: 20),),
                const SizedBox(height: 20,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LiquidArtButton(
                      label: 'Save',
                      onTap: () async {
                        await UserConfigurations.setDallEKey(dallEController.text);
                      },
                    ),
                    const SizedBox(width: 10,),
                    LiquidArtButton(
                      label: 'Cancel',
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Services Keys",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              LiquidArtTextField(
                label: 'Dall-E API key',
                hintText: '',
                textController: dallEController,
                onChanged: (value) {
                  _galaxyCubit.dalleKeyChanged(value);
                },
              ),
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: LiquidArtButton(
                    label: 'Save Api keys',
                    onTap: popDialog,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: const Color(0xFF4C7BBF),
        children: [
          _buildSpeedDial(
              context,
              'Home Page',
              const Icon(
                Icons.home,
                color: Colors.white,
              ),
              const Color(0xFF4C7BBF), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }),
          _buildSpeedDial(
              context,
              'Connection Page',
              const Icon(
                Icons.cast_connected,
                color: Colors.white,
              ),
              const Color(0xFF4C7BBF), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ConnectionPage()),
            );
          }),
          _buildSpeedDial(
              context,
              'Drawer Page',
              const Icon(
                Icons.brush,
                color: Colors.white,
              ),
              const Color(0xFF4C7BBF), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DrawerPage()),
            );
          }),
          _buildSpeedDial(
              context,
              'Gallery Page',
              const Icon(
                Icons.image,
                color: Colors.white,
              ),
              const Color(0xFF4C7BBF), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const GalleryPage()),
            );
          }),
        ],
      ),
    );
  }
}

_buildSpeedDial(context, String label, Icon icon, Color backgroundColor,
    Function function) {
  return SpeedDialChild(
    label: label,
    child: icon,
    backgroundColor: backgroundColor,
    onTap: () {
      function();
    },
  );
}
