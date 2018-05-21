//
//  FetchInfo.swift
//  DUTInfoDemo
//
//  Created by shino on 2018/5/6.
//  Copyright © 2018 shino. All rights reserved.
//

import Fuzi
import PromiseKit
import AwaitKit

extension DUTInfo {
    public func fetchInfo() -> JSON {
        if fetches.count == 0 {
            return ""
        }
        do {
            try await(login())
            if (fetches.contains { $0.site == .teach }) {
                try await(loginTeach())
            }
            let value = try await(fetchInfo(fetches))
            let json = Dictionary(uniqueKeysWithValues: zip(fetches.map { $0.rawValue }, value))
            return Info.exportJson(json)
        } catch(let error) {
            print(error)
            return ""
        }
    }
    
    func fetchInfo(_ fetches: [DUTFetch]) -> Promise<[JSON]> {
        return async {
            let funcArray = fetches.map { DUTInfo.fetchFunc[$0.rawValue]! }
            return try await(when(fulfilled: funcArray.map { $0(self)() }))
        }
    }
}
