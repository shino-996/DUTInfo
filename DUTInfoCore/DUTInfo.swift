//
//  TeachInfo.swift
//  DUTInfo
//
//  Created by shino on 2017/7/3.
//  Copyright © 2017年 shino. All rights reserved.
//

import PromiseKit
import Fuzi
import Foundation

//可能会遇到的错误类型
public enum DUTError: Error {
    case authError
    case evaluateError
    case netError
    case htmlError
    case cookieError
    case otherError
}

// 登录网站种类
enum DUTSite: String {
    case portal = "?service=https%3A%2F%2Fportal.dlut.edu.cn%2Ftp%2F"
    case teach = "?service=https%3A%2F%2Fportal.dlut.edu.cn%2Fsso%2Fsso_jw.jsp"
    case library
}

// 请求信息种类
public enum DUTFetch: String {
    case net
    case ecard
    case person
    case course
    case test
    case grade
    case library
}

extension DUTFetch {
    var site: DUTSite {
        switch self {
        case .net:
            return .portal
        case .ecard:
            return .portal
        case .person:
            return .portal
        case .course:
            return .teach
        case .test:
            return .teach
        case .grade:
            return .teach
        case.library:
            return .library
        }
    }
}

public struct DUTInfo {
    //学号
    public let studentNumber: String
    //校园门户密码，默认为身份证号后6位
    public let password: String
    
    public let fetches: [DUTFetch]
    
    //用于网络请求的session
    let session = URLSession(configuration: .ephemeral)
    
    public init(studentNumber: String, password: String, fetches: [DUTFetch]) {
        self.studentNumber = studentNumber
        self.password = password
        self.fetches = fetches
    }
}
