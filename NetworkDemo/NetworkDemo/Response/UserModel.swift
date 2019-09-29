//
//  UserModel.swift
//  NetworkDemo
//
//  Created by Mac on 2019/9/29.
//  Copyright © 2019 manman. All rights reserved.
//

import UIKit
import AutoSQLiteSwift

class UserModel: SQLiteModel {
    var token:String = "";
    var userId:String = "";
    var userType:Int = 0;
    var userName:String = "";
}
