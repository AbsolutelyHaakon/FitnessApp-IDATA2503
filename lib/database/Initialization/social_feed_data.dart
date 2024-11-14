
import 'package:cloud_firestore/cloud_firestore.dart';

import '../tables/user.dart';

/// Class for fetching data from firebase that is used for the social feed
/// Currently it is used for fetching users for search fields so they don't have to be stored locally
/// 
/// Later on it will also be used for fetching posts for the social feed
/// 
/// Last edited: 14.11.2024
/// Last edited by: Håkon Svensen Karlsen

class SocialFeedData {

  // TODO: Change this to search for people with @ tags in their name when they are implemented
  Future <Map<String, dynamic>> fireBaseFetchUsersForSearch() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users').get();

    List<LocalUser> users = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['userId'] = doc.id;
      return LocalUser.fromMap(data);
    }).toList();

    return {
      'users': users,
    };
  }

}