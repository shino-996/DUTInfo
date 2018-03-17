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
        if dutInfo.loginPortal() {
            if let (cost, flow) = self.dutInfo.netInfo() {
                print(cost)
                print(flow)
            }
            if let ecard = self.dutInfo.moneyInfo() {
                print(ecard)
            }
            if let name = self.dutInfo.personInfo() {
                print(name)
            }
        }
        if dutInfo.loginTeachSite() {
            if let course = self.dutInfo.courseInfo() {
                print(course)
            }
            if let test = self.dutInfo.testInfo() {
                print(test)
            }
        }
    }
}
