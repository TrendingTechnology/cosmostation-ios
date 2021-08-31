// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: burrow/balance.proto

package balance;

public final class BalanceOuterClass {
  private BalanceOuterClass() {}
  public static void registerAllExtensions(
      com.google.protobuf.ExtensionRegistryLite registry) {
  }

  public static void registerAllExtensions(
      com.google.protobuf.ExtensionRegistry registry) {
    registerAllExtensions(
        (com.google.protobuf.ExtensionRegistryLite) registry);
  }
  public interface BalanceOrBuilder extends
      // @@protoc_insertion_point(interface_extends:balance.Balance)
      com.google.protobuf.MessageOrBuilder {

    /**
     * <code>uint32 Type = 1 [(.gogoproto.casttype) = "Type"];</code>
     * @return The type.
     */
    int getType();

    /**
     * <code>uint64 Amount = 2;</code>
     * @return The amount.
     */
    long getAmount();
  }
  /**
   * Protobuf type {@code balance.Balance}
   */
  public  static final class Balance extends
      com.google.protobuf.GeneratedMessageV3 implements
      // @@protoc_insertion_point(message_implements:balance.Balance)
      BalanceOrBuilder {
  private static final long serialVersionUID = 0L;
    // Use Balance.newBuilder() to construct.
    private Balance(com.google.protobuf.GeneratedMessageV3.Builder<?> builder) {
      super(builder);
    }
    private Balance() {
    }

    @java.lang.Override
    @SuppressWarnings({"unused"})
    protected java.lang.Object newInstance(
        UnusedPrivateParameter unused) {
      return new Balance();
    }

    @java.lang.Override
    public final com.google.protobuf.UnknownFieldSet
    getUnknownFields() {
      return this.unknownFields;
    }
    private Balance(
        com.google.protobuf.CodedInputStream input,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws com.google.protobuf.InvalidProtocolBufferException {
      this();
      if (extensionRegistry == null) {
        throw new java.lang.NullPointerException();
      }
      com.google.protobuf.UnknownFieldSet.Builder unknownFields =
          com.google.protobuf.UnknownFieldSet.newBuilder();
      try {
        boolean done = false;
        while (!done) {
          int tag = input.readTag();
          switch (tag) {
            case 0:
              done = true;
              break;
            case 8: {

              type_ = input.readUInt32();
              break;
            }
            case 16: {

              amount_ = input.readUInt64();
              break;
            }
            default: {
              if (!parseUnknownField(
                  input, unknownFields, extensionRegistry, tag)) {
                done = true;
              }
              break;
            }
          }
        }
      } catch (com.google.protobuf.InvalidProtocolBufferException e) {
        throw e.setUnfinishedMessage(this);
      } catch (java.io.IOException e) {
        throw new com.google.protobuf.InvalidProtocolBufferException(
            e).setUnfinishedMessage(this);
      } finally {
        this.unknownFields = unknownFields.build();
        makeExtensionsImmutable();
      }
    }
    public static final com.google.protobuf.Descriptors.Descriptor
        getDescriptor() {
      return balance.BalanceOuterClass.internal_static_balance_Balance_descriptor;
    }

    @java.lang.Override
    protected com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
        internalGetFieldAccessorTable() {
      return balance.BalanceOuterClass.internal_static_balance_Balance_fieldAccessorTable
          .ensureFieldAccessorsInitialized(
              balance.BalanceOuterClass.Balance.class, balance.BalanceOuterClass.Balance.Builder.class);
    }

    public static final int TYPE_FIELD_NUMBER = 1;
    private int type_;
    /**
     * <code>uint32 Type = 1 [(.gogoproto.casttype) = "Type"];</code>
     * @return The type.
     */
    public int getType() {
      return type_;
    }

    public static final int AMOUNT_FIELD_NUMBER = 2;
    private long amount_;
    /**
     * <code>uint64 Amount = 2;</code>
     * @return The amount.
     */
    public long getAmount() {
      return amount_;
    }

    private byte memoizedIsInitialized = -1;
    @java.lang.Override
    public final boolean isInitialized() {
      byte isInitialized = memoizedIsInitialized;
      if (isInitialized == 1) return true;
      if (isInitialized == 0) return false;

      memoizedIsInitialized = 1;
      return true;
    }

    @java.lang.Override
    public void writeTo(com.google.protobuf.CodedOutputStream output)
                        throws java.io.IOException {
      if (type_ != 0) {
        output.writeUInt32(1, type_);
      }
      if (amount_ != 0L) {
        output.writeUInt64(2, amount_);
      }
      unknownFields.writeTo(output);
    }

    @java.lang.Override
    public int getSerializedSize() {
      int size = memoizedSize;
      if (size != -1) return size;

      size = 0;
      if (type_ != 0) {
        size += com.google.protobuf.CodedOutputStream
          .computeUInt32Size(1, type_);
      }
      if (amount_ != 0L) {
        size += com.google.protobuf.CodedOutputStream
          .computeUInt64Size(2, amount_);
      }
      size += unknownFields.getSerializedSize();
      memoizedSize = size;
      return size;
    }

    @java.lang.Override
    public boolean equals(final java.lang.Object obj) {
      if (obj == this) {
       return true;
      }
      if (!(obj instanceof balance.BalanceOuterClass.Balance)) {
        return super.equals(obj);
      }
      balance.BalanceOuterClass.Balance other = (balance.BalanceOuterClass.Balance) obj;

      if (getType()
          != other.getType()) return false;
      if (getAmount()
          != other.getAmount()) return false;
      if (!unknownFields.equals(other.unknownFields)) return false;
      return true;
    }

    @java.lang.Override
    public int hashCode() {
      if (memoizedHashCode != 0) {
        return memoizedHashCode;
      }
      int hash = 41;
      hash = (19 * hash) + getDescriptor().hashCode();
      hash = (37 * hash) + TYPE_FIELD_NUMBER;
      hash = (53 * hash) + getType();
      hash = (37 * hash) + AMOUNT_FIELD_NUMBER;
      hash = (53 * hash) + com.google.protobuf.Internal.hashLong(
          getAmount());
      hash = (29 * hash) + unknownFields.hashCode();
      memoizedHashCode = hash;
      return hash;
    }

    public static balance.BalanceOuterClass.Balance parseFrom(
        java.nio.ByteBuffer data)
        throws com.google.protobuf.InvalidProtocolBufferException {
      return PARSER.parseFrom(data);
    }
    public static balance.BalanceOuterClass.Balance parseFrom(
        java.nio.ByteBuffer data,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws com.google.protobuf.InvalidProtocolBufferException {
      return PARSER.parseFrom(data, extensionRegistry);
    }
    public static balance.BalanceOuterClass.Balance parseFrom(
        com.google.protobuf.ByteString data)
        throws com.google.protobuf.InvalidProtocolBufferException {
      return PARSER.parseFrom(data);
    }
    public static balance.BalanceOuterClass.Balance parseFrom(
        com.google.protobuf.ByteString data,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws com.google.protobuf.InvalidProtocolBufferException {
      return PARSER.parseFrom(data, extensionRegistry);
    }
    public static balance.BalanceOuterClass.Balance parseFrom(byte[] data)
        throws com.google.protobuf.InvalidProtocolBufferException {
      return PARSER.parseFrom(data);
    }
    public static balance.BalanceOuterClass.Balance parseFrom(
        byte[] data,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws com.google.protobuf.InvalidProtocolBufferException {
      return PARSER.parseFrom(data, extensionRegistry);
    }
    public static balance.BalanceOuterClass.Balance parseFrom(java.io.InputStream input)
        throws java.io.IOException {
      return com.google.protobuf.GeneratedMessageV3
          .parseWithIOException(PARSER, input);
    }
    public static balance.BalanceOuterClass.Balance parseFrom(
        java.io.InputStream input,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws java.io.IOException {
      return com.google.protobuf.GeneratedMessageV3
          .parseWithIOException(PARSER, input, extensionRegistry);
    }
    public static balance.BalanceOuterClass.Balance parseDelimitedFrom(java.io.InputStream input)
        throws java.io.IOException {
      return com.google.protobuf.GeneratedMessageV3
          .parseDelimitedWithIOException(PARSER, input);
    }
    public static balance.BalanceOuterClass.Balance parseDelimitedFrom(
        java.io.InputStream input,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws java.io.IOException {
      return com.google.protobuf.GeneratedMessageV3
          .parseDelimitedWithIOException(PARSER, input, extensionRegistry);
    }
    public static balance.BalanceOuterClass.Balance parseFrom(
        com.google.protobuf.CodedInputStream input)
        throws java.io.IOException {
      return com.google.protobuf.GeneratedMessageV3
          .parseWithIOException(PARSER, input);
    }
    public static balance.BalanceOuterClass.Balance parseFrom(
        com.google.protobuf.CodedInputStream input,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws java.io.IOException {
      return com.google.protobuf.GeneratedMessageV3
          .parseWithIOException(PARSER, input, extensionRegistry);
    }

    @java.lang.Override
    public Builder newBuilderForType() { return newBuilder(); }
    public static Builder newBuilder() {
      return DEFAULT_INSTANCE.toBuilder();
    }
    public static Builder newBuilder(balance.BalanceOuterClass.Balance prototype) {
      return DEFAULT_INSTANCE.toBuilder().mergeFrom(prototype);
    }
    @java.lang.Override
    public Builder toBuilder() {
      return this == DEFAULT_INSTANCE
          ? new Builder() : new Builder().mergeFrom(this);
    }

    @java.lang.Override
    protected Builder newBuilderForType(
        com.google.protobuf.GeneratedMessageV3.BuilderParent parent) {
      Builder builder = new Builder(parent);
      return builder;
    }
    /**
     * Protobuf type {@code balance.Balance}
     */
    public static final class Builder extends
        com.google.protobuf.GeneratedMessageV3.Builder<Builder> implements
        // @@protoc_insertion_point(builder_implements:balance.Balance)
        balance.BalanceOuterClass.BalanceOrBuilder {
      public static final com.google.protobuf.Descriptors.Descriptor
          getDescriptor() {
        return balance.BalanceOuterClass.internal_static_balance_Balance_descriptor;
      }

      @java.lang.Override
      protected com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
          internalGetFieldAccessorTable() {
        return balance.BalanceOuterClass.internal_static_balance_Balance_fieldAccessorTable
            .ensureFieldAccessorsInitialized(
                balance.BalanceOuterClass.Balance.class, balance.BalanceOuterClass.Balance.Builder.class);
      }

      // Construct using balance.BalanceOuterClass.Balance.newBuilder()
      private Builder() {
        maybeForceBuilderInitialization();
      }

      private Builder(
          com.google.protobuf.GeneratedMessageV3.BuilderParent parent) {
        super(parent);
        maybeForceBuilderInitialization();
      }
      private void maybeForceBuilderInitialization() {
        if (com.google.protobuf.GeneratedMessageV3
                .alwaysUseFieldBuilders) {
        }
      }
      @java.lang.Override
      public Builder clear() {
        super.clear();
        type_ = 0;

        amount_ = 0L;

        return this;
      }

      @java.lang.Override
      public com.google.protobuf.Descriptors.Descriptor
          getDescriptorForType() {
        return balance.BalanceOuterClass.internal_static_balance_Balance_descriptor;
      }

      @java.lang.Override
      public balance.BalanceOuterClass.Balance getDefaultInstanceForType() {
        return balance.BalanceOuterClass.Balance.getDefaultInstance();
      }

      @java.lang.Override
      public balance.BalanceOuterClass.Balance build() {
        balance.BalanceOuterClass.Balance result = buildPartial();
        if (!result.isInitialized()) {
          throw newUninitializedMessageException(result);
        }
        return result;
      }

      @java.lang.Override
      public balance.BalanceOuterClass.Balance buildPartial() {
        balance.BalanceOuterClass.Balance result = new balance.BalanceOuterClass.Balance(this);
        result.type_ = type_;
        result.amount_ = amount_;
        onBuilt();
        return result;
      }

      @java.lang.Override
      public Builder clone() {
        return super.clone();
      }
      @java.lang.Override
      public Builder setField(
          com.google.protobuf.Descriptors.FieldDescriptor field,
          java.lang.Object value) {
        return super.setField(field, value);
      }
      @java.lang.Override
      public Builder clearField(
          com.google.protobuf.Descriptors.FieldDescriptor field) {
        return super.clearField(field);
      }
      @java.lang.Override
      public Builder clearOneof(
          com.google.protobuf.Descriptors.OneofDescriptor oneof) {
        return super.clearOneof(oneof);
      }
      @java.lang.Override
      public Builder setRepeatedField(
          com.google.protobuf.Descriptors.FieldDescriptor field,
          int index, java.lang.Object value) {
        return super.setRepeatedField(field, index, value);
      }
      @java.lang.Override
      public Builder addRepeatedField(
          com.google.protobuf.Descriptors.FieldDescriptor field,
          java.lang.Object value) {
        return super.addRepeatedField(field, value);
      }
      @java.lang.Override
      public Builder mergeFrom(com.google.protobuf.Message other) {
        if (other instanceof balance.BalanceOuterClass.Balance) {
          return mergeFrom((balance.BalanceOuterClass.Balance)other);
        } else {
          super.mergeFrom(other);
          return this;
        }
      }

      public Builder mergeFrom(balance.BalanceOuterClass.Balance other) {
        if (other == balance.BalanceOuterClass.Balance.getDefaultInstance()) return this;
        if (other.getType() != 0) {
          setType(other.getType());
        }
        if (other.getAmount() != 0L) {
          setAmount(other.getAmount());
        }
        this.mergeUnknownFields(other.unknownFields);
        onChanged();
        return this;
      }

      @java.lang.Override
      public final boolean isInitialized() {
        return true;
      }

      @java.lang.Override
      public Builder mergeFrom(
          com.google.protobuf.CodedInputStream input,
          com.google.protobuf.ExtensionRegistryLite extensionRegistry)
          throws java.io.IOException {
        balance.BalanceOuterClass.Balance parsedMessage = null;
        try {
          parsedMessage = PARSER.parsePartialFrom(input, extensionRegistry);
        } catch (com.google.protobuf.InvalidProtocolBufferException e) {
          parsedMessage = (balance.BalanceOuterClass.Balance) e.getUnfinishedMessage();
          throw e.unwrapIOException();
        } finally {
          if (parsedMessage != null) {
            mergeFrom(parsedMessage);
          }
        }
        return this;
      }

      private int type_ ;
      /**
       * <code>uint32 Type = 1 [(.gogoproto.casttype) = "Type"];</code>
       * @return The type.
       */
      public int getType() {
        return type_;
      }
      /**
       * <code>uint32 Type = 1 [(.gogoproto.casttype) = "Type"];</code>
       * @param value The type to set.
       * @return This builder for chaining.
       */
      public Builder setType(int value) {
        
        type_ = value;
        onChanged();
        return this;
      }
      /**
       * <code>uint32 Type = 1 [(.gogoproto.casttype) = "Type"];</code>
       * @return This builder for chaining.
       */
      public Builder clearType() {
        
        type_ = 0;
        onChanged();
        return this;
      }

      private long amount_ ;
      /**
       * <code>uint64 Amount = 2;</code>
       * @return The amount.
       */
      public long getAmount() {
        return amount_;
      }
      /**
       * <code>uint64 Amount = 2;</code>
       * @param value The amount to set.
       * @return This builder for chaining.
       */
      public Builder setAmount(long value) {
        
        amount_ = value;
        onChanged();
        return this;
      }
      /**
       * <code>uint64 Amount = 2;</code>
       * @return This builder for chaining.
       */
      public Builder clearAmount() {
        
        amount_ = 0L;
        onChanged();
        return this;
      }
      @java.lang.Override
      public final Builder setUnknownFields(
          final com.google.protobuf.UnknownFieldSet unknownFields) {
        return super.setUnknownFields(unknownFields);
      }

      @java.lang.Override
      public final Builder mergeUnknownFields(
          final com.google.protobuf.UnknownFieldSet unknownFields) {
        return super.mergeUnknownFields(unknownFields);
      }


      // @@protoc_insertion_point(builder_scope:balance.Balance)
    }

    // @@protoc_insertion_point(class_scope:balance.Balance)
    private static final balance.BalanceOuterClass.Balance DEFAULT_INSTANCE;
    static {
      DEFAULT_INSTANCE = new balance.BalanceOuterClass.Balance();
    }

    public static balance.BalanceOuterClass.Balance getDefaultInstance() {
      return DEFAULT_INSTANCE;
    }

    private static final com.google.protobuf.Parser<Balance>
        PARSER = new com.google.protobuf.AbstractParser<Balance>() {
      @java.lang.Override
      public Balance parsePartialFrom(
          com.google.protobuf.CodedInputStream input,
          com.google.protobuf.ExtensionRegistryLite extensionRegistry)
          throws com.google.protobuf.InvalidProtocolBufferException {
        return new Balance(input, extensionRegistry);
      }
    };

    public static com.google.protobuf.Parser<Balance> parser() {
      return PARSER;
    }

    @java.lang.Override
    public com.google.protobuf.Parser<Balance> getParserForType() {
      return PARSER;
    }

    @java.lang.Override
    public balance.BalanceOuterClass.Balance getDefaultInstanceForType() {
      return DEFAULT_INSTANCE;
    }

  }

  private static final com.google.protobuf.Descriptors.Descriptor
    internal_static_balance_Balance_descriptor;
  private static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_balance_Balance_fieldAccessorTable;

  public static com.google.protobuf.Descriptors.FileDescriptor
      getDescriptor() {
    return descriptor;
  }
  private static  com.google.protobuf.Descriptors.FileDescriptor
      descriptor;
  static {
    java.lang.String[] descriptorData = {
      "\n\024burrow/balance.proto\022\007balance\032\024gogopro" +
      "to/gogo.proto\"?\n\007Balance\022\026\n\004Type\030\001 \001(\rB\010" +
      "\372\336\037\004Type\022\016\n\006Amount\030\002 \001(\004:\014\220\242\037\000\230\242\037\000\230\240\037\000BC" +
      "Z)github.com/hyperledger/burrow/acm/bala" +
      "nce\330\342\036\001\310\342\036\001\320\342\036\001\340\342\036\001\300\343\036\001\310\343\036\001b\006proto3"
    };
    descriptor = com.google.protobuf.Descriptors.FileDescriptor
      .internalBuildGeneratedFileFrom(descriptorData,
        new com.google.protobuf.Descriptors.FileDescriptor[] {
          com.google.protobuf2.GoGoProtos.getDescriptor(),
        });
    internal_static_balance_Balance_descriptor =
      getDescriptor().getMessageTypes().get(0);
    internal_static_balance_Balance_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_balance_Balance_descriptor,
        new java.lang.String[] { "Type", "Amount", });
    com.google.protobuf.ExtensionRegistry registry =
        com.google.protobuf.ExtensionRegistry.newInstance();
    registry.add(com.google.protobuf2.GoGoProtos.casttype);
    registry.add(com.google.protobuf2.GoGoProtos.goprotoRegistration);
    registry.add(com.google.protobuf2.GoGoProtos.goprotoSizecache);
    registry.add(com.google.protobuf2.GoGoProtos.goprotoStringer);
    registry.add(com.google.protobuf2.GoGoProtos.goprotoUnkeyed);
    registry.add(com.google.protobuf2.GoGoProtos.marshalerAll);
    registry.add(com.google.protobuf2.GoGoProtos.messagenameAll);
    registry.add(com.google.protobuf2.GoGoProtos.sizerAll);
    registry.add(com.google.protobuf2.GoGoProtos.stableMarshalerAll);
    registry.add(com.google.protobuf2.GoGoProtos.unmarshalerAll);
    com.google.protobuf.Descriptors.FileDescriptor
        .internalUpdateFileDescriptor(descriptor, registry);
    com.google.protobuf2.GoGoProtos.getDescriptor();
  }

  // @@protoc_insertion_point(outer_class_scope)
}
