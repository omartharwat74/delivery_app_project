import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/working_hours_model.dart';

abstract class WorkingHoursRemoteDataSource {
  /// GET /working-hours
  Future<WorkingHoursModel> getWorkingHours();

  /// POST /working-hours
  Future<WorkingHoursModel> addWorkingHours({
    required String workDate,
    required String startsAt,
    required String endsAt,
  });

  /// DELETE /working-hours?work_date=YYYY-MM-DD
  Future<WorkingHoursModel> deleteWorkingHours({required String workDate});
}

class WorkingHoursRemoteDataSourceImpl implements WorkingHoursRemoteDataSource {
  final ApiClient apiClient;

  WorkingHoursRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<WorkingHoursModel> getWorkingHours() async {
    final response = await apiClient.getResponse<WorkingHoursModel>(
      ApiConstants.workingHours,
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return WorkingHoursModel.fromJson(data);
        }
        throw Exception('Invalid working hours data format');
      },
    );

    if (response.data != null) return response.data!;
    throw Exception(
      response.msg.isNotEmpty ? response.msg : 'Failed to fetch working hours',
    );
  }

  @override
  Future<WorkingHoursModel> addWorkingHours({
    required String workDate,
    required String startsAt,
    required String endsAt,
  }) async {
    final response = await apiClient.postResponse<WorkingHoursModel>(
      ApiConstants.workingHours,
      body: {
        'work_date': workDate,
        'starts_at': startsAt,
        'ends_at': endsAt,
      },
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return WorkingHoursModel.fromJson(data);
        }
        throw Exception('Invalid working hours data format');
      },
    );

    if (response.data != null) return response.data!;
    throw Exception(
      response.msg.isNotEmpty ? response.msg : 'Failed to add working hours',
    );
  }

  @override
  Future<WorkingHoursModel> deleteWorkingHours({
    required String workDate,
  }) async {
    final response = await apiClient.deleteResponse<WorkingHoursModel>(
      ApiConstants.workingHours,
      queryParams: {'work_date': workDate},
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return WorkingHoursModel.fromJson(data);
        }
        throw Exception('Invalid working hours data format');
      },
    );

    if (response.data != null) return response.data!;
    throw Exception(
      response.msg.isNotEmpty
          ? response.msg
          : 'Failed to delete working hours',
    );
  }
}
