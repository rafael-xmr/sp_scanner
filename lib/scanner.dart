// ignore_for_file: non_constant_identifier_names
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:sp_scanner/generated_bindings.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

DynamicLibrary load(name) {
  // return DynamicLibrary.open(
  //     '/home/rafael/Working/sp_scanner/rust-silentpayments/target/debug/libsilentpayments.so');
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$name.so');
  } else if (Platform.isIOS || Platform.isMacOS) {
    return DynamicLibrary.open('$name.framework/$name');
  } else {
    // } else if (Platform.isWindows) {
    return DynamicLibrary.open('$name.dll');
  }
}

final lib = NativeLibrary(load('silentpayments'));

class Receiver {
  final String bScan;
  final String BSpend;
  final bool isTestnet;
  final List<int> labels;
  final int labelsLen;

  Receiver(this.bScan, this.BSpend, this.isTestnet, this.labels, this.labelsLen);
}

Pointer<OutputData> createOutputDataStruct(String outputToCheck) {
  final outputBytes = BytesUtils.fromHexString(outputToCheck);
  final Pointer<Uint8> outputToCheckPtr = calloc<Uint8>(outputBytes.length);
  final outputToCheckList = outputToCheckPtr.asTypedList(outputBytes.length);
  outputToCheckList.setAll(0, outputBytes);

  final result = calloc<OutputData>();
  result.ref.pubkey_bytes = outputToCheckPtr;
  return result;
}

void freeOutputDataStruct(Pointer<OutputData> voutDataPtr) {
  calloc.free(voutDataPtr.ref.pubkey_bytes);
  calloc.free(voutDataPtr);
}

Pointer<ReceiverData> createReceiverDataStruct(
  String bScan,
  String BSpend,
  bool isTestnet,
  List<int> labels,
  int labelsLen,
) {
  final Pointer<Uint8> bScanPtr = calloc<Uint8>(bScan.length);
  final bScanList = bScanPtr.asTypedList(bScan.length);
  bScanList.setAll(0, BytesUtils.fromHexString(bScan));

  final Pointer<Uint8> bSpendPtr = calloc<Uint8>(BSpend.length);
  final BSpendList = bSpendPtr.asTypedList(BSpend.length);
  BSpendList.setAll(0, BytesUtils.fromHexString(BSpend));

  final Pointer<Uint32> labelsPtr = calloc<Uint32>(labels.length);
  final labelsList = labelsPtr.asTypedList(labels.length);
  labelsList.setAll(0, labels);

  final result = calloc<ReceiverData>();
  result.ref
    ..b_scan_bytes = bScanPtr
    ..B_spend_bytes = bSpendPtr
    ..is_testnet = isTestnet ? 1 : 0
    ..labels = labelsPtr
    ..labels_len = labelsLen;
  return result;
}

void freeReceiverDataStruct(Pointer<ReceiverData> receiverDataPtr) {
  calloc.free(receiverDataPtr.ref.b_scan_bytes);
  calloc.free(receiverDataPtr.ref.B_spend_bytes);
  calloc.free(receiverDataPtr.ref.labels);
  calloc.free(receiverDataPtr);
}

BytesVec callApiScanOutputs(
    List<String> outputsToCheck, String tweakDataForRecipient, Receiver receiver) {
  final pointers = calloc<Pointer<OutputData>>(outputsToCheck.length);
  for (int i = 0; i < outputsToCheck.length; i++) {
    pointers[i] = createOutputDataStruct(outputsToCheck[i]);
  }

  final pointersReceiver = createReceiverDataStruct(
    receiver.bScan,
    receiver.BSpend,
    receiver.isTestnet,
    receiver.labels,
    receiver.labelsLen,
  );

  final tweakBytes = BytesUtils.fromHexString(tweakDataForRecipient);
  final tweakPtr = calloc<Uint8>(tweakBytes.length);
  final tweakList = tweakPtr.asTypedList(tweakBytes.length);
  tweakList.setAll(0, tweakBytes);

  final paramData = calloc<ParamData>();
  paramData.ref
    ..outputs_data = pointers
    ..outputs_data_len = outputsToCheck.length
    ..tweak_bytes = tweakPtr
    ..receiver_data = pointersReceiver;

  // Call the Rust function with ParamData
  final result = lib.api_scan_outputs(paramData);

  // Cleanup
  for (int i = 0; i < outputsToCheck.length; i++) {
    freeOutputDataStruct(pointers[i]);
  }
  freeReceiverDataStruct(pointersReceiver);
  calloc.free(pointers);
  calloc.free(tweakPtr);
  calloc.free(paramData);

  return result;
}

// A function to interpret the BytesVec returned from Rust
String interpretBytesVec(BytesVec bytesVec) {
  final byteList = bytesVec.data.asTypedList(bytesVec.len);

  freeBytesVec(bytesVec.data, bytesVec.len);

  return BytesUtils.toHexString(byteList);
}

typedef FreeFunc = Void Function(Pointer<BytesVec>);
typedef Free = void Function(Pointer<BytesVec>);

void freeBytesVec(Pointer<Uint8> bytesVecPtr, int len) {
  lib.free_bytes_vec(bytesVecPtr, len);
}
