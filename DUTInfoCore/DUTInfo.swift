//
//  TeachInfo.swift
//  DUTInfomation
//
//  Created by shino on 2017/7/3.
//  Copyright © 2017年 shino. All rights reserved.
//

import PromiseKit
import Fuzi
import Foundation

public protocol DUTInfoDelegate: AnyObject {
    //当DUTInfo属性更改时会调用的委托方法
    func setNetCost(_ netCost: String)
    func setNetFlow(_ netFlow: String)
    func setEcardCost(_ ecardCost: String)
    func setSchedule(_ courseArray: [[String: String]])
    func setTest(_ testArray: [[String : String]])
    func setPersonName(_ personName: String)
}

//可能会遇到的错误类型
public enum DUTError: Error {
    case authError
    case evaluateError
    case netError
    case otherError
}

public class DUTInfo: NSObject {
    //学号
    public var studentNumber: String
    //教务处密码，默认为身份证号后6位
    public var teachPassword: String
    //校园门户密码，默认为身份证号后6位
    public var portalPassword: String
    
    //用于网络请求的session
    //新版校园门户
    var newPortalSession: URLSession!
    //教务处
    var teachSession: URLSession!
    // 校园网
    var netSession: URLSession!
    
    //委托对象，用于属性更新时的回调
    public weak var delegate: DUTInfoDelegate?
        
    public override init() {
        studentNumber = ""
        teachPassword = ""
        portalPassword = ""
    }
    
    public init(studentNumber: String, teachPassword: String, portalPassword: String) {
        self.studentNumber = studentNumber
        self.teachPassword = teachPassword
        self.portalPassword = portalPassword
    }
    
    public var netCost: String! {
        didSet {
            delegate?.setNetCost(netCost)
        }
    }
    public var netFlow: String! {
        didSet {
            delegate?.setNetFlow(netFlow)
        }
    }
    public var ecardCost: String! {
        didSet {
            delegate?.setEcardCost(ecardCost)
        }
    }
    
    public var personName: String! {
        didSet {
            delegate?.setPersonName(personName)
        }
    }
}
