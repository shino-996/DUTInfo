//
//  PortalSite.swift
//  DUTInfo
//
//  Created by shino on 2017/9/25.
//  Copyright © 2017年 shino. All rights reserved.
//

import Fuzi
import PromiseKit
import AwaitKit

//校园门户信息，可以通过外网访问
//http://portal.dlut.edu.cn/
extension DUTInfo {
    func netInfo() -> Promise<JSON> {
        return async {
            let netRsp = try await(self.fetchNetInfo())
            return self.parseNetInfo(netRsp)
        }
    }
    
    func ecardInfo() -> Promise<JSON> {
        return async {
            let ecardRsp = try await(self.fetchEcardInfo())
            return self.parseEcardInfo(ecardRsp)
        }
    }
    
    func personInfo() -> Promise<JSON> {
        return async {
            let personRsp = try await(self.fetchPersonInfo())
            return self.parsePersonInfo(personRsp)
        }
    }
    
    private func fetchNetInfo() -> Promise<Rsp> {
        let url = URL(string: "https://portal.dlut.edu.cn/tp/up/subgroup/getTrafficList")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{}".data(using: .utf8)
        return session.dataTask(.promise, with: request)
    }
    
    private func parseNetInfo(_ rsp: Rsp) -> JSON {
        struct NetInfo: Decodable {
            let fee: String
            let usedTraffic: String
        }
        let decoder = JSONDecoder()
        let netInfo = try! decoder.decode([NetInfo].self, from: rsp.data).first!
        let net =  Info.Net(cost: Double(netInfo.fee)!,
                       flow: 30720 - Double(netInfo.usedTraffic)!)
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(net)
        return String(data: jsonData, encoding: .utf8)!
    }
    
    private func fetchEcardInfo() -> Promise<Rsp> {
        let url = URL(string: "https://portal.dlut.edu.cn/tp/up/subgroup/getCardMoney")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{}".data(using: .utf8)
        return session.dataTask(.promise, with: request)
    }
    
    private func parseEcardInfo(_ rsp: Rsp) -> String {
        struct EcardInfo: Decodable {
            let cardbal: String
        }
        let decoder = JSONDecoder()
        let ecard = try! decoder.decode(EcardInfo.self, from: rsp.data)
        return ecard.cardbal
    }
    
    private func fetchPersonInfo() -> Promise<Rsp> {
        let url = URL(string: "https://portal.dlut.edu.cn/tp/sys/uacm/profile/getUserById")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let idString = DES.desStr(text: self.studentNumber, key_1: "tp", key_2: "des", key_3: "param")
        request.httpBody = """
            {
            "BE_OPT_ID": "\(idString)"
            }
            """.data(using: .utf8)
        return session.dataTask(.promise, with: request)
    }
    
    private func parsePersonInfo(_ rsp: Rsp) -> String {
        struct PersonInfo: Decodable {
            let USER_NAME: String
        }
        let decoder = JSONDecoder()
        let personInfo = try! decoder.decode(PersonInfo.self, from: rsp.data)
        return personInfo.USER_NAME
    }

}
