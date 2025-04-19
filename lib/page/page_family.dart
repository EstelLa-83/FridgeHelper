import 'package:flutter/material.dart';
import 'package:fridge/model/member.dart';
import 'package:fridge/widget/family/member_card.dart';
import 'package:fridge/controller/global.dart';
import 'package:fridge/controller/auth_service.dart';
import 'dart:convert';

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key,});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  final _unfocusNode = FocusNode();
  List<Member> memberList = [];
  late int myId;
  late String myName;
  late int familyId;
  late String familyName;

  Future<void> _loadInfoFromServer() async {
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
        myId = data['userId'];
        myName = data['userName'];
        familyId = data['familyGroupId'];
        familyName = data['familyGroupName'];
      });
    } 
    else {
      print("Failed to load familyInfo: ${response.statusCode}");
    }
  }

  Future<void> _loadFamilyFromServer() async {
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
          memberProfile: item['profile'],
        );
      }).toList();

      fetchedMembers.sort((a, b) {
        if (a.memberId == myId) return -1;
        if (b.memberId == myId) return 1;
        return 0;
      });

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
    _loadInfoFromServer();
    _loadFamilyFromServer();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(familyName),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: memberList.length,
                itemBuilder: (context, index) {
                  final member = memberList[index];
                  return MemberCard(
                    name: member.memberName,
                    profile: member.memberProfile,
                    isMe: member.memberId == myId,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: SizedBox(
                width: 230.0,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () {
                    _showInviteDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Invite Family Members',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Leave from family"),
        content: const Text("Are you sure about leaving from family?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final response = await authenticatedRequest(
                context: context,
                url: Uri.parse("$BASE_URL/family-groups/leave"),
                method: "DELETE",
              );
              
              if (response.statusCode == 204) {
                _loadFamilyFromServer();
                Navigator.pop(context);
              } 
              else {
                print("Failed to leave from family: ${response.statusCode}");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to leave from family")),
                );
              }
            },
            child: const Text("Leave", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    final TextEditingController _idController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Invitation for ...'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'ID: ',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            controller: _idController,
                            decoration: const InputDecoration(labelText: 'ID'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final id = _idController.text.trim();
                    if (id.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter an ID')),
                      );

                      return;
                    } 

                    final response = await authenticatedRequest(
                      context: context, 
                      url: Uri.parse('$BASE_URL/users/$id'), 
                      method: 'GET',
                    );

                    if (response.statusCode != 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please check an ID')),
                      );
                    }
                    else {
                      final data = jsonDecode(utf8.decode(response.bodyBytes));
                      
                      final String resultName = data['userName'];

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Invitation'),
                          content: Text('Would you like to invite $resultName($id) ?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final id = _idController.text.trim();

                                if (id.isNotEmpty) {
                                  final response = await authenticatedRequest(
                                    context: context, 
                                    url: Uri.parse('$BASE_URL/invites'), 
                                    method: 'POST',
                                    body: {
                                      "email": id,
                                    },
                                  );

                                  if (response.statusCode == 200) {
                                    print('Inviting $id');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Invitation was successful.')),
                                    );
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  }
                                  else {
                                    print("Failed to send an invitation: ${response.statusCode}");
                                  }
                                }
                              },
                              child: const Text('Ok'),
                            )
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Send'),
                ),
              ],
            );
          }
        );      
      },
    );
  }  
}
