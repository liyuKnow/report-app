import 'package:final_report/src/widgets/screens/home/users_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_report/src/data/helper/db_helper.dart';

class UsersList extends StatelessWidget {
  const UsersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (_, db, __) {
        var list = db.users;
        return list.isNotEmpty
            ? ListView.builder(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                itemCount: list.length,
                itemBuilder: (_, i) => UsersCard(list[i]),
              )
            : const Center(
                child: Text('No Entries Found'),
              );
      },
    );
  }
}
