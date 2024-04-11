// ignore_for_file: non_constant_identifier_names
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

final class OutputData extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> pubkey_bytes;
  @ffi.Uint64()
  external int amount;
}

class Receiver {
  final String bScan;
  final String BSpend;
  final bool isTestnet;
  final List<int> labels;

  Receiver(this.bScan, this.BSpend, this.isTestnet, this.labels);
}

final class ReceiverData extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> b_scan_bytes;
  external ffi.Pointer<ffi.Uint8> B_spend_bytes;
  @ffi.Bool()
  external bool is_testnet;
  external ffi.Pointer<ffi.Uint32> labels;
}

final class ParamData extends ffi.Struct {
  external ffi.Pointer<ffi.Pointer<OutputData>> outputs_data;
  @ffi.Uint64()
  external int outputs_data_len;
  external ffi.Pointer<ffi.Uint8> tweak_bytes;
  external ffi.Pointer<ReceiverData> receiver_data;
}

typedef GetSecKeyFunc = ffi.Void Function(ffi.Pointer<ParamData>);
typedef GetSecKey = void Function(ffi.Pointer<ParamData>);

ffi.Pointer<OutputData> createOutputDataStruct(String txid) {
  final ffi.Pointer<ffi.Uint8> txidPtr = calloc<ffi.Uint8>(txid.length);
  final txidList = txidPtr.asTypedList(txid.length);
  txidList.setAll(0, BytesUtils.fromHexString(txid));

  final result = calloc<OutputData>();
  result.ref.pubkey_bytes = txidPtr;
  return result;
}

void freeOutputDataStruct(ffi.Pointer<OutputData> voutDataPtr) {
  calloc.free(voutDataPtr.ref.pubkey_bytes);
  calloc.free(voutDataPtr);
}

ffi.Pointer<ReceiverData> createReceiverDataStruct(
    String bScan, String BSpend, bool isTestnet, List<int> labels) {
  final ffi.Pointer<ffi.Uint8> bScanPtr = calloc<ffi.Uint8>(bScan.length);
  final bScanList = bScanPtr.asTypedList(bScan.length);
  bScanList.setAll(0, BytesUtils.fromHexString(bScan));

  final ffi.Pointer<ffi.Uint8> bSpendPtr = calloc<ffi.Uint8>(BSpend.length);
  final BSpendList = bSpendPtr.asTypedList(BSpend.length);
  BSpendList.setAll(0, BytesUtils.fromHexString(BSpend));

  final ffi.Pointer<ffi.Uint32> labelsPtr = calloc<ffi.Uint32>(labels.length);
  final labelsList = labelsPtr.asTypedList(labels.length);
  labelsList.setAll(0, labels);

  final result = calloc<ReceiverData>();
  result.ref
    ..b_scan_bytes = bScanPtr
    ..B_spend_bytes = bSpendPtr
    ..is_testnet = isTestnet
    ..labels = labelsPtr;
  return result;
}

void freeReceiverDataStruct(ffi.Pointer<ReceiverData> receiverDataPtr) {
  calloc.free(receiverDataPtr.ref.b_scan_bytes);
  calloc.free(receiverDataPtr.ref.B_spend_bytes);
  calloc.free(receiverDataPtr.ref.labels);
  calloc.free(receiverDataPtr);
}

void callGetSecKeys(List<String> txids, List<int> tweakBytes, Receiver receiver) {
  final dl = ffi.DynamicLibrary.open("rust-silentpayments/target/debug/libsilentpayments.so");
  final getSecKey = dl.lookupFunction<GetSecKeyFunc, GetSecKey>("get_sec_key");

  final pointers = calloc<ffi.Pointer<OutputData>>(txids.length);
  for (int i = 0; i < txids.length; i++) {
    pointers[i] = createOutputDataStruct(txids[i]);
  }

  final pointersReceiver = createReceiverDataStruct(
      receiver.bScan, receiver.BSpend, receiver.isTestnet, receiver.labels);

  final tweakPtr = calloc<ffi.Uint8>(tweakBytes.length);
  final tweakList = tweakPtr.asTypedList(tweakBytes.length);
  tweakList.setAll(0, tweakBytes);

  final paramData = calloc<ParamData>();
  paramData.ref
    ..outputs_data = pointers
    ..outputs_data_len = txids.length
    ..tweak_bytes = tweakPtr
    ..receiver_data = pointersReceiver;

  // Call the Rust function with ParamData
  getSecKey(paramData);

  // Cleanup
  for (int i = 0; i < txids.length; i++) {
    freeOutputDataStruct(pointers[i]);
  }
  freeReceiverDataStruct(pointersReceiver);
  calloc.free(pointers);
  calloc.free(tweakPtr);
  calloc.free(paramData);
}
