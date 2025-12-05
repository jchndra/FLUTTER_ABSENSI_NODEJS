import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/member.dart';
import '../config.dart';

class MemberService {
  // Base URL for backend API (centralized)
  static const String _baseUrl = API_BASE_URL;

  Future<List<Member>> getMembers() async {
    final url = Uri.parse('$_baseUrl/members');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      return data
          .map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to fetch members: ${resp.statusCode}');
  }

  Future<Member> addMember(Member m) async {
    final url = Uri.parse('$_baseUrl/members');
    final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': m.id, 'name': m.name, 'photoUrl': m.photoUrl}));
    if (resp.statusCode == 201) {
      return Member.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to add member: ${resp.statusCode} ${resp.body}');
  }

  Future<void> deleteMember(String memberId) async {
    final url = Uri.parse('$_baseUrl/members/$memberId');
    final resp = await http.delete(url);
    if (resp.statusCode != 200) {
      throw Exception('Failed to delete member: ${resp.statusCode}');
    }
  }
}
