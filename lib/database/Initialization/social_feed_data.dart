import 'package:cloud_firestore/cloud_firestore.dart';

import '../tables/user.dart';

/// Class for fetching data from firebase that is used for the social feed
/// Currently it is used for fetching users for search fields so they don't have to be stored locally
///
/// Later on it will also be used for fetching posts for the social feed
///

class SocialFeedData {
  Future<Map<String, dynamic>> fireBaseFetchUsersForSearch() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<LocalUser> users = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['userId'] = doc.id;

      // Ensure that fields expected to be int? are properly converted
      data['weight'] = (data['weight'] as num?)?.toInt();
      data['weightTarget'] = (data['weightTarget'] as num?)?.toInt();
      data['weightInitial'] = (data['weightInitial'] as num?)?.toInt();
      data['waterTarget'] = (data['waterTarget'] as num?)?.toInt();
      data['caloriesIntakeTarget'] =
          (data['caloriesIntakeTarget'] as num?)?.toInt();
      data['caloriesBurnedTarget'] =
          (data['caloriesBurnedTarget'] as num?)?.toInt();

      return LocalUser.fromMap(data);
    }).toList();

    return {
      'users': users,
    };
  }
}
