import 'package:fridge/page/page_fridge_collection.dart';
import 'package:fridge/page/page_family.dart';
import 'package:fridge/page/page_setting.dart';
import 'package:fridge/controller/auth_service.dart';
import 'package:fridge/controller/global.dart';
import 'package:fridge/model/invite.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class Page {
  const Page(this.iconData, this.text);
  final IconData iconData;
  final String text;
}

class _MainPageState extends State<MainPage> {
  final Set<int> shownInvitationIds = {};
  Timer? _inviteChecker;
  int idx = 0;

  final pageList = const <Page>[
    Page(Icons.home_filled, "fridgeCollection"),
    Page(Icons.group, "family"),
    Page(Icons.person, "setting"),
  ];

  final _buildBody = <Widget>[
    FridgeCollectionPage(), 
    FamilyPage(),
    SettingPage(),
  ];

  void _startInvitePolling() {
    if (_inviteChecker != null) return;
    _inviteChecker = Timer.periodic(Duration(seconds: 15), (_) {
      _checkInvites();
    });
  }

  Future<void> _checkInvites() async {
    if (!mounted) return;

    final response = await authenticatedRequest(
      context: context,
      url: Uri.parse("$BASE_URL/invites"),
      method: "GET",
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      final invites = data.map((item) {
        return Invite(
          invitationId: item['invitationId'],
          fromFamilyGroupId: item['fromFamilyGroupId'],
          fromFamilyGroupName: item['fromFamilyGroupName'],
          inviterName: item['inviterName'],  
          inviterId: item['inviterEmail'],        
        );
      });

      for (final invite in invites) {
        if (!shownInvitationIds.contains(invite.invitationId)) {
          shownInvitationIds.add(invite.invitationId);
          _showInviteDialog(invite);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (onServer) {
      _checkInvites();
      _startInvitePolling();
    }
    else {
      _setTmpValue();
    }
  }

  @override
  void dispose() {
    _inviteChecker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: idx,
        onTap: (x) {
          if (!mounted) return;
          setState(() {
            idx = x;
          });
        },
        elevation: 20.0,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        unselectedItemColor: Colors.black,
        selectedItemColor: const Color(0xff395BA9),
        items:
            pageList
                .map(
                  (Page page) => BottomNavigationBarItem(
                    backgroundColor: Colors.white,
                    icon: Icon(page.iconData),
                    label: page.text,
                  ),
                )
                .toList(),
      ),
      body: _buildBody[idx],
    );
  }

  void _showInviteDialog(Invite invite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Family Invitation"),
        content: Text(
          "${invite.inviterName}(${invite.inviterId}) \ninvited you \nto join '${invite.fromFamilyGroupName}'",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final response = await authenticatedRequest(
                context: context, 
                url: Uri.parse('$BASE_URL/invites/${invite.invitationId}/decline'), 
                method: 'POST',
                body: {},
              );

              if (response.statusCode == 200) {
                print('Declined the invitation.');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Declined the invitation.')),
                );
                Navigator.pop(context);
              }
              else {
                print('failed to decline the invitation: ${response.statusCode}');
              }
            },
            child: const Text("Decline"),
          ),
          ElevatedButton(
            onPressed: () async {
              final response = await authenticatedRequest(
                context: context, 
                url: Uri.parse('$BASE_URL/users/me'), 
                method: 'GET',
              );

              if (response.statusCode != 200) {
                print('Invalid User');
              }
              else {
                final data = jsonDecode(utf8.decode(response.bodyBytes));
                
                final String familyName = data['familyGroupName'];

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Notice'),
                    content: Text(
                      'If you get accept an invitation, \n your existing family ${familyName} will disappear. \n Is that okay?',
                      softWrap: true,
                      maxLines: null,
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
                          final response = await authenticatedRequest(
                            context: context, 
                            url: Uri.parse('$BASE_URL/invites/${invite.invitationId}/accept'), 
                            method: 'POST',
                            body: {},
                          );

                          if (response.statusCode == 200) {
                            print('Joined the group');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Joined ${invite.fromFamilyGroupName}!')),
                            );
                            Navigator.pop(context);
                            if (Navigator.canPop(context)) Navigator.pop(context);
                          }
                          else {
                            print("Failed to join the group: ${response.statusCode}");
                          }
                        },
                        child: const Text('Join'),
                      )
                    ],
                  ),
                );
              }
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _setTmpValue() {
    idx = 0;
  }
}
