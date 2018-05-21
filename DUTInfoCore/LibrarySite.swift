//
//  LibrarySite.swift
//  DUTInfoDemo
//
//  Created by shino on 2018/5/2.
//  Copyright © 2018 shino. All rights reserved.
//

import Fuzi
import PromiseKit
import AwaitKit

extension DUTInfo {
    func libraryInfo() -> Promise<JSON> {
        return async {
            let url = URL(string: "http://202.118.72.80/web/opentime_show.asp")!
            let request = URLRequest(url: url)
            let libraryRsp = try await(self.session.dataTask(.promise, with: request))
            guard let html = try? HTMLDocument(string: String(rsp: libraryRsp)) else {
                throw DUTError.htmlError
            }
            let pnode = html.xpath("/html/body/p")
            if pnode.count != 2 {
                throw DUTError.htmlError
            }
            let timeArray = pnode[1].stringValue.filter {
                ([((0 ... 9).map { "\($0)" }), ["-", "："]].flatMap { $0 }).contains("\($0)")
            }.split {
                $0 == "-" || $0 == "："
            }
            let library = Info.Library(open: timeArray[0] + ":" + timeArray[1],
                                       close: timeArray[2] + ":" + timeArray[3])
            let encoder = JSONEncoder()
            let jsonData = try! encoder.encode(library)
            return String(data: jsonData, encoding: .utf8)!
        }
    }
}
