import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  /// GET /wallet
  Future<WalletModel> getWallet();

  /// POST /wallet/withdrawals
  Future<void> requestWithdrawal(double amount);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient apiClient;

  WalletRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<WalletModel> getWallet() async {
    final response = await apiClient.getResponse<WalletModel>(
      ApiConstants.wallet,
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return WalletModel.fromJson(data);
        }
        throw Exception('Invalid wallet data structure');
      },
    );

    if (response.data != null) {
      return response.data!;
    }
    throw Exception(response.msg.isNotEmpty ? response.msg : 'Failed to load wallet data');
  }

  @override
  Future<void> requestWithdrawal(double amount) async {
    final response = await apiClient.postResponse(
      ApiConstants.walletWithdrawals,
      body: {'amount': amount},
    );

    if (!response.isSuccess) {
      throw Exception(response.msg.isNotEmpty ? response.msg : 'Failed to request withdrawal');
    }
  }
}
