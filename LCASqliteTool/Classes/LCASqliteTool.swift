//
//  LCASqliteTool.swift
//  sqlite封装
//
//  Created by lichangan on 2017/10/4.
//  Copyright © 2017年 lichangan. All rights reserved.
//

import Foundation

let kCachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!

//let kCachePath = "/Users/lichangan/Desktop" //放在桌面，方便调试
///导入sqlite数据库，在桥接文件中#import "sqlite3.h"

var pDb:OpaquePointer? = nil

public class LCASqliteTool : NSObject{

    // MARK:执行SQL语句
    /// 执行SQL语句
    /// - Parameters:
    ///   - sql: sql语句
    ///   - uid: 用户标识
    /// - Returns: true 成功 fase失败
    public class func deal(sql:String,uid:String?)->Bool {
//        1.创建&打开数据库
        //如果打开的文件不存，会自动创建
        if !openDB(uid: uid) {
            print("打开数据库失败")
            return false
        }
        //2.执行语句
        let result = sqlite3_exec(pDb!, sql.cString(using: String.Encoding.utf8), nil, nil, nil)
        print(result)
        //3.关闭数据
        closeDB(uid: uid)
        return (result == 0)
    }
    
    // MARK:查询
    /// 查询
    /// - Parameters:
    ///   - sql: sql语句
    ///   - uid: 用户标识
    /// - Returns: 字典(一行记录)组成的数组
    public class func query(sql:String,uid:String?)->[[String:Any]]? {
        if !openDB(uid: uid) {
            return nil
        }
        
        //准备语句(预处理语句)
        //1.创建准备语句
        //参数1:一个已经打开的数据库
        //参数2:需要的sql
        //参数3:参数2取出多少字节的长度 -1表示自动计算，遇到\0结束
        //参数4:准备语句
        //参数5:通过参数3取出参数2的长度字节之后，剩下的字符串
        var pStmt:OpaquePointer? = nil
//        SQLITE_OK
//        print(sqlite3_prepare(pDb,sql.cString(using: .utf8), -1, &pStmt, nil))
        if sqlite3_prepare(pDb,sql.cString(using: .utf8), -1, &pStmt, nil) != 0 {
            print("准备语句编译失败")
            return nil
        }
        //2.绑定数据(省略，外部传入了完整的sql语句)
        //3.执行
        var resultArray = [[String:Any]]()
        while sqlite3_step(pStmt) == SQLITE_ROW {
            //一行记录->字典
            //1.获取所有的记录的个数
            let columnCount = sqlite3_column_count(pStmt)
            var dict = [String:Any]()
            for i in 0 ..< columnCount {
                //2.1获取列名
                //c语言的字符串
                guard let cColumnName = sqlite3_column_name(pStmt, i) else {
                    continue
                }
                let columnName = String(cString: cColumnName)
                
                //2.2获取列值,
                //不同列的类型，使用不同的函数，进行获取
                //2.2.1获取列的类型
                let type = sqlite3_column_type(pStmt, i)
                //2.2.2根据类型获取值
                var value:Any? = nil
                switch type {
                case SQLITE_INTEGER:
                    value = sqlite3_column_int(pStmt, i)
                case SQLITE_FLOAT:
                    value = sqlite3_column_double(pStmt, i)
                case SQLITE_BLOB:
                    value = sqlite3_column_blob(pStmt, i)
                case SQLITE_TEXT:
                    var text = String(cString: sqlite3_column_text(pStmt, i))
                    if text.contains(kDictionaryIdenti) {
                        //字典:
                       text = text.replacingOccurrences(of: kDictionaryIdenti, with: "")
                        if let data = text.data(using: String.Encoding.utf8) {
                            do {
                                value = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                            }catch{
                                value = nil
                            }
                        }
 
                    }else if text.contains(kArrayIdenti) {
                        //数组
                       text = text.replacingOccurrences(of: kArrayIdenti, with: "")
                        if let data = text.data(using: String.Encoding.utf8){
                            do {
                                value = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                            }catch {
                                value = nil
                            }
                        }
                    }else {
                         value = text
                    }
                   
                default:
                    break
                }
                
                dict[columnName] = value
            }
            resultArray.append(dict)
        }
        //4.重置(省略，执行多次的时候需要重置，绑定数据，执行，重置，绑定数据，执行，重置)
        //5.释放资源
        sqlite3_finalize(pStmt)
        return resultArray
    }
    
    //MARK:执行多条sql语句
    //事务:开启事务 提交事务 回滚事务
    //事务可以保证多个操作都执行成功，否则就不会更新数据
    //当执行多个sql时，一条执行失败，可能整个表就不能用了，所以批量操作要使用事务进行操作
    public class func deal(sqls:[String],uid:String?)->Bool{
        //开启事务
        beginTransaction(uid: uid)
        //批量执行sql
        for sql in sqls {
            let result = deal(sql: sql, uid: uid)
            if result == false {
                //回滚
                rollBackTransaction(uid: uid)
                return false
            }
        }
        //提交
       commitTransaction(uid: uid)
        return true

    }
    
    //MARK:开启事务
    fileprivate class func beginTransaction(uid:String?) {
        deal(sql:"begin transaction", uid: uid)
    }
    //MARK:提交事务
    fileprivate class func commitTransaction(uid:String?) {
        deal(sql:"commit transaction", uid: uid)
    }
    //MARK:回滚
    fileprivate class func rollBackTransaction(uid:String?) {
       deal(sql:"rollback transaction", uid: uid)
    }
    
    //MARK- 私有方法
    
    //MARK: 创建&打开数据库
    /// 打开数据库
    /// - Parameter uid: uid
    /// - Returns: true false
   fileprivate class func openDB(uid:String?)->Bool{
        /*
         用户机制:
         如果uid = nil 是公共数据库 common.db
         uid = zhangsan zhangsan.db
         */
        var dbName = "common.sqlite"
        if uid?.characters.count ?? 0 != 0 {
            dbName = "\(uid!).sqlite"
        }
        
        let dbPath = kCachePath.appending("/\(dbName)")
        print(dbPath)
        let cDbPath = dbPath.cString(using: String.Encoding.utf8)
        return (sqlite3_open(cDbPath, &pDb) == 0)
    }
    
    //MARK:关闭数据库
    /// 关闭数据库
    /// - Parameter uid: uid
    /// - Returns: true false
   fileprivate class func closeDB(uid:String?){
        sqlite3_close(pDb)
        pDb = nil
    }
    
}
