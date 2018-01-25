//
//  ViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/7/3.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DUTInfoDelegate {
    var dutInfo: DUTInfo!
    override func viewDidLoad() {
        super.viewDidLoad()
        dutInfo = DUTInfo(studentNumber: "学号", teachPassword: "教务处密码", portalPassword: "教务处密码")
        dutInfo.delegate = self
        dutInfo.loginNewPortalSite(succeed: { [unowned self] in
            self.dutInfo.newPortalNetInfo()
        }) {
            print("error")
        }
    }
    
    func setNetCost(_ netCost: String) {
        print(netCost)
    }
    
    func setNetFlow(_ netFlow: String) {
        print(netFlow)
    }
    
    func setEcardCost(_ ecardCost: String) {
        print(ecardCost)
    }
    
    func setSchedule(_ courseArray: [[String : String]]) {
        print(courseArray)
    }
    
    func setTest(_ testArray: [[String : String]]) {
        print(testArray)
    }
    
    func setPersonName(_ personName: String) {
        print(personName)
    }
    
    func netErrorHandle(_ error: Error) {
        print(error)
        if let error = error as? DUTError {
            if error == DUTError.authError {
                print("登录错误")
            } else if error == DUTError.evaluateError {
                print("未完成教学评估")
            }
        } else {
            print("网络错误")
        }
    }
}

