//
//  KeyWindowValueKeyTests.swift
//  
//
//  Created by Matthaus Woolard on 05/01/2021.
//
import XCTest
import KeyWindow

extension Int: KeyWindowValueKey {
    public typealias Value = Self
}

class NonEquatableType: KeyWindowValueKey {
    internal init(value: Int) {
        self.value = value
    }
    
    typealias Value = NonEquatableType
    
    var value: Int
}

enum CustomCastKey: KeyWindowValueKey {
    
    typealias Value = NonEquatableType
        
    static func fromAnyEquatable(_ value: AnyEquatable) -> Value? {
        guard let raw = value.base as? Int else { return nil}
        return Value(value: raw)
    }
    
    static func toAnyEquatable(_ value: Value) -> AnyEquatable {
        AnyEquatable(value.value)
    }
}

final class KeyWindowValueKey_AnyEquatable_Casting_Tests: XCTestCase {

    func testEquatable() {
        let any5 = Int.toAnyEquatable(5)
        let other5 = Int.toAnyEquatable(5)
        XCTAssertTrue(any5 == other5)
        let value = Int.fromAnyEquatable(any5)!
        XCTAssertEqual(value, 5)
    }
    
    func testNonEquatable() {
        let ne1 = NonEquatableType(value: 5)
        let ne2 = NonEquatableType(value: 5)
        let any1 = NonEquatableType.toAnyEquatable(ne1)
        let any2 = NonEquatableType.toAnyEquatable(ne2)
        XCTAssertTrue(any1 == any1)
        XCTAssertTrue(any2 == any2)
        XCTAssertFalse(any1 == any2)
        let n1unwrapped = NonEquatableType.fromAnyEquatable(any1)!
        XCTAssertEqual(n1unwrapped.value, 5)
    }
    
    func testCustomCast() {
        let ne1 = NonEquatableType(value: 5)
        let ne2 = NonEquatableType(value: 5)
        let any1 = CustomCastKey.toAnyEquatable(ne1)
        let any2 = CustomCastKey.toAnyEquatable(ne2)
        XCTAssertTrue(any1 == any2)
        
        let n1unwrapped = CustomCastKey.fromAnyEquatable(any1)!
        XCTAssertEqual(n1unwrapped.value, 5)
    }
}
