//
//  AnyEquatable.swift
//  
//
//  Created by Matthaus Woolard on 27/12/2020.
//

import Foundation

/// A value that has a custom representation in `AnyEquatable`.
///
/// `Self` should also conform to `Equatable`.
protocol _HasCustomAnyEquatableRepresentation {
  /// Returns a custom representation of `self` as `AnyEquatable`.
  /// If returns nil, the default representation is used.
  ///
  /// If your custom representation is a class instance, it
  /// needs to be boxed into `AnyEquatable` using the static
  /// type that introduces the `Equatable` conformance.
  ///
  ///     class Base: Equatable {}
  ///     class Derived1: Base {}
  ///     class Derived2: Base, _HasCustomAnyEquatableRepresentation {
  ///       func _toCustomAnyEquatable() -> AnyEquatable? {
  ///         // `Derived2` is canonicalized to `Derived1`.
  ///         let customRepresentation = Derived1()
  ///
  ///         // Wrong:
  ///         // return AnyEquatable(customRepresentation)
  ///
  ///         // Correct:
  ///         return AnyEquatable(customRepresentation as Base)
  ///       }
  __consuming func _toCustomAnyEquatable() -> AnyEquatable?
}

@usableFromInline
internal protocol _AnyEquatableBox {
  var _canonicalBox: _AnyEquatableBox { get }

  /// Determine whether values in the boxes are equivalent.
  ///
  /// - Precondition: `self` and `box` are in canonical form.
  /// - Returns: `nil` to indicate that the boxes store different types, so
  ///   no comparison is possible. Otherwise, contains the result of `==`.
  func _isEqual(to box: _AnyEquatableBox) -> Bool?

  var _base: Any { get }
  func _unbox<T: Equatable>() -> T?
  func _downCastConditional<T>(into result: UnsafeMutablePointer<T>) -> Bool
}

extension _AnyEquatableBox {
  var _canonicalBox: _AnyEquatableBox {
    return self
  }
}

internal struct _ConcreteEquatableBox<Base: Equatable>: _AnyEquatableBox {
  internal var _baseEquatable: Base

  internal init(_ base: Base) {
    self._baseEquatable = base
  }

  internal func _unbox<T: Equatable>() -> T? {
    return (self as _AnyEquatableBox as? _ConcreteEquatableBox<T>)?._baseEquatable
  }

  internal func _isEqual(to rhs: _AnyEquatableBox) -> Bool? {
    if let rhs: Base = rhs._unbox() {
      return _baseEquatable == rhs
    }
    return nil
  }

  internal var _base: Any {
    return _baseEquatable
  }

  internal
  func _downCastConditional<T>(into result: UnsafeMutablePointer<T>) -> Bool {
    guard let value = _baseEquatable as? T else { return false }
    result.initialize(to: value)
    return true
  }
}

/// A type-erased equatable value.
///
/// The `AnyEquatable` type forwards equality comparisons to an underlying equatable value,
/// hiding the type of the wrapped value.
///
/// Where conversion using `as` or `as?` is possible between two types (such as
/// `Int` and `NSNumber`), `AnyEquatable` uses a canonical representation of the
/// type-erased value so that instances wrapping the same value of either type
/// compare as equal. For example, `AnyEquatable(42)` compares as equal to
/// `AnyEquatable(42 as NSNumber)`.
struct AnyEquatable {
  internal var _box: _AnyEquatableBox

  internal init(_box box: _AnyEquatableBox) {
    self._box = box
  }

  /// Creates a type-erased equatable value that wraps the given instance.
  ///
  /// - Parameter base: A equatable value to wrap.
  init<H: Equatable>(_ base: H) {
    if let custom =
      (base as? _HasCustomAnyEquatableRepresentation)?._toCustomAnyEquatable() {
      self = custom
      return
    }

    self.init(_box: _ConcreteEquatableBox(base))
  }

  internal init<H: Equatable>(_usingDefaultRepresentationOf base: H) {
    self._box = _ConcreteEquatableBox(base)
  }

  /// The value wrapped by this instance.
  ///
  /// The `base` property can be cast back to its original type using one of
  /// the type casting operators (`as?`, `as!`, or `as`).
  ///
  ///     let anyMessage = AnyEquatable("Hello world!")
  ///     if let unwrappedMessage = anyMessage.base as? String {
  ///         print(unwrappedMessage)
  ///     }
  ///     // Prints "Hello world!"
  var base: Any {
    return _box._base
  }

  /// Perform a downcast directly on the internal boxed representation.
  ///
  /// This avoids the intermediate re-boxing we would get if we just did
  /// a downcast on `base`.
  internal
  func _downCastConditional<T>(into result: UnsafeMutablePointer<T>) -> Bool {
    // Attempt the downcast.
    if _box._downCastConditional(into: result) { return true }

    #if _runtime(_ObjC)
    // Bridge to Objective-C and then attempt the cast from there.
    // FIXME: This should also work without the Objective-C runtime.
    if let value = _bridgeAnythingToObjectiveC(_box._base) as? T {
      result.initialize(to: value)
      return true
    }
    #endif

    return false
  }
}

extension AnyEquatable: Equatable {
  /// Returns a Boolean value indicating whether two type-erased equatable
  /// instances wrap the same value.
  ///
  /// `AnyEquatable` considers bridged counterparts (such as a `String` and an
  /// `NSString`) of the same value to be equivalent when type-erased. If those
  /// compatible types use different definitions for equality, values that were
  /// originally distinct might compare as equal when they are converted to
  /// `AnyEquatable`:
  ///
  ///     let string1 = "café"
  ///     let string2 = "cafe\u{301}" // U+301 COMBINING ACUTE ACCENT
  ///     let nsString1 = string1 as NSString
  ///     let nsString2 = string2 as NSString
  ///     let typeErased1 = nsString1 as AnyEquatable
  ///     let typeErased2 = nsString2 as AnyEquatable
  ///     print(string1 == string2)         // prints "true"
  ///     print(nsString1 == nsString2)     // prints "false"
  ///     print(typeErased1 == typeErased2) // prints "true"
  ///
  /// - Parameters:
  ///   - lhs: A type-erased equatable value.
  ///   - rhs: Another type-erased equatable value.
  static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
    return lhs._box._canonicalBox._isEqual(to: rhs._box._canonicalBox) ?? false
  }
}

extension AnyEquatable: CustomStringConvertible {
  var description: String {
    return String(describing: base)
  }
}

extension AnyEquatable: CustomDebugStringConvertible {
  var debugDescription: String {
    return "AnyEquatable(" + String(reflecting: base) + ")"
  }
}

extension AnyEquatable: CustomReflectable {
  var customMirror: Mirror {
    Mirror(
      self,
      children: ["value": base]
    )
  }
}

// MARK: NonEquitableWrapper

struct NonEquitableWrapper: Equatable {
    var base: Any
    let id: UUID = UUID()

    static func == (lhs: NonEquitableWrapper, rhs: NonEquitableWrapper) -> Bool {
        lhs.id == rhs.id
    }
}

extension NonEquitableWrapper: CustomStringConvertible {
  var description: String {
    return String(describing: base)
  }
}

extension NonEquitableWrapper: CustomDebugStringConvertible {
  var debugDescription: String {
    return "NonEquitableWrapper(" + String(reflecting: base) + ")"
  }
}

extension NonEquitableWrapper: CustomReflectable {
  var customMirror: Mirror {
    Mirror(
      self,
      children: ["value": base]
    )
  }
}
