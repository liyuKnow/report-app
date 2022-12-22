import 'package:final_report/src/widgets/screens/home/users_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:final_report/src/data/models/models.dart';
import 'package:final_report/src/data/helper/db_helper.dart';
import 'package:final_report/src/widgets/screens/home/search_users.dart';

class AllUsersList extends StatefulWidget {
  const AllUsersList({super.key});

  @override
  State<AllUsersList> createState() => _AllUsersListState();
}

class _AllUsersListState extends State<AllUsersList> {
  late Future _allUsersList;

  Future _getAllUsers() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return await provider.fetchAllUsers();
  }

  @override
  void initState() {
    super.initState();
    _allUsersList = _getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _allUsersList,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: const [
                  SearchUsers(),
                  Expanded(child: UsersList()),
                ],
              ),
            );
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
