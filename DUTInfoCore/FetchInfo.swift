//
//  FetchInfo.swift
//  DUTInfoDemo
//
//  Created by shino on 2018/5/6.
//  Copyright © 2018 shino. All rights reserved.
//

import Fuzi
import PromiseKit

extension DUTInfo {
    public func fetchInfo() -> JSON {
        var value = [String: String]()
        if requests.count == 0 {
            return ""
        }
        if let libraryRequest = (requests.filter { $0.site == .library }).first {
            value[libraryRequest.rawValue] = libraryInfo()
        }
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "fetchinfo")
        firstly(execute: login)
        .done(on: queue) {
            if (self.requests.filter { $0.site == .teach }).count != 0 {
                self.teach()
            }
            value.merge(self.fetchInfo(self.requests.filter { $0.site != .library }), uniquingKeysWith: + )
        }.ensure(on: queue) {
            semaphore.signal()
        }.catch(on: queue) { error in
            print(error)
        }
        _ = semaphore.wait(timeout: .distantFuture)
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(value)
        return String(data: jsonData, encoding: .utf8)!
    }
    
    func teach() {
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "teach")
        firstly(execute: self.loginTeach)
            .ensure(on: queue) {
                semaphore.signal()
            }.catch(on: queue) { error in
                print(error)
        }
        _ = semaphore.wait(timeout: .distantFuture)
    }
    
    func fetchInfo(_ requests: [DUTInfoType]) -> [String: String] {
        var value = [String: String]()
        for request in requests {
            var promise: Any = ()
            let semaphore = DispatchSemaphore(value: 0)
            let queue = DispatchQueue(label: "fetchrequest")
            switch request {
            case .course:
                promise = self.courseInfo
            case .test:
                promise = self.testInfo
            case .grade:
                break
            case .net:
                promise = self.netInfo
            case .ecard:
                promise = self.ecardInfo
            case .person:
                promise = self.personInfo
            default:
                break
            }
            firstly(execute: promise as! () -> Promise<String>)
            .map(on: queue) {
                value[request.rawValue] = $0
            }.ensure(on: queue) {
                semaphore.signal()
            }.catch(on: queue) {
                print($0)
            }
            _ = semaphore.wait(timeout: .distantFuture)
        }
        return value
    }
}
