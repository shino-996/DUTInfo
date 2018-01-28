//
//  DutInfoNewPortalSite.swift
//  DUTInfomation
//
//  Created by shino on 2017/9/25.
//  Copyright © 2017年 shino. All rights reserved.
//

import Foundation
import Fuzi
import PromiseKit
import JavaScriptCore

//新版校园门户信息，可以通过外网访问
//http://one.dlut.edu.cn/

//接口
extension DUTInfo {
    public func loginNewPortalSite(succeed: @escaping () -> Void = {}, failed: @escaping () -> Void = {}) {
        firstly(execute: gotoNewPortalPage)
            .then(execute: loginNewPortal)
            .then(execute: newPortalLoginVerify)
            .then { (isLogin: Bool) -> Void in
                if isLogin {
                    succeed()
                }
            }.catch { error in
                print(error)
                failed()
            }
    }
    
    public func newPortalNetInfo() {
        firstly(execute: gotoNewPortalPage)
            .then(execute: loginNewPortal)
            .then(execute: newPortalLoginVerify)
            .then(execute: getNewPortalNetInfo)
            .then(execute: parseNewPortalNetInfo)
            .then(execute: getNewPortalMoneyInfo)
            .then(execute: parseNewPortalMoneyInfo)
            .catch { error in
                print(error)
        }
    }
    
    public func newPortalPersonInfo() {
        firstly(execute: gotoNewPortalPage)
            .then(execute: loginNewPortal)
            .then(execute: newPortalLoginVerify)
            .then(execute: getNewPortalPersonInfo)
            .then(execute: parseNewPortalPersonInto)
            .catch { error in
                print(error)
        }
        
    }
}

//接口实现
extension DUTInfo {
    private func gotoNewPortalPage() -> URLDataPromise {
        let url = URL(string: "https://sso.dlut.edu.cn/cas/login?service=https%3A%2F%2Fportal.dlut.edu.cn%2Ftp%2F")!
        let request = URLRequest(url: url)
        newPortalSession = URLSession(configuration: .ephemeral)
        return newPortalSession.dataTask(with: request)
    }
    
    //额……新版的门户登录验证信息用了DES加密，我就直接运行js版的算法，不改成swift了
    private func desEncode(_ text: String) -> String {
        guard let jscontext = JSContext() else {
            fatalError()
        }
        if let jsPath = Bundle.main.path(forResource: "des", ofType: "js") {
            let jsStr = try! String(contentsOfFile: jsPath)
            _ = jscontext.evaluateScript(jsStr)
        } else {
            fatalError()
        }
        guard let jsFunc = jscontext.objectForKeyedSubscript("strEnc") else {
            fatalError()
        }
        guard let encode = jsFunc.call(withArguments: [text, "1", "2", "3"]) else {
            fatalError()
        }
        return encode.toString()
    }
    
    private func loginNewPortal(_ data: Data) throws -> URLDataPromise {
        let parseStr = try! HTMLDocument(data: data)
        let lt_ticket = parseStr.body?.children[0].children[6].attr("value")
        guard let cookieStorage = newPortalSession.configuration.httpCookieStorage else {
            print("no cookie")
            throw DUTError.authError
        }
        guard let cookies = cookieStorage.cookies(for: URL(string: "https://sso.dlut.edu.cn")!) else {
            print("no cookie array")
            throw DUTError.authError
        }
        var cookieString = "jsessionid="
        for cookie in cookies {
            if cookie.name == "JSESSIONID" {
                cookieString += cookie.value
            }
        }
        let url = URL(string: "https://sso.dlut.edu.cn/cas/login;" + cookieString + "?service=https%3A%2F%2Fportal.dlut.edu.cn%2Ftp%2F")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = ("rsa=" + self.desEncode(studentNumber + portalPassword + lt_ticket!) + "&ul=9&pl=14&" + lt_ticket! + "&execution=e1s1&_eventId=submit").data(using: .utf8)!
        return newPortalSession.dataTask(with: request)
    }
    
    private func newPortalLoginVerify(_ data: Data) throws -> Bool {
        let verifyStr = String(data: data, encoding: .utf8)!
        if verifyStr.hasPrefix("<META http-equiv=\"Refresh\" content=\"0; url=") {
            return true
        } else {
            throw DUTError.authError
        }
    }
    
    private func newPortalLoginVerify(_ data: Data) throws {
        let verifyStr = String(data: data, encoding: .utf8)!
        if verifyStr.hasPrefix("<META http-equiv=\"Refresh\" content=\"0; url=") {
            return
        } else {
            throw DUTError.authError
        }
    }
    
    private func getNewPortalNetInfo() -> URLDataPromise {
        let url = URL(string: "https://portal.dlut.edu.cn/tp/up/subgroup/getTrafficList")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{}".data(using: .utf8)
        return newPortalSession.dataTask(with: request)
    }
    
    private func parseNewPortalNetInfo(_ netInfoData: Data) -> Void {
        let jsonArray = try! JSONSerialization.jsonObject(with: netInfoData)
                   as! [[String: String]]
        let json = jsonArray[0]
        netCost = json["fee"]! + "元"
        let flow = 30720 - Double(json["usedTraffic"]!)!
        if flow < 1024 {
            netFlow = "\(flow))MB"
        } else {
            netFlow = String(format: "%.1lfGB", flow / 1024)
        }
    }
    
    private func getNewPortalMoneyInfo() -> URLDataPromise {
        let url = URL(string: "https://portal.dlut.edu.cn/tp/up/subgroup/getCardMoney")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{}".data(using: .utf8)
        return newPortalSession.dataTask(with: request)
    }
    
    private func parseNewPortalMoneyInfo(_ moneyInfoData: Data) -> Void {
        let json = try! JSONSerialization.jsonObject(with: moneyInfoData)
                   as! [String: String]
        ecardCost = json["cardbal"]! + "元"
    }
    
    private func getNewPortalPersonInfo() -> URLDataPromise {
        let url = URL(string: "https://portal.dlut.edu.cn/tp/sys/uacm/profile/getUserById")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = """
        {
            "ID_NUMBER": "\(self.studentNumber)"
        }
        """.data(using: .utf8)
        return newPortalSession.dataTask(with: request)
    }
    
    private func parseNewPortalPersonInto(_ personInfoData: Data) -> Void {
        let json = try! JSONSerialization.jsonObject(with: personInfoData)
                   as! [String: Any]
        personName = json["USER_NAME"] as! String
    }
    
    private func newPortalErrorHandle(_ error: Error) {
        print(error)
        if let error = error as? DUTError {
            if error == .authError {
                print("新版校园门户用户名或密码错误！")
            }
        } else {
            print("其他错误")
        }
        delegate?.netErrorHandle(error)
    }
}
