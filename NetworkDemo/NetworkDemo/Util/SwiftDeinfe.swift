//
//  SwiftDeinfe.swift
//  NetworkDemo
//
//  Created by Mac on 2019/9/29.
//  Copyright © 2019 manman. All rights reserved.
//

import Foundation

// 服务器地址
let kGraphQLEndpoint = "https://onapi2.weixin-jp.com:4000/graphql"

// token
let kLoginToken = "kLoginToken"

// 登陆个人信息归档Url
let kUserInforPathUrl:URL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]).appendingPathComponent("userModelFile")
