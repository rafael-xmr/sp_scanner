import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:package/package.dart' as package;

void main(List<String> arguments) {
  package.callGetSecKeys(
    [
      "f207162b1a7abc51c42017bef055e9ec1efc3d3567cb720357e2b84325db33ac",
      "e976a58fbd38aeb4e6093d4df02e9c1de0c4513ae0c588cef68cda5b2f8834ca",
      "841792c33c9dc6193e76744134125d40add8f2f4a96475f28ba150be032d64e8",
      "2e847bb01d1b491da512ddd760b8509617ee38057003d6115d00ba562451323a"
    ],
    ECPrivate.fromHex("33ce085c3c11eaad13694aae3c20301a6c83382ec89a7cde96c6799e2f88805a")
        .getPublic()
        .toCompressedBytes(),
    package.Receiver(
      "0f694e068028a717f8af6b9411f9a133dd3565258714cc226594b34db90c1f2c",
      ECPrivate.fromHex("9d6ad855ce3417ef84e836892e5a56392bfba05fa5d97ccea30e266f540e08b3")
          .getPublic()
          .toHex(),
      true,
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    ),
  );
}
