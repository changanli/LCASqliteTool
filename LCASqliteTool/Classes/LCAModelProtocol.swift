//
//  LCAModelProtocol.swift
//  sqlite封装
//
//  Created by lichangan on 2017/10/4.
//  Copyright © 2017年 lichangan. All rights reserved.
//

import Foundation

public protocol LCAModelProtocol:NSObjectProtocol{
    //MARK:让用户指定主键 必须是字段，不能是字段中不存在的
    func primaryKey()->String
    //MARK:表名
    func tableName()->String
    //MARK:字段:类型
    func columnNameAndType()->[String:String]
    //MARK:修改字段名称
    func replaceOldNameWithNewName()->[String:String]?
}

public extension LCAModelProtocol {
    
    //MARK:临时表名
   public func tmpTableName()->String {
        return "\(tableName())_tmp"
    }
    //MARK:经过排序的字段名
   public func allSortedColumnNames()->[String] {
        let dict = columnNameAndType()
        var names = [String]()
        for value in dict {
            names.append(value.key)
        }
        names.sort(by: >)
        return names
    }
    
    //MARK:返回带有字段名和类型的sql
    /// 返回带有字段名和类型的sql
    /// - Parameter model: 遵守协议的数据模型
    /// - Returns: 返回带有字段名和类型的sql
   public func createTableSql()->String {
        ////后面判断是否需要更新表时，需要根据这个拼接格式，获取columnSql,所以格式不能改变
        let  createTableSql = "create table if not exists \(tableName())(\(comlumnAndTypeSql()),primary key(\(primaryKey())))"
        return createTableSql
    }
    //MARK:根据表明创建sqlite
   public func createTableSql(tableName:String)->String{
        let createTableSql = "create table if not exists \(tableName)(\(comlumnAndTypeSql()),primary key(\(primaryKey())))"
        return createTableSql
    }
    //MARK:创建临时表的sql
   public func createTmpTableSql()-> String {
        let createTableSql =  "create table if not exists \(tmpTableName())(\(comlumnAndTypeSql()),primary key(\(primaryKey())))"
        return createTableSql
    }
    
    func comlumnAndTypeSql()->String{
        let dict = covertTypeToSqliteType()
        var sql = ""
        for value in dict {
            sql += value.key + " " + value.value + ","
        }
        sql.remove(at: sql.index(sql.endIndex, offsetBy: -1))
        return sql
    }
    func covertTypeToSqliteType()->[String:String] {
        var dict = columnNameAndType()
        
        for value in dict {
            
            if value.value.lowercased().contains("double") || value.value.lowercased().contains("float") {
                dict[value.key] = "real"
            }else if value.value.lowercased().contains("int") || value.value.lowercased().contains("bool") {
                dict[value.key] = "integer"
            }else if value.value.lowercased().contains("string") {
                dict[value.key] = "text"
            }else if value.value.lowercased().contains("data") {
                dict[value.key] = "blob"
            }else {
                //数组 字典 按照text类型存储
                dict[value.key] = "text"
            }
        }
        
        return dict
    }
    
}
