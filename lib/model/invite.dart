class Invite {
  final int invitationId;
  final int fromFamilyGroupId;
  final String fromFamilyGroupName;
  final String inviterName;
  final int inviterId;

  Invite({
    required this.invitationId,
    required this.fromFamilyGroupId,
    required this.fromFamilyGroupName,
    required this.inviterName,
    required this.inviterId,
  });
}