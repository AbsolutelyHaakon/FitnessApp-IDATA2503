import 'package:fitnessapp_idata2503/database/user.dart';
import 'package:fitnessapp_idata2503/database/user_dao.dart';
import 'package:fitnessapp_idata2503/database/user_weight_data.dart';
import 'package:fitnessapp_idata2503/database/user_weight_data_dao.dart';


// THIS IS PURELY AI GENERATED AND ONLY USED FOR TESTING PURPOSES
// DO NOT PUBLISH THIS CODE IN A RELEASE!


class DummyData {
  final UserDao userDao = UserDao();
  final UserWeightDataDao userWeightDataDao = UserWeightDataDao();

  Future<void> insertDummyUsers() async {
    List<User> users = [
      User(name: 'John Doe', email: 'john@example.com', password: 'password123', weight: 70),
      User(name: 'Jane Smith', email: 'jane@example.com', password: 'password123', weight: 65),
      User(name: 'Alice Johnson', email: 'alice@example.com', password: 'password123', weight: 55),
    ];

    for (User user in users) {
      await userDao.create(user);
    }
  }

  Future<void> insertDummyUserWeights() async {
    List<UserWeightData> userWeights = [
      UserWeightData(id: 1, userId: 1, weight: 70, date: '2023-01-01'),
      UserWeightData(id: 2, userId: 1, weight: 71, date: '2023-02-01'),
      UserWeightData(id: 3, userId: 2, weight: 65, date: '2023-01-01'),
      UserWeightData(id: 4, userId: 2, weight: 66, date: '2023-02-01'),
      UserWeightData(id: 5, userId: 3, weight: 55, date: '2023-01-01'),
      UserWeightData(id: 6, userId: 3, weight: 56, date: '2023-02-01'),
    ];

    for (UserWeightData userWeight in userWeights) {
      await userWeightDataDao.create(userWeight);
    }
  }

  Future<void> insertAllDummyData() async {
    await insertDummyUsers();
    await insertDummyUserWeights();
  }
}