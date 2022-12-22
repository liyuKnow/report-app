import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:final_report/src/data/helper/db_helper.dart';
import 'package:final_report/src/data/models/models.dart';

class ConfirmBox extends StatelessWidget {
  final User user;
  const ConfirmBox({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return AlertDialog(
      title: Text('Delete ${user.firstName} ?'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // don't delete
            },
            child: const Text('Don\'t delete'),
          ),
          const SizedBox(width: 5.0),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              // on delete
              // provider.deleteExpense(user.id, user.firstName, user.lastName);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
