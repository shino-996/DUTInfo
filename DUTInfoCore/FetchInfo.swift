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
        var value = [String: JSON]()
        if fetches.count == 0 {
            return ""
        }
        if let libraryRequest = (fetches.filter { $0.site == .library }).first {
            value[libraryRequest.rawValue] = libraryInfo()
        }
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "fetchinfo")
        firstly(execute: login)
        .done(on: queue) {
            if (self.fetches.filter { $0.site == .teach }).count != 0 {
                self.teach()
            }
            value.merge(self.fetchInfo(self.fetches.filter { $0.site != .library })) { origin, _ in origin }
        }.ensure(on: queue) {
            semaphore.signal()
        }.catch(on: queue) { error in
            print(error)
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return Info.exportJson(value)
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
    
    func fetchInfo(_ fetches: [DUTFetch]) -> [String: JSON] {
        var value = [String: JSON]()
        for fetch in fetches {
            var promise: Any = ()
            let semaphore = DispatchSemaphore(value: 0)
            let queue = DispatchQueue(label: "fetchrequest")
            switch fetch {
            case .course:
                promise = self.courseInfo
            case .test:
                promise = self.testInfo
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
                value[fetch.rawValue] = $0
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
