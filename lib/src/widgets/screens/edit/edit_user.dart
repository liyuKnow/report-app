import 'package:final_report/src/controllers/permissions_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:final_report/src/data/helper/db_helper.dart';
import 'package:final_report/src/data/models/models.dart';
import 'package:final_report/src/widgets/screens/edit/custom_form_feild.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key, required this.userId});

  final int userId;
  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late User? user;

  final _userFirstNameController = TextEditingController();
  final _userLastNameController = TextEditingController();

  bool _validateFirstName = false;
  bool _validateLastName = false;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    try {
      user = await Provider.of<DatabaseProvider>(context, listen: false)
          .getUserById(widget.userId);
      // FILL USER DETAILS TO INPUTS
      _userFirstNameController.text = user!.firstName;
      _userLastNameController.text = user!.lastName;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _userFirstNameController.dispose();
    _userLastNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Update user"),
      ),
      body: SingleChildScrollView(
          child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomFormField(
                  controller: _userFirstNameController,
                  txtLabel: "First Name",
                ),
                CustomFormField(
                  controller: _userLastNameController,
                  txtLabel: "Last Name",
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue[300],
                          textStyle: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400)),
                      onPressed: () {
                        editUser();
                        Navigator.pushNamed(context, '/');
                      },
                      child: const Text(
                        'Update User',
                        style: TextStyle(fontSize: 16),
                      ))
                ])
              ],
            ),
          ),
        ),
      )),
    );
  }

  void editUser() async {
    final isValid = _formKey.currentState?.validate();

    if (isValid != null && isValid) {
      User updateUser = user!;

      updateUser.firstName = _userFirstNameController.text;
      updateUser.lastName = _userLastNameController.text;
      updateUser.updated = true;

      // Update User
      await Provider.of<DatabaseProvider>(context, listen: false)
          .updateUser(updateUser);

      // Set location data
      // Update User

      try {
        PermissionController.requestLocation();

        var location = Location();
        var loc = await location.getLocation();

        UpdateLocation updateLocation = UpdateLocation(
          lat: loc.latitude.toString(),
          long: loc.longitude.toString(),
          userId: user?.id,
        );

        await Provider.of<DatabaseProvider>(context, listen: false)
            .addUpdateLocation(updateLocation);
        print("Lat : ${updateLocation.lat}");
      } catch (e) {
        print(e.toString());
      }

      print(" User Data : ${user?.firstName}");
      print(" User Data : ${user?.lastName}");
      print(" User Data : ${user?.age}");
      print(" User Data : ${user?.date}");
      print(" User Data : ${user?.id}");
      print(" User Data : ${user?.updated}");
      print("Everything seems fine!");
    }
  }
}
