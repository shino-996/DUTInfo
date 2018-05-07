//
//  ViewController.swift
//  DUTInfo
//
//  Created by shino on 2017/7/3.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var dutInfo: DUTInfo!
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetch: [DUTFetch] = [.net, .course, .test, .library]
        dutInfo = DUTInfo(studentNumber: "学号", password: "教务处密码", fetches: fetch)
        let value = dutInfo.fetchInfo()
        struct Info: Decodable {
            let net: Net
            struct Net: Decodable {
                let cost: Double
                let flow: Double
            }
        }
        let decoder = JSONDecoder()
        let info = try! decoder.decode(Info.self, from: value.data(using: .utf8)!)
        print(info.net)
    }
}
