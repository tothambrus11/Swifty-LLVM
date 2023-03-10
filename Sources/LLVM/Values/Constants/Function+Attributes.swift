import llvmc

extension Function: AttributeHolder {

  /// An attribute on a function in LLVM IR.
  public typealias Attribute = LLVM.Attribute<Function>

  /// The name of an attribute on a function in LLVM IR.
  public enum AttributeName: String, AttributeNameProtocol {

    /// Indicates that the inliner should attempt to inline this function into callers whenever
    /// possible, ignoring any active inlining size threshold for this caller.
    case alwaysinline

    /// Indicates that this function is rarely called.
    case cold

    /// Indicates that this function is a hot spot of the program execution.
    case hot

    /// Indicates that the inliner should never inline this function in any situation.
    ///
    /// - Note: This attribute may not be used together with the `alwaysinline` attribute.
    case noinline

    /// Indicates that the function never returns normally.
    ///
    /// If the function ever does dynamically return, its run-time behavior is undefined. Annotated
    /// functions may still raise an exception, i.e., `nounwind` is not implied.
    case noreturn

    /// Indicates that the function does not call itself either directly or indirectly down any
    /// possible call path.
    ///
    /// If the function ever does recurse, its run-time behavior is undefined.
    case norecurse

    /// Indicates that the function never raises an exception.
    ///
    /// If the function does raise an exception, its run-time behavior is undefined. However,
    /// functions marked nounwind may still trap or generate asynchronous exceptions. Exception
    /// handling schemes that are recognized by LLVM to handle asynchronous exceptions, such as
    /// `SEH`, will still provide their implementation defined semantics.
    case nounwind

    /// The unique kind identifier corresponding to this name.
    public var id: UInt32 {
      return LLVMGetEnumAttributeKindForName(rawValue, rawValue.count)
    }

  }

  /// The attributes of the function.
  public var attributes: [Attribute] {
    let i = UInt32(bitPattern: Int32(LLVMAttributeFunctionIndex))
    let n = LLVMGetAttributeCountAtIndex(llvm, i)
    var handles: [LLVMAttributeRef?] = .init(repeating: nil, count: Int(n))
    LLVMGetAttributesAtIndex(llvm, i, &handles)
    return handles.map(Attribute.init(_:))
  }

}
