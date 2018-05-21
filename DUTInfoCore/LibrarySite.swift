//
//  LibrarySite.swift
//  DUTInfoDemo
//
//  Created by shino on 2018/5/2.
//  Copyright © 2018 shino. All rights reserved.
//

import Fuzi
import PromiseKit

extension DUTInfo {
    func libraryInfo() -> JSON {
        var value = ""
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "libraryinfo")
        firstly { () -> Promise<Rsp> in
            let url = URL(string: "http://202.118.72.80/web/opentime_show.asp")!
            let request = URLRequest(url: url)
            return URLSession.shared.dataTask(.promise, with: request)
        }.map(on: queue, String.init)
        .done(on:queue) { str in
            guard let html = try? HTMLDocument(string: str) else {
                throw DUTError.htmlError
            }
            let pnode = html.xpath("/html/body/p")
            if pnode.count != 2 {
                throw DUTError.htmlError
            }
            let timeArray = pnode[1].stringValue.filter {
                ([((0 ... 9).map { "\($0)" }), ["-", "："]].flatMap { $0 }).contains(String($0))
            }.split {
                $0 == "-" || $0 == "："
            }
            let library = Info.Library(open: timeArray[0] + ":" + timeArray[1],
                                       close: timeArray[2] + ":" + timeArray[3])
            let encoder = JSONEncoder()
            let jsonData = try! encoder.encode(library)
            value = String(data: jsonData, encoding: .utf8)!
        }.ensure(on: queue) {
            semaphore.signal()
        }.catch(on: queue) { error in
            print(error)
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return value
    }
}
