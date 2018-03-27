//
//  CourseType.swift
//  DUTInfoDemo
//
//  Created by shino on 26/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import Foundation

public struct CourseType {
    var name: String = ""
    var teacher: String = ""
    var time: [CourseTimeType] = [CourseTimeType]()
}

public struct CourseTimeType {
    var place: String = ""
    var startSection: Int = 0
    var endSection: Int = 0
    var week: Int = 0
    var teachWeek: [Int] = [Int]()
}
