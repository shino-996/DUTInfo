//
//  TeachSite.swift
//  DUTInfo
//
//  Created by shino on 2017/9/13.
//  Copyright © 2017年 shino. All rights reserved.
//

import Foundation
import Fuzi
import PromiseKit

//教务处网站信息，只有在校园网内网可以访问
//http://zhjw.dlut.edu.cn
//登录教务处网站

//干TM的GBK编码, 只有教务处网站会用到
extension String {
    init(rsp: Rsp) {
        if let str = String(data: rsp.data, encoding: .utf8) {
            self = str
        } else {
            let cfEncoding = CFStringEncodings.GB_18030_2000
            let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
            self = NSString(data: rsp.data, encoding: encoding)! as String
        }
    }
}

extension DUTInfo {
    func courseInfo() -> Promise<JSON> {
        return Promise { resolve in
            let queue = DispatchQueue(label: "courseinfo.promise")
            firstly(execute: fetchCourse)
            .map(on:queue, evaluateVerify)
            .map(on: queue, parseCourse)
            .done(on: queue) {
                resolve.fulfill($0)
            }.catch(on: queue) {
                resolve.reject($0)
            }
        }
    }
    
    func testInfo() -> Promise<JSON> {
        return Promise { resolve in
            let queue = DispatchQueue(label: "testinfo.promise")
            firstly(execute: fetchTest)
            .map(on: queue, parseTest)
            .map(on: queue) {
                resolve.fulfill($0)
            }.catch(on: queue) {
                resolve.reject($0)
            }
        }
    }
    
    //查询本学期课程
    //进入本学期选课界面
    private func fetchCourse() -> Promise<Rsp> {
        let url = URL(string: "http://zhjw.dlut.edu.cn/xkAction.do?actionType=6")!
        let request = URLRequest(url: url)
        return session.dataTask(.promise, with: request)
    }
    
    private func evaluateVerify(_ rsp: Rsp) throws -> String {
        let str = String(rsp: rsp)
        let parseString = try! HTMLDocument(string: str)
        guard let verifyStr = parseString.title else {
            return str
        }
        if verifyStr.trimmingCharacters(in: .whitespacesAndNewlines) == "错误信息" {
            throw DUTError.evaluateError
        } else {
            return str
        }
    }
    
    //解析出各门课程
    private func parseCourse(_ string: String) -> JSON {
        let parseString = try! HTMLDocument(string: string)
        let courseSource = parseString.xpath("//table[@class=\"displayTag\"]/tr[@class=\"odd\"]")
        var courses = [Info.Course]()
        for courseData in courseSource {
            let items = courseData.xpath("./td")
            if items.count > 7 {
                let name = items[2].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                let teacher = items[7].stringValue
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .filter {$0 != "*"}
                let teachWeeks = items[11].stringValue
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .filter {$0.unicodeScalars.first?.value ?? 128 < 128}
                    .split(separator: "-")
                if teachWeeks.count == 0 {
                    let course = Info.Course(name: name,
                                        teacher: teacher,
                                        time: nil)
                    courses.append(course)
                    continue
                }
                let startTeachWeek = Int(teachWeeks.first!)!
                let endTeachWeek = Int(teachWeeks.last!)!
                let teachweek = (startTeachWeek ... endTeachWeek).map { $0 }
                let week = Int(items[12].stringValue.trimmingCharacters(in: .whitespacesAndNewlines))!
                let startsection = Int(items[13].stringValue.trimmingCharacters(in: .whitespacesAndNewlines))!
                let endsection = startsection - 1 +  Int(items[14].stringValue.trimmingCharacters(in: .whitespacesAndNewlines))!
                let place = items[16].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    + " "
                    + items[17].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                let courseTime = Info.Course.Time(place: place,
                                      startsection: startsection,
                                      endsection: endsection,
                                      week: week,
                                      teachweek: teachweek)
                let course = Info.Course(name: name,
                                    teacher: teacher,
                                    time: [courseTime])
                courses.append(course)
            } else {
                let course = courses.popLast()!
                let teachWeeks = items[0].stringValue
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .filter {$0.unicodeScalars.first?.value ?? 128 < 128}
                    .split(separator: "-")
                if teachWeeks.count == 0 {
                    courses.append(course)
                    continue
                }
                let startTeachWeek = Int(teachWeeks.first!)!
                let endTeachWeek = Int(teachWeeks.last!)!
                let teachweek = (startTeachWeek ... endTeachWeek).map { $0 }
                let week = Int(items[1].stringValue.trimmingCharacters(in: .whitespacesAndNewlines))!
                let startsection = Int(items[2].stringValue.trimmingCharacters(in: .whitespacesAndNewlines))!
                let endsection = startsection - 1 + Int(items[3].stringValue.trimmingCharacters(in: .whitespacesAndNewlines))!
                let place = items[5].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    + " "
                    + items[6].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                let courseTime = Info.Course.Time(place: place,
                                startsection: startsection,
                                endsection: endsection,
                                week: week,
                                teachweek: teachweek)
                if let time = course.time {
                    let newCourse = Info.Course(name: course.name,
                                           teacher: course.teacher,
                                           time: [[courseTime], time].flatMap { $0 })
                    courses.append(newCourse)
                } else {
                    let newCourse = Info.Course(name: course.name,
                                           teacher: course.teacher,
                                           time: [courseTime])
                    courses.append(newCourse)
                }
            }
        }
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(courses)
        return String(data: jsonData, encoding: .utf8)!
    }
    
    //查询本学期成绩
    //进入本学期成绩界面
    private func fetchGrade() -> Promise<Rsp> {
        let url = URL(string: "http://zhjw.dlut.edu.cn/bxqcjcxAction.do")!
        let request = URLRequest(url: url)
        return session.dataTask(.promise, with: request)
    }
    
    //解析出各科成绩
    private func parseGrade(_ rsp: Rsp) {
        let str = String(rsp: rsp)
        let parseString = try! HTMLDocument(string: str)
        //找到分数所在的标签
        let courses = parseString.xpath("//table[@class=\"displayTag\"]/tr[@class=\"odd\"]")
        for course in courses {
            for item in course.xpath("./td") {
                print(item.stringValue.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }

    //查询考试安排
    private func fetchTest() -> Promise<Rsp> {
        let url = URL(string: "http://zhjw.dlut.edu.cn/ksApCxAction.do?oper=getKsapXx")!
        let request = URLRequest(url: url)
        return session.dataTask(.promise, with: request)
    }
    // 解析考试信息
    private func parseTest(_ rsp: Rsp) -> JSON {
        let str = String(rsp: rsp)
        let parseString = try! HTMLDocument(string: str)
        let courses = parseString.xpath("//table[@class=\"displayTag\"]/tr[@class=\"odd\"]")
        var testData = [Info.Test]()
        for course in courses {
            let item = course.xpath("./td")
            let name = item[4].stringValue
            let teachweek = item[0].stringValue.filter{ $0.unicodeScalars.first?.value ?? 128 < 128 }
            let date = item[5].stringValue
            let time = item[6].stringValue
            let place = item[2].stringValue + " " + item[3].stringValue
            let test = Info.Test(name: name,
                            teachweek: teachweek,
                            date: date,
                            time: time,
                            place: place)
            testData.append(test)
        }
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(testData)
        return String(data: jsonData, encoding: .utf8)!
    }
}
