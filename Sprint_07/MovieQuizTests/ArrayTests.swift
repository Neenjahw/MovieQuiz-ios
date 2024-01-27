//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Pavel Popov on 25.01.2024.
//

import Foundation
import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        
        let array = [1, 2, 3, 4, 5]
        
        let value = array[safe: 2]
        
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
    }
    
    func testGetValueOutOfRange() throws {
        let array = [1, 2, 3, 4, 5]
    
        let value = array[safe: 20]
        
        XCTAssertNil(value)
    }
}