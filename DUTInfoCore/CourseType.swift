//
//  CourseType.swift
//  DUTInfoDemo
//
//  Created by shino on 26/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import Foundation

public struct CourseType {
    public var name: String
    public var teacher: String
    public var time: [CourseTimeType]
    public init() {
        name = ""
        teacher = ""
        time = []
    }
}

public struct CourseTimeType {
    public var place: String
    public var startSection: Int
    public var endSection: Int
    public var week: Int
    public var teachWeek: [Int]
    public init() {
        place = ""
        startSection = 0
        endSection = 0
        week = 0
        teachWeek = []
    }
}
