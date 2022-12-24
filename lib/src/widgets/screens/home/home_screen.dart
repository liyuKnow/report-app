import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as XLSIO;
import 'package:provider/provider.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import 'package:final_report/src/data/helper/db_helper.dart';
import 'package:final_report/src/data/models/models.dart';
import 'package:final_report/src/widgets/screens/home/all_users_list.dart';
import 'package:final_report/src/controllers/permissions_controller.dart';

enum MenuItems { import, export, sync }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    PermissionController.onStartUpPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report App"),
        actions: [
          popupActions(),
        ],
      ),
      body: const AllUsersList(),
    );
  }

  PopupMenuButton<MenuItems> popupActions() {
    return PopupMenuButton<MenuItems>(
      onSelected: (value) {
        if (value == MenuItems.import) {
          loadData();
        } else if (value == MenuItems.export) {
          _exportData();
        } else if (value == MenuItems.sync) {}
      },
      itemBuilder: ((context) => [
            PopupMenuItem(
              value: MenuItems.import,
              child: Row(
                children: const [
                  Icon(
                    Icons.download,
                    color: Colors.indigo,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text("Import Data"),
                ],
              ),
            ),
            PopupMenuItem(
              value: MenuItems.export,
              child: Row(
                children: const [
                  Icon(
                    Icons.upload,
                    color: Colors.indigo,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text("Export Data"),
                ],
              ),
            ),
            PopupMenuItem(
              value: MenuItems.sync,
              child: Row(
                children: const [
                  Icon(
                    Icons.import_export,
                    color: Colors.indigo,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text("Sync Data"),
                ],
              ),
            ),
          ]),
    );
  }

  loadData() async {
    try {
      // ^ CHECK PERMISSION
      PermissionController.requestManageStorage();

      // ^ GET FILE FROM DOWNLOADS
      final directory = Directory('/storage/emulated/0/Download/');
      const fileName = "usersDownload.xlsx";

      var file = File(directory.path + fileName);

      var isFile = await file.exists();

      if (isFile) {
        // ^ SAVE IT TO A LOCAL VARIABLE
        List<String> rowDetail = [];

        var excelBytes = File(file.path).readAsBytesSync();
        var excelDecoder =
            SpreadsheetDecoder.decodeBytes(excelBytes, update: true);

        for (var table in excelDecoder.tables.keys) {
          for (var row in excelDecoder.tables[table]!.rows) {
            rowDetail.add('$row'.replaceAll('[', '').replaceAll(']', ''));
          }
        }

        insertIntoDb(rowDetail);
      }
    } catch (e) {
      return e.toString();
    }
  }

  void insertIntoDb(rowDetail) {
    // TODO  : Get Database instance
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    // TODO  : delete previos data and reset db index
    try {
      provider.truncateTables();
    } catch (e) {}

    for (var i = 1; i < rowDetail.length; i++) {
      var data = rowDetail[i].split(',');

      try {
        User user = User(
          firstName: data[1],
          lastName: data[2],
          age: int.parse(data[5]),
          date: DateTime.now().toIso8601String(),
        );

        provider.addUser(user);
      } catch (e) {
        print(e);
      }
    }

    // TODO  : return to list with new data
    Navigator.pushNamed(context, '/');
  }

  Future<void> _exportData() async {
    // ^ export current database data to downloads folder
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    // Create a new Excel document.
    final XLSIO.Workbook workbook = XLSIO.Workbook();
    //Accessing worksheet via index.
    final XLSIO.Worksheet sheet = workbook.worksheets[0];

    // ADD THE HEADERS
    sheet.getRangeByName('A1').setText('FirstName');
    sheet.getRangeByName('B1').setText('LastName');
    sheet.getRangeByName('C1').setText('Updated');
    sheet.getRangeByName('D1').setText('Age');
    sheet.getRangeByName('E1').setText('Date');

    // GET ALL DATA FROM OBJECT BOX
    List<User> allUsers = await provider.fetchUsers();

    for (var i = 2; i < allUsers.length; i++) {
      sheet.getRangeByName('A$i').setText((allUsers[i].firstName).toString());
      sheet.getRangeByName('B$i').setText((allUsers[i].lastName).toString());
      sheet.getRangeByName('C$i').setText((allUsers[i].updated).toString());
      sheet.getRangeByName('D$i').setText((allUsers[i].age).toString());
      sheet.getRangeByName('E$i').setText((allUsers[i].date).toString());
    }

    final List<int> bytes = workbook.saveAsStream();

    final directory = Directory('/storage/emulated/0/Download/');
    const fileName = "GeneratedUsersDownload.xlsx";
    final file = File(directory.path + fileName);

    file.writeAsBytes(bytes);

    //Dispose the workbook.
    workbook.dispose();
  }
}
