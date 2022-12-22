// import 'package:flutter/material.dart';
// import 'package:final_report/src/controllers/files_controller.dart';

// enum MenuItems { import, export, sync }

// PopupMenuButton<MenuItems> popupActions() {
//   return PopupMenuButton<MenuItems>(
//       onSelected: (value) {
//         if (value == MenuItems.import) {
//           FilesController.loadData();
//         } else if (value == MenuItems.export) {
//           FilesController.loadData(); //  yellow comments
//         } else if (value == MenuItems.sync) {
//           FilesController.loadData();
//         }
//       },
//       itemBuilder: ((context) => [
//             PopupMenuItem(
//                 value: MenuItems.import,
//                 child: Row(
//                   children: const [
//                     Icon(
//                       Icons.download,
//                       color: Colors.indigo,
//                     ),
//                     SizedBox(
//                       width: 6,
//                     ),
//                     Text("Import Data"),
//                   ],
//                 )),
//             PopupMenuItem(
//                 value: MenuItems.export,
//                 child: Row(
//                   children: const [
//                     Icon(
//                       Icons.upload,
//                       color: Colors.indigo,
//                     ),
//                     SizedBox(
//                       width: 6,
//                     ),
//                     Text("Export Data"),
//                   ],
//                 )),
//             PopupMenuItem(
//                 value: MenuItems.sync,
//                 child: Row(
//                   children: const [
//                     Icon(
//                       Icons.import_export,
//                       color: Colors.indigo,
//                     ),
//                     SizedBox(
//                       width: 6,
//                     ),
//                     Text("Sync Data"),
//                   ],
//                 )),
//           ]));
// }
