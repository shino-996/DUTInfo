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

struct Course: Encodable {
    let name: String
    let teacher: String
    let time: [Time]?
}

struct Time: Encodable {
    let place: String
    let startsection: Int
    let endsection: Int
    let week: Int
    let teachweek: [Int]
}

struct Test: Encodable {
    let name: String
    let teachweek: String
    let date: String
    let time: String
    let place: String
}

struct Net: Encodable {
    let cost: Double
    let flow: Double
}

struct Library: Encodable {
    let open: String
    let close: String
}
