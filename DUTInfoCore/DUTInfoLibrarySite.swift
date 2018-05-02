//
//  DUTInfoLibrarySite.swift
//  DUTInfoDemo
//
//  Created by shino on 2018/5/2.
//  Copyright © 2018 shino. All rights reserved.
//

import Fuzi
import PromiseKit

extension DUTInfo {
    public func openLibraryInfo() -> (open: String, close: String)? {
        var value: (String, String)?
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "space.shino.library")
        firstly { () -> Promise<Rsp> in
            let url = URL(string: "http://202.118.72.80/web/opentime_show.asp")!
            let request = URLRequest(url: url)
            return URLSession.shared.dataTask(.promise, with: request)
        }.map(on: queue, String.init).map(on:queue) { str in
            let htmlStr = try! HTMLDocument(string: str)
            var infoStr = htmlStr.body!.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: "：")
            _ = infoStr.removeFirst()
            if infoStr.count == 3 {
                let tmp = infoStr[1].split(separator: "-")
                let startDateStr = String(infoStr[0]) + ":" + String(tmp[0])
                let endDateStr = String(tmp[1]) + ":" + String(String(infoStr[2]).split(separator: "\r\n")[0])
                value = (startDateStr, endDateStr)
            }
        }.ensure(on: queue) {
            semaphore.signal()
        }.catch(on: queue) { error in
            print(error)
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return value
    }
}
