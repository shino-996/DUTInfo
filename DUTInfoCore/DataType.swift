//
//  CourseType.swift
//  DUTInfoDemo
//
//  Created by shino on 26/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import Foundation

// 数据格式, 输出均转换为 json

public typealias JSON = String

// Promisekit 中请求类型的别名
typealias Rsp = (data: Data, response: URLResponse)

struct Info: Codable {
    let course: [Course]?
    let test: [Test]?
    let net: Net?
    let person: String?
    let ecard: Double?
    let library: Library?
    
    static func exportJson(_ value: [String: JSON]) -> JSON {
        var course: [Course]?
        var test: [Test]?
        var net: Net?
        var person: String?
        var ecard: Double?
        var library: Library?
        let decoder = JSONDecoder()
        if let courseData = value["course"]?.data(using: .utf8) {
            course = try? decoder.decode([Course].self, from: courseData)
        }
        if let testData = value["test"]?.data(using: .utf8) {
            test = try? decoder.decode([Test].self, from: testData)
        }
        if let netData = value["net"]?.data(using: .utf8) {
            net = try? decoder.decode(Net.self, from: netData)
        }
        person = value["person"]
        if let ecardString = value["ecard"] {
            ecard = Double(ecardString)
        }
        if let libraryData = value["library"]?.data(using: .utf8) {
            library = try? decoder.decode(Library.self, from: libraryData)
        }
        let info = Info(course: course,
                    test: test,
                    net: net,
                    person: person,
                    ecard: ecard,
                    library: library)
        let jsonData = try! JSONEncoder().encode(info)
        return String(data: jsonData, encoding: .utf8)!
    }

    struct Course: Codable {
        let name: String
        let teacher: String
        let time: [Time]?
        
        struct Time: Codable {
            let place: String
            let startsection: Int
            let endsection: Int
            let week: Int
            let teachweek: [Int]
        }
    }

    struct Test: Codable {
        let name: String
        let teachweek: String
        let date: String
        let time: String
        let place: String
    }

    struct Net: Codable {
        let cost: Double
        let flow: Double
    }

    struct Library: Codable {
        let open: String
        let close: String
    }
}
