import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:sp_scanner/sp_scanner.dart';

void main(List<String> arguments) {
  final result = interpretBytesVec(callApiScanOutputs(
    ["e00a003643cebac9fa0a5569ddd7921023e9d744d61f9aac540f3a3ebcb6eb6c"],
    ECPublic.fromHex("03820ba28923a3d4ecf7ae5ad6de8b737bd0a9b34c7dcf1efe846bb73c88737e8e").toHex(),
    Receiver(
      "a757e2cb0b1e7376062ce0a618166c83adbe6ac00abcba9b9e3197dd71d29a01",
      "03dab9fb8d205198b11616a24c598c9488063c8048e55fc4ebedc8a0f86125aa2d",
      true,
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      10,
    ),
  ));
  print('Result: $result');
}
