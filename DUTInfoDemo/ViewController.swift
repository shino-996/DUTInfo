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
        dutInfo = DUTInfo(studentNumber: "学号", teachPassword: "教务处密码", portalPassword: "校园门户密码")
        let (cost, flow) = self.dutInfo.netInfo()
        let ecard = self.dutInfo.moneyInfo()
        let name = self.dutInfo.personInfo()
        print(cost)
        print(flow)
        print(ecard)
        print(name)
        let course = self.dutInfo.courseInfo()
        let test = self.dutInfo.testInfo()
        print(course)
        print(test)
    }
}
