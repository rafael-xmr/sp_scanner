import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:sp_scanner/sp_scanner.dart';

void main(List<String> arguments) {
  final result = interpretBytesVec(callApiScanOutputs(
    [
      ["545ff3ecec27fbf43790d639a7a71ea0ff72a3dcce11aea17aeb63eca4188379", 0]
    ],
    ECPublic.fromHex("03a952f2ec5ea0a8bd7d5022c499ab7947058e3dd471434775b08f10d5d4fd1ab9").toHex(),
    Receiver(
      "f402c47811fa7ff8d7f879de7be8d2f1b7cc411c0542535731fb43095b90a3b6",
      "022fdc3f6726e23bfce017ab731c09e13d97cde4613bba309e5f2c507798764bca",
      false,
      [1],
      1,
    ),
  ));
  print('Result: $result');
}
