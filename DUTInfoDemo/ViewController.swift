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
        let fetch: [DUTFetch] = [.net, .person, .ecard, .course, .test, .library]
        dutInfo = DUTInfo(studentNumber: "学号", password: "校园门户密码", fetches: fetch)
        let json = dutInfo.fetchInfo()
        print(json)
    }
}
