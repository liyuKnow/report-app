import 'package:final_report/src/data/models/user.dart';
import 'package:final_report/src/widgets/screens/home/confirm_box.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UsersCard extends StatelessWidget {
  final User user;
  const UsersCard(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey(user.id),
      onTap: (() {
        // Navigator.pushNamed(context, '/qr_screen', arguments: user.id);
        Navigator.pushNamed(context, '/edit_user', arguments: user.id);
      }),
      child: ListTile(
        title: Text("${user.firstName} ${user.lastName} id = ${user.id}"),
        subtitle: Text(
            "${DateFormat('MMMM dd, yyyy').format(DateTime.parse(user.date))}, Updated = ${user.updated}"),
        trailing: const Padding(
            padding: EdgeInsets.all(2.0), child: Icon(Icons.qr_code_scanner)),
      ),
    );
  }
}
