// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: shentu/gov/v1alpha1/tx.proto

package shentu.gov.v1alpha1;

public final class Tx {
  private Tx() {}
  public static void registerAllExtensions(
      com.google.protobuf.ExtensionRegistryLite registry) {
  }

  public static void registerAllExtensions(
      com.google.protobuf.ExtensionRegistry registry) {
    registerAllExtensions(
        (com.google.protobuf.ExtensionRegistryLite) registry);
  }

  public static com.google.protobuf.Descriptors.FileDescriptor
      getDescriptor() {
    return descriptor;
  }
  private static  com.google.protobuf.Descriptors.FileDescriptor
      descriptor;
  static {
    java.lang.String[] descriptorData = {
      "\n\034shentu/gov/v1alpha1/tx.proto\022\023shentu.g" +
      "ov.v1alpha1\032\036cosmos/base/v1beta1/coin.pr" +
      "oto\032\033cosmos/gov/v1beta1/tx.proto\032\031cosmos" +
      "_proto/cosmos.proto\032\024gogoproto/gogo.prot" +
      "o\032\032google/protobuf2/any.proto2\212\002\n\003Msg\022f\n" +
      "\016SubmitProposal\022%.cosmos.gov.v1beta1.Msg" +
      "SubmitProposal\032-.cosmos.gov.v1beta1.MsgS" +
      "ubmitProposalResponse\022H\n\004Vote\022\033.cosmos.g" +
      "ov.v1beta1.MsgVote\032#.cosmos.gov.v1beta1." +
      "MsgVoteResponse\022Q\n\007Deposit\022\036.cosmos.gov." +
      "v1beta1.MsgDeposit\032&.cosmos.gov.v1beta1." +
      "MsgDepositResponseB4Z.github.com/certikf" +
      "oundation/shentu/x/gov/types\330\342\036\001b\006proto3"
    };
    descriptor = com.google.protobuf.Descriptors.FileDescriptor
      .internalBuildGeneratedFileFrom(descriptorData,
        new com.google.protobuf.Descriptors.FileDescriptor[] {
          cosmos.base.v1beta1.CoinOuterClass.getDescriptor(),
          cosmos.gov.v1beta1.Tx.getDescriptor(),
          cosmos_proto.Cosmos.getDescriptor(),
          com.google.protobuf2.GoGoProtos.getDescriptor(),
          com.google.protobuf2.AnyProto.getDescriptor(),
        });
    com.google.protobuf.ExtensionRegistry registry =
        com.google.protobuf.ExtensionRegistry.newInstance();
    registry.add(com.google.protobuf2.GoGoProtos.stableMarshalerAll);
    com.google.protobuf.Descriptors.FileDescriptor
        .internalUpdateFileDescriptor(descriptor, registry);
    cosmos.base.v1beta1.CoinOuterClass.getDescriptor();
    cosmos.gov.v1beta1.Tx.getDescriptor();
    cosmos_proto.Cosmos.getDescriptor();
    com.google.protobuf2.GoGoProtos.getDescriptor();
    com.google.protobuf2.AnyProto.getDescriptor();
  }

  // @@protoc_insertion_point(outer_class_scope)
}
