import 'package:flutter/material.dart';
import 'package:fridge/model/member.dart';
import 'package:fridge/widget/family/family_member_card.dart';
import 'package:fridge/widget/family/family_appbar.dart';
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
    if (onServer) {
      _loadInfoFromServer();
      _loadFamilyFromServer();
    }
    else {
      _setTmpValue(); 
    }
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
        child: Column(
          children: [
            FamilyAppBar(
              familyName: familyName, 
              onRename: () => _showRenameDialog(context)),
            const SizedBox(height: 10.0),
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
              padding: const EdgeInsets.only(bottom: 15.0),
              child: SizedBox(
                width: 280.0,
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
                    'Invite new Family Members',
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

  void _showRenameDialog(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rename to ...'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Family name'),
                      ),
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
                    final name = _nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a Family name')),
                      );

                      return;
                    } 

                    final response = await authenticatedRequest(
                      context: context, 
                      url: Uri.parse('$BASE_URL/family-groups/name'), 
                      method: 'PUT',
                      body: {
                        "name": name,
                      },
                    );

                    if (response.statusCode != 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please check a Family name')),
                      );
                    }
                    
                    if (response.statusCode == 200) {
                      setState(() {
                        familyName = name;
                      });

                      print('Rename to $name');
                      Navigator.pop(context);
                    }
                    else {
                      print("Failed to rename: ${response.statusCode}");
                    }
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          }
        );      
      },
    );
  }    


  void _showLeaveDialog(BuildContext context) async {
    showDialog(
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

  void _setTmpValue() {
    myId = 0;
    myName = 'Alice';
    familyId = 0;
    familyName = "Alice's family";
    memberList = [
      Member(memberId: 0, memberName: 'Alice', memberProfile: 'profile_1'),
      Member(memberId: 1, memberName: 'Bob', memberProfile: 'profile_2'),
      Member(memberId: 2, memberName: 'Charlie', memberProfile: 'profile_3'),
    ];
  }
}
