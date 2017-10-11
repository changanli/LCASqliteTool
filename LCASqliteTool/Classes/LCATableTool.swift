//
//  LCATableTool.swift
//  sqlite封装
//
//  Created by lichangan on 2017/10/5.
//  Copyright © 2017年 lichangan. All rights reserved.
//

import Foundation

//解析表格
open class LCATableTool {
    
    //MARK:判断表是否存在
   open class func isTableExist(tableName:String,uid:String?)->Bool {
        let querySql = "select sql from sqlite_master where type = 'table' and name = '\(tableName)'"
        let result = LCASqliteTool.query(sql: querySql, uid: uid)
        
        return ((result?.count ?? 0) > 0)
    }
    //MARK:获取sqlite数据库中创建表的sql
   open class func createTableSql(tableName:String,uid:String?)->String?{
        let queryCreateSqlStr = "select sql from sqlite_master where type = 'table' and name = '\(tableName)'"
        guard let dict = LCASqliteTool.query(sql: queryCreateSqlStr, uid: uid)?.first, let createTableSql = dict["sql"] as? String else {
           return nil
        }
        
        //兼容
        /*
         CREATE TABLE "XMGStu" ( \n
         //                           "age2" integer,
         //                           "stuNum" integer,
         //                           "score" real,
         //                           "name" text,
         //                           PRIMARY KEY("stuNum")
         //                           )
         */
        var sql = createTableSql.trimmingCharacters(in: .init(charactersIn: "\""))
        sql = sql.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "")

        return sql.lowercased()
    }
    
    //MARK:获取所有排序的字段名
   open class func allSortColumnNames(tableName:String,uid:String?)->[String] {
        guard var sql = createTableSql(tableName: tableName, uid: uid) else {
            return []
        }
        sql = sql.trimmingCharacters(in: CharacterSet.init(charactersIn: "\""))
        let nameTypeStr = sql.components(separatedBy: "(")[1]
        let nameTypes = nameTypeStr.components(separatedBy: ",")
        var names = [String]()
        for value in nameTypes {
            if value.lowercased().contains("primary") {
                continue
            }
            
            let nameAndType = value.components(separatedBy: " ")
            names.append(nameAndType[0])
        }
        names.sort(by: >)
        return names
    }

}
