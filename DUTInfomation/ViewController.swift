//
//  ViewController.swift
//  DUTInfomation
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
        DispatchQueue.global().async {
            let (cost, flow) = self.dutInfo.portalNetInfo()
            let ecard = self.dutInfo.portalMoneyInfo()
            let name = self.dutInfo.portalPersonInfo()
            print(cost)
            print(flow)
            print(ecard)
            print(name)
        }
        DispatchQueue.global().async {
            let course = self.dutInfo.courseInfo()
            let test = self.dutInfo.testInfo()
            print(course)
            print(test)
        }
    }
}
