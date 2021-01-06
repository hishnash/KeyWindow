//
//  AnyEquatableTests.swift
//  
//
//  Created by Matthaus Woolard on 06/01/2021.
//

import KeyWindow
import XCTest


final class AnyEquatableTests: XCTestCase {

    func testEquatableSameTypeEqual() {
        XCTAssertEqual(AnyEquatable(5 as Int), AnyEquatable(5 as Int))
    }
    
    func testNotEquatableSameType() {
        XCTAssertNotEqual(AnyEquatable(5 as Int), AnyEquatable(6 as Int))
    }
    
    func testNotEquatableDifferentType() {
        XCTAssertNotEqual(AnyEquatable(5 as Int), AnyEquatable(5 as UInt))
    }
    
    func testNotEquatableRelatedTypes() {
        XCTAssertNotEqual(AnyEquatable(A(value: 5)), AnyEquatable(B(value: 5)))
        XCTAssertNotEqual(AnyEquatable(B(value: 5)), AnyEquatable(A(value: 5)))
    }
    
    func testEquatableCustomRepresentationTypes() {
        XCTAssertEqual(AnyEquatable(CustomEquatableAsInt(value: 5)), AnyEquatable(CustomEquatableAsInt(value: 5)))
    }
    
    func testNotEquatableCustomRepresentationTypes() {
        XCTAssertNotEqual(AnyEquatable(CustomEquatableAsInt(value: 5)), AnyEquatable(CustomEquatableAsInt(value: 6)))
    }
    
    func testEquatableCustomRepresentationTypesMixedWithCastType() {
        XCTAssertEqual(AnyEquatable(CustomEquatableAsInt(value: 5)), AnyEquatable(5))
    }
}


fileprivate class A: Equatable {
    static func == (lhs: A, rhs: A) -> Bool {
        lhs.value == rhs.value
    }
    
    internal init(value: Int) {
        self.value = value
    }
    
    let value: Int
}

fileprivate class B: A {}

fileprivate struct CustomEquatableAsInt: _HasCustomAnyEquatableRepresentation {
    let value: Int
    
    __consuming func _toCustomAnyEquatable() -> AnyEquatable {
        AnyEquatable(self.value)
    }
}

