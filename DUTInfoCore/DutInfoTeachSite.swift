//
//  DutInfoTeachSite.swift
//  DUTInfomation
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

//接口
extension DUTInfo {
    //登录验证
    func loginTeachSite(succeed: @escaping () -> Void = {}, failed: @escaping () -> Void = {}) {
        firstly(execute: gotoTeachPage)
            .then(execute: teachLoginVerify)
            .then { (ifLogin: Bool) -> Void in
                if ifLogin {
                    succeed()
                }
            }.catch { error in
                print(error)
                failed()
            }
    }
    
    func courseInfo() {
        firstly(execute: gotoTeachPage)
            .then(execute: teachLoginVerify)
            .then(execute: gotoCoursePage)
            .then(execute: getCourse)
            .catch(execute: teachErrorHandle)
    }
    
    func gradeInfo() {
        firstly(execute: gotoTeachPage)
            .then(execute: teachLoginVerify)
            .then(execute: gotoGradePage)
            .then(execute: getGrade)
            .catch(execute: teachErrorHandle)
    }
    
    func testInfo() {
        firstly(execute: gotoTeachPage)
            .then(execute: teachLoginVerify)
            .then(execute: gotoTestPage)
            .then(execute: getTest)
            .catch(execute: teachErrorHandle)
    }
}

//干TM的GBK编码, 只有教务处网站会用到
extension Data {
    var unicodeString: String {
        if let string = String(data: self, encoding: .utf8) {
            return string
        }
        let cfEncoding = CFStringEncodings.GB_18030_2000
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
        return NSString(data: self, encoding: encoding)! as String
    }
}

//接口实现
extension DUTInfo {
    private func gotoTeachPage() -> URLDataPromise {
        let url = URL(string: "http://zhjw.dlut.edu.cn/loginAction.do")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = ("zjh=" + self.studentNumber + "&mm=" + self.teachPassword)
            .data(using: String.Encoding.utf8)
        teachSession = URLSession(configuration: .ephemeral)
        return teachSession.dataTask(with: request)
    }
    
    //验证是否登录成功
    private func teachLoginVerify(_ data: Data) throws -> Bool {
        let requestStr = data.unicodeString
        let parseStr = try! HTMLDocument(string: requestStr)
        let verifyStr = parseStr.title
        if verifyStr! != "学分制综合教务" {
            throw DUTError.authError
        }
        return true
    }
    
    //查询本学期课程
    //进入本学期选课界面
    private func gotoCoursePage(_: Bool) -> URLDataPromise {
        let url = URL(string: "http://zhjw.dlut.edu.cn/xkAction.do?actionType=6")!
        let request = URLRequest(url: url)
        return teachSession.dataTask(with: request)
    }
    
    //解析出各门课程
    private func getCourse(_ data: Data) {
        let requestString = data.unicodeString
        let pharseString = try! HTMLDocument(string: requestString)
        let courses = pharseString.xpath("//table[@class=\"displayTag\"]/tr[@class=\"odd\"]")
        var courseData = [[String: String]]()
        for course in courses {
            let items = course.xpath("./td")
            let weeknumber = items[11].stringValue
                .trimmingCharacters(in: .whitespaces)
                .filter {$0.unicodeScalars.first?.value ?? 128 < 128}
            let week = items[12].stringValue.trimmingCharacters(in: .whitespaces)
            let coursenumber = "第"
                + items[13].stringValue.trimmingCharacters(in: .whitespaces)
                + "节"
            let place = items[5].stringValue.trimmingCharacters(in: .whitespaces)
                + " "
                + items[6].stringValue.trimmingCharacters(in: .whitespaces)
            var courseDic = [
                "weeknumber": weeknumber,
                "week": week,
                "coursenumber": coursenumber,
                "place": place
            ]
            if items.count > 7 {
                let name = items[2].stringValue.trimmingCharacters(in: .whitespaces)
                let teacher = items[7].stringValue
                    .trimmingCharacters(in: .whitespaces)
                    .filter {$0 != "*"}
                courseDic["name"] = name
                courseDic["teacher"] = teacher
            } else {
                let lastCourse = courseData.last!
                courseDic["name"] = lastCourse["name"]!
                courseDic["teacher"] = lastCourse["teache"]!
            }
            courseData.append(courseDic)
        }
        delegate.setSchedule(courseData)
    }
    
    //查询本学期成绩
    //进入本学期成绩界面
    private func gotoGradePage(_: Bool) -> URLDataPromise {
        let url = URL(string: "http://zhjw.dlut.edu.cn/bxqcjcxAction.do")!
        let request = URLRequest(url: url)
        return teachSession.dataTask(with: request)
    }
    
    //解析出各科成绩
    private func getGrade(_ data: Data) {
        let requestString = data.unicodeString
        let pharseString = try! HTMLDocument(string: requestString)
        //找到分数所在的标签
        let courses = pharseString.xpath("//table[@class=\"displayTag\"]/tr[@class=\"odd\"]")
        for course in courses {
            for item in course.xpath("./td") {
                print(item.stringValue.trimmingCharacters(in: .whitespaces))
            }
        }
    }

    //查询考试安排
    //因为我小学期没有考试……等抓到有考试的人再用他的账号抓吧【
    private func gotoTestPage(_: Bool) -> URLDataPromise {
        let url = URL(string: "http://zhjw.dlut.edu.cn/ksApCxAction.do?oper=getKsapXx")!
        let request = URLRequest(url: url)
        return teachSession.dataTask(with: request)
    }
    
    private func getTest(_ data: Data) {
        let requestString = data.unicodeString
        let pharseString = try! HTMLDocument(string: requestString)
        let courses = pharseString.xpath("//table[@class=\"displayTag\"]/tr[@class=\"odd\"]")
        for course in courses {
            for item in course.xpath("./td") {
                print(item.stringValue)
            }
        }
    }

    private func teachErrorHandle(_ error: Error) {
        print(error)
        if let error = error as? DUTError {
            if error == .authError {
                print("教务处用户名或密码错误！")
            }
        } else {
            print("其他错误")
        }
        delegate.netErrorHandle()
    }
}
