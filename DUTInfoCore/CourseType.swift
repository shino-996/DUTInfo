//
//  CourseType.swift
//  DUTInfoDemo
//
//  Created by shino on 26/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import Foundation

public protocol CourseType {
    associatedtype TimeType: CourseTimeType
    var name: String { get set }
    var teacher: String { get set }
    var time: [TimeType] { get set }
    init()
}

public protocol CourseTimeType {
    var place: String { get set }
    var startSection: Int { get set }
    var endSection: Int { get set }
    var week: Int { get set }
    var teachWeek: [Int] { get set }
    init()
}
