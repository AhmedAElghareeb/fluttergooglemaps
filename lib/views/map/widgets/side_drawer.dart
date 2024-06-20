import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps/core/consts/colors.dart';
import 'package:google_maps/core/consts/strings.dart';
import 'package:google_maps/logic/phone_auth/phone_auth_cubit.dart';

// ignore: must_be_immutable
class SideDrawer extends StatelessWidget {
  SideDrawer({super.key});

  PhoneAuthCubit phoneAuthCubit = PhoneAuthCubit();

  Widget buildDrawerHeader(context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsetsDirectional.fromSTEB(
            70,
            10,
            70,
            10,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.blue[100],
          ),
          child: Image.network(
            "https://thimar.amr.aait-d.com/public/dashboardAssets/images/backgrounds/avatar.jpg",
            fit: BoxFit.cover,
          ),
        ),
        const Text(
          "User Name",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        BlocProvider<PhoneAuthCubit>(
            create: (context) => phoneAuthCubit,
            child: Text(
              '${phoneAuthCubit.getLoggedInUser().phoneNumber}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )),
      ],
    );
  }

  Widget buildDrawerListItem(
      {required IconData leadingIcon,
      required String title,
      Widget? trailing,
      Function()? onTap,
      Color? color}) {
    return ListTile(
      leading: Icon(
        leadingIcon,
        color: color ?? AppColors.blue,
      ),
      title: Text(
        title,
      ),
      trailing: trailing ??
          const Icon(
            Icons.arrow_right,
            color: AppColors.blue,
          ),
      onTap: onTap,
    );
  }

  Widget buildDrawerListItemsDivider() {
    return const Divider(
      height: 0,
      thickness: 1,
      indent: 18,
      endIndent: 24,
    );
  }

  Widget buildLogoutBlocProvider(context) {
    return BlocProvider<PhoneAuthCubit>(
      create: (context) => phoneAuthCubit,
      child: buildDrawerListItem(
        leadingIcon: Icons.logout,
        title: 'Log Out',
        onTap: () async {
          await phoneAuthCubit.logOut();
          Navigator.of(context).pushReplacementNamed(loginView);
        },
        color: Colors.red,
        trailing: const SizedBox(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 280,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[100],
              ),
              child: buildDrawerHeader(context),
            ),
          ),
          buildDrawerListItem(leadingIcon: Icons.person, title: "Profile"),
          buildDrawerListItemsDivider(),
          buildDrawerListItem(
              leadingIcon: Icons.history,
              title: "Places History",
              onTap: () {}),
          buildDrawerListItemsDivider(),
          buildDrawerListItem(leadingIcon: Icons.settings, title: "Settings"),
          buildDrawerListItemsDivider(),
          buildDrawerListItem(leadingIcon: Icons.help, title: "Help"),
          buildDrawerListItemsDivider(),
          buildLogoutBlocProvider(context),
          // buildDrawerListItem(leadingIcon: Icons.exit_to_app, title: "Log out"),
        ],
      ),
    );
  }
}
