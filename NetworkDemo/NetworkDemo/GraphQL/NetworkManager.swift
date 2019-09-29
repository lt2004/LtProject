//
//  NetworkManager.swift
//  NetworkDemo
//
//  Created by Mac on 2019/9/29.
//  Copyright © 2019 manman. All rights reserved.
//

import UIKit
import Apollo
import AutoSQLiteSwift

enum NetworkTye {
    case Login // 登陆
}


class NetworkManager: NSObject {
    // 单例
    static let sharedInstance: NetworkManager = {
        let shareInstance = NetworkManager()
        return shareInstance;
    }()
    
    var apollo: ApolloClient = {
        
        let url = URL(string: kGraphQLEndpoint)!
        
        let configuration = URLSessionConfiguration.default
        
        var token = "";
        if UserDefaults.standard.value(forKey: kLoginToken) != nil {
            token = UserDefaults.standard.value(forKey: kLoginToken) as! String
        }
        configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(token)"]
        let urlSession : URLSession = URLSession(configuration: configuration);
        
        let transport:HTTPNetworkTransport = HTTPNetworkTransport(url: url, session: urlSession, sendOperationIdentifiers: false, useGETForQueries: false, delegate: nil, requestCreator: ApolloRequestCreator())
        return ApolloClient(networkTransport: transport)
    }()
    
    // MRK:登陆需要重新设置token
    func setApolloClientToken(){
        self.apollo = {
            let url = URL(string: kGraphQLEndpoint)!
            
            let configuration = URLSessionConfiguration.default
            
            var token = "";
            if UserDefaults.standard.value(forKey: kLoginToken) != nil {
                token = UserDefaults.standard.value(forKey: kLoginToken) as! String
            }
            configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(token)"]
            let urlSession : URLSession = URLSession(configuration: configuration);
            
            let transport:HTTPNetworkTransport = HTTPNetworkTransport(url: url, session: urlSession, sendOperationIdentifiers: false, useGETForQueries: false, delegate: nil, requestCreator: ApolloRequestCreator())
            return ApolloClient(networkTransport: transport)
        }()
    }
    
    // MARK:通用请求方法
    func commonQuery<Query: GraphQLQuery>(query: Query, networkTye:NetworkTye, finished: @escaping (Any, Bool) -> Void){
        
        self.apollo.fetch(query: query) { result in
            if (try! result.get().errors == nil) {
                guard let data = try? result.get().data else { return }
                let responseMap:ResultMap = data.resultMap;
                switch networkTye {
                    case .Login:
                        let userLoginDict = responseMap["userLogin"] as! Dictionary<String, Any>;
                        let userModel:UserModel =  UserModel();
                        userModel.token = userLoginDict["token"] as! String
                        userModel.userId = userLoginDict["userId"] as! String
                        userModel.userType = userLoginDict["userType"] as! Int
                        userModel.userName = userLoginDict["userName"] as! String
                        
//                         var manager = SQLiteDataBase.createDB("testDataBaseName")
//
//                        SQLiteDataBase.insert(object: userModel, intoTable: "LoginUserModel")
                        
                        
                        print("解析登陆数据");
                        
                        break;
                }
            } else {
                // 请求异常
            }
            print("测试")
        }
//        self.apollo.fetch(query: GraphQLQuery)
        /*
        self.apollo.fetch(query: query) { result in
          guard let data = try? result.get().data else { return }
            print("测试")
        }
 */
    }
//    GetStudentClassroomsQuery
    /*
    //MARK: 获取学生所有课程
    func getStudentClassrooms(query: GetStudentClassroomsQuery,finished: @escaping (Any,Any,Bool) -> Void){
        apollo.fetch(query: query) { result in
          guard let data = try? result.get().data else { return }
            print("测试")
        }
    }
 */
    
    
    
    
    
}
