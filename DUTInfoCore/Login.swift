//
//  Login.swift
//  DUTInfo
//
//  Created by shino on 2018/5/5.
//  Copyright © 2018 shino. All rights reserved.
//

import Fuzi
import PromiseKit

// 登录请求和登录验证
extension DUTInfo {
    public func login() -> Bool {
        var value = false
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "login.promise")
        firstly {
            return login()
        }.done(on: queue) {
            value = true
        }.ensure(on: queue) {
            semaphore.signal()
        }.catch(on: queue) { error in
            print(error)
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return value
    }
    
    // 把两步的登录 Promise 封装成一个 Promise
    func login() -> Promise<Void> {
        return Promise { resolve in
            let queue = DispatchQueue(label: "login.promise")
            firstly(execute: fetchCookie)
            .then(on: queue, postLogin)
            .done(on: queue) {
                if self.loginVerify($0) {
                    resolve.fulfill(())
                } else {
                    throw DUTError.authError
                }
            }.catch(on: queue) {
                resolve.reject($0)
            }
        }
    }
    
    // 合并登录教务处网站的 Promise 合并成一个 Promise
    // 需要在登录统一验证之后才可以登录教务处
    func loginTeach() -> Promise<Void> {
        return Promise { resolve in
            let queue = DispatchQueue(label: "loginteach.promise")
            firstly(execute: jumpTeach)
            .then(on: queue, fetchTeachPage)
            .map(on: queue, teachLoginVerify)
            .done(on: queue) {
                if $0 {
                    resolve.fulfill(())
                } else {
                    throw DUTError.authError
                }
            }.catch(on: queue) {
                resolve.reject($0)
            }
        }
    }
}

extension DUTInfo {
    func fetchCookie() -> Promise<Rsp> {
        let url = URL(string: "https://sso.dlut.edu.cn/cas/login" + DUTSite.portal.rawValue)!
        let request = URLRequest(url: url)
        return session.dataTask(.promise, with: request)
    }
    
    func postLogin(_ rsp: Rsp) throws -> Promise<Rsp> {
        guard let html = try? HTMLDocument(data: rsp.data) else {
            throw DUTError.htmlError
        }
        let lt_ticket = html.body?.xpath("//*[@id=\"lt\"]").first?.attr("value") ?? ""
        guard let cookieStorage = session.configuration.httpCookieStorage else {
            throw DUTError.cookieError
        }
        guard let cookies = cookieStorage.cookies(for: URL(string: "https://sso.dlut.edu.cn")!) else {
            throw DUTError.cookieError
        }
        let cookieString = "jsessionid=" +
            ((cookies.filter { $0.name == "JSESSIONID" }.first?.value) ?? "")
        let url = URL(string: "https://sso.dlut.edu.cn/cas/login;" + cookieString + DUTSite.portal.rawValue)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = ("rsa=" +
            DES.desStr(text: studentNumber + password + lt_ticket,
                       key_1: "1", key_2: "2", key_3: "3") +
            "&ul=9" +
            "&pl=14" +
            "&lt=" +
            lt_ticket +
            "&execution=e1s1" +
            "&_eventId=submit").data(using: .utf8)!
        return session.dataTask(.promise, with: request)
    }
    
    func jumpTeach() -> Promise<Rsp> {
        let url = URL(string: "https://sso.dlut.edu.cn/cas/login" + DUTSite.teach.rawValue)!
        let request = URLRequest(url: url)
        return session.dataTask(.promise, with: request)
    }
    
    func fetchTeachPage(_ rsp: Rsp) throws -> Promise<Rsp> {
        guard let html = try? HTMLDocument(data: rsp.data) else {
            throw DUTError.htmlError
        }
        let url = URL(string: "http://zhjw.dlut.edu.cn")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let logintype = html.xpath("//*[@id=\"logintype\"]").first?.attr("value") ?? ""
        let un = html.xpath("//*[@id=\"un\"]").first?.attr("value") ?? ""
        let verify = html.xpath("//*[@id=\"verify\"]").first?.attr("value") ?? ""
        let time = html.xpath("//*[@id=\"time\"]").first?.attr("value") ?? ""
        let _url = html.xpath("//*[@id=\"url\"]").first?.attr("value") ?? ""
        request.httpBody = ("logintype=" + logintype +
            "&un=" + un +
            "&verify=" + verify +
            "&time=" + time +
            "&url=" +  _url).data(using: .utf8)
        return session.dataTask(.promise, with: request)
    }
    
    func loginVerify(_ rsp: Rsp) -> Bool {
        let verifyString = String(rsp: rsp)
        return verifyString.hasPrefix("<META http-equiv=\"Refresh\" content=\"0; url=")
    }
    
    func teachLoginVerify(_ rsp: Rsp) -> Bool {
        let str = String(rsp: rsp)
        let htmlStr = try! HTMLDocument(string: str)
        let verifyStr = htmlStr.title
        return verifyStr! == "学分制综合教务"
    }
}
