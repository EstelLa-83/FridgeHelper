import 'package:flutter/material.dart';
import 'package:fridge/model/member.dart';
import 'package:fridge/widget/fridge/food_card.dart';
import 'package:fridge/widget/fridge/fridge_appbar.dart';
import 'package:fridge/widget/fridge/fridge_divider.dart';
import 'package:fridge/controller/global.dart';
import 'package:fridge/controller/auth_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key,});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  final _unfocusNode = FocusNode();
  List<Member> memberList = [];
  late int familyId;
  late String familyName;

  Future<void> _loadFamilyNameFromServer() async {
    final token = await storage.read(key: 'accessToken');

    if (token == null) {
      print("Access token not found");
      return;
    }

    final response = await authenticatedRequest(
      context: context,
      url: Uri.parse("$BASE_URL/users/me"),
      method: "GET",
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      setState(() {
        familyId = data['familyGroupId'];
        familyName = data['familyGroupName'];
      });
    } 
    else {
      print("Failed to load familyInfo: ${response.statusCode}");
    }
  }

  Future<void> _loadFamilyFromServer() async {
    final token = await storage.read(key: 'accessToken');

    if (token == null) {
      print("Access token not found");
      return;
    }

    final response = await authenticatedRequest(
      context: context,
      url: Uri.parse("$BASE_URL/family-groups/members"),
      method: "GET",
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      final List<Member> fetchedMembers = data.map((item) {
        return Member(
          memberId: item['id'],
          memberName: item['name'],
        );
      }).toList();

      setState(() {
        memberList = fetchedMembers;
      });
    } 
    else {
      print("Failed to load family: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFamilyNameFromServer();
    _loadFamilyFromServer();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold();
  }
}
