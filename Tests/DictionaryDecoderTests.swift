//
//  DictionaryDecoderTests.swift
//  MoreCodable
//
//  Created by Tatsuya Tanaka on 20180211.
//  Copyright © 2018年 tattn. All rights reserved.
//

import XCTest
@testable import MoreCodable

class DictionaryDecoderTests: XCTestCase {

    var decoder = DictionaryDecoder()

    override func setUp() {
        super.setUp()
        decoder = DictionaryDecoder()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDecodeSimpleModel() throws {
        struct User: Codable {
            let name: String
            let age: Int
        }

        let dictionary: [String: Any] = [
            "name": "Tatsuya Tanaka",
            "age": 24
        ]
        let user = try decoder.decode(User.self, from: dictionary)
        XCTAssertEqual(user.name, dictionary["name"] as? String)
        XCTAssertEqual(user.age, dictionary["age"] as? Int)
    }

    func testFailDecoding() {
        decoder.storage.push(container: "string"); do {
            let container = try! decoder.singleValueContainer()
            XCTAssertNil(try? container.decode(Bool.self))
        }

        struct CustomType: Decodable {
            let value: Int = 0
        }
        decoder = DictionaryDecoder()
        decoder.storage.push(container: CustomType()); do {
            let container = try! decoder.singleValueContainer()
            XCTAssertNil(try? container.decode(Bool.self))
        }
    }

    func testOptionalValues() throws {
        struct Model: Codable, Equatable {
            let int: Int?
            let string: String?
            let double: Double?
        }

        XCTAssertEqual(try decoder.decode(Model.self, from: ["int": 0, "string": "test"]), Model(int: 0, string: "test", double: nil))
        XCTAssertEqual(try decoder.decode(Model.self, from: ["double": 0.5, "string": "test"]), Model(int: nil, string: "test", double: 0.5))
    }
    
    func testDateValues() throws {
        struct Person: Codable, Equatable {
            var name: String
            var age: Int
            var birthday: Date
        }
        
        let now = Date()
        
        decoder.dateDecodingStrategy = .deferredToDate
        XCTAssertEqual(try decoder.decode(Person.self, from: ["name": "张三", "age": 18, "birthday": now]), Person(name: "张三", age: 18, birthday: now))
        
        decoder.dateDecodingStrategy = .secondsSince1970
        XCTAssertEqual(try decoder.decode(Person.self, from: ["name": "张三", "age": 18, "birthday": now.timeIntervalSince1970]), Person(name: "张三", age: 18, birthday: now))
        
        decoder.dateDecodingStrategy = .millisecondsSince1970
        XCTAssertEqual(try decoder.decode(Person.self, from: ["name": "张三", "age": 18, "birthday": now.timeIntervalSince1970 * 1000]), Person(name: "张三", age: 18, birthday: now))
    }
    
    func testURLValues() throws {
        struct Person: Codable, Equatable {
            var name: String
            var age: Int
            var homePage: URL?
        }
        
        XCTAssertEqual(try decoder.decode(Person.self, from: ["name": "张三", "age": 18, "homePage": "https://www.baidu.com"]), Person(name: "张三", age: 18, homePage: URL(string: "https://www.baidu.com")!))
        
        XCTAssertEqual(try decoder.decode(Person.self, from: ["name": "张三", "age": 18]), Person(name: "张三", age: 18, homePage: nil))        
    }
    
    func testDecimalValues() throws {
        struct Fruit: Codable, Equatable {
            var name: String
            var color: String
            var weight: Double
            var price: Decimal
        }
        
        XCTAssertEqual(try decoder.decode(Fruit.self, from: ["name": "Apple", "color": "red", "weight": 295.5, "price": 15.88]), Fruit(name: "Apple", color: "red", weight: 295.5, price: Decimal(15.88)))
    }
}
