//
//  LCASqliteModelTool.swift
//  sqlite封装
//
//  Created by lichangan on 2017/10/4.
//  Copyright © 2017年 lichangan. All rights reserved.
//

import Foundation

let kDictionaryIdenti = "&&Dictionary"
let kArrayIdenti = "&&Array"

public class LCASqliteModelTool : NSObject {
    
    //MARK:创建表格
    /// MARK:创建表格
    /// - Parameters:
    ///   - createSql: 创建表格的sql
    ///   - uid: uid唯一标识，如果为空，存储common.sqlite,如果不为空，存储uid.sqlite
    /// - Returns: true 成功 false :失败
  public  class func createTable(createSql:String,uid:String?)->Bool {
        return LCASqliteTool.deal(sql: createSql, uid: uid)
    }
    
    // MARK:判断表是否需要更新
    /// 判断表是否需要更新
    /// - Parameters:
    ///   - model: 模型对象
    ///   - uid:  uid唯一标识，如果为空，存储common.sqlite,如果不为空，存储uid.sqlite
    /// - Returns: true 成功 false :失败
   public class func isTableNeedUpdate(model:LCAModelProtocol,uid:String?)->Bool {
        //create table if not exists student(name text,stuname interger,age interger,score real,primary key(stuname))
        let modelSql = model.createTableSql().lowercased()
//        create table student(name text,stuname interger,age interger,score real,primary key(stuname))
        let tableSql = LCATableTool.createTableSql(tableName: model.tableName(), uid: uid)?.lowercased()
        let modelColumnSql = modelSql.components(separatedBy: "\(model.tableName().lowercased())(").last
        let tableColumnSql = tableSql?.components(separatedBy: "\(model.tableName().lowercased())(").last
        if tableColumnSql == nil {
            return true
        }
        if modelColumnSql != tableColumnSql!{
            return true
        }
        return false
    }
    
    
    // MARK:更新表结构
    /// 更新表结构
    /// - Parameters:
    ///   - tableName: 要更新的表的名字
    ///   - model: 模型对象
    ///   - uid: uid唯一标识，如果为空，存储common.sqlite,如果不为空，存储uid.sqlite
    /// - Returns: true 成功 false :失败
  public  class func updateTable(tableName:String,model:LCAModelProtocol,uid:String?)->Bool{
        var sqls = [String]()
        //1.创建一个拥有正确结构的临时表 tableName_tmp
        let createTempTableSql = model.createTableSql(tableName: tableName)
        sqls.append(createTempTableSql)
        //2.把旧表的主键插入到新表
        let insertPrimaryKeySql = "insert into \(model.tmpTableName())(\(model.primaryKey())) select \(model.primaryKey()) from \(tableName);"
        sqls.append(insertPrimaryKeySql)
        //3.根据主键，把所有的数据从旧表更新到新表
        let oldNames = LCATableTool.allSortColumnNames(tableName: tableName, uid: uid)
        let newNames = model.allSortedColumnNames()
        
        //4.获取更名字典
        let replaceOldNameWithNewName = model.replaceOldNameWithNewName()
        for newName in newNames {
            //获取需要改名的新字段对应的老自选
            var oldName = newName
            if let replaceOldNameWithNewName = replaceOldNameWithNewName {
                for dict in replaceOldNameWithNewName {
                    if dict.value == newName {
                        oldName = dict.key
                    }
                }
            }
            
            //如果不是新增的字段直接跳过 如果要改名的新字段 对应的老字段不存在
            if !oldNames.contains(newName) || !oldNames.contains(oldName) || newName.contains(model.primaryKey()) {
                continue
            }
            let updateSql = "update \(model.tmpTableName()) set \(newName) = (select \(oldName) from \(tableName) where \(model.tmpTableName()).\(model.primaryKey()) = \(tableName).\(model.primaryKey()))"
            sqls.append(updateSql)
        }
        //4.删除旧表
        let deleteOldTable = "drop table if exists \(tableName)"
        sqls.append(deleteOldTable)
        //5.重新命名新表
        let renameTable = "alter table \(model.tmpTableName()) rename to \(tableName)"
        sqls.append(renameTable)
        return LCASqliteTool.deal(sqls: sqls, uid: uid)
    }
    
    //MARK:保存或者更新数据
    /// 保存或者更新数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - model: 模型对象
    ///   - uid: uid唯一标识，如果为空，存储common.sqlite,如果不为空，存储uid.sqlite
    /// - Returns: true 成功 false :失败
   public class func saveOrUpdate(tableName:String,model:LCAModelProtocol,uid:String?)->Bool {
        //1.判断模型是否存在，不存在，则创建
        if !LCATableTool.isTableExist(tableName: tableName, uid: uid) {
            let createSql = model.createTableSql(tableName: tableName)
            let r = LCASqliteModelTool.createTable(createSql: createSql, uid: uid)
        }
        //2.判断模型是否需要更新
        if isTableNeedUpdate(model: model, uid: uid) {
           updateTable(tableName: tableName, model: model, uid: uid)
        }
        
        //3.通过主键判断记录是否存在，如果存在则更新，不存在则插入
        let primaryKey = model.primaryKey()
        let object = model as! NSObject
        let primaryValue = object.value(forKey: primaryKey) as! String
        //根据主键的值，获取对应记录
        let querySql = "select * from \(tableName) where \(primaryKey) = '\(primaryValue)'"
        let result = LCASqliteTool.query(sql: querySql, uid: uid)
        
        //获取字段数组
        let columnNames = model.allSortedColumnNames()
        //获取值数组
        var values = [Any]()
        for name in columnNames {
            var value  = object.value(forKey: name)
            if ((value as? [String:Any]) != nil) || ((value as? [Any]) != nil) {
                do {
                    let data = try JSONSerialization.data(withJSONObject: value!, options: .prettyPrinted)
                    var text = String(data: data, encoding: .utf8)
                    if (value as? [String:Any]) != nil {
                        //是字典
                        text = kDictionaryIdenti + (text ?? "")
                    }else if (value as? [Any]) != nil {
                        //数组
                        text = kArrayIdenti + (text ?? "")
                    }
                    value = text
                } catch  {
                    print("转换成data失败")
                    values.append("null")
                }
            }
            if let value = value {
                values.append(value)
            }else {
                values.append("null")
            }
        }
        
        let count = columnNames.count
        var insertValues = [String]()
        var updateValues = [String]()
        for i in 0 ..< count {
            let name = columnNames[i]
            let value = values[i]
            let str = "'\(value)'"
            insertValues.append(str)
            let updateStr = name + "=" + str
            updateValues.append(updateStr)
        }
        
        var sql = ""
        if (result?.count ?? 0) > 0 {
            //update
            sql = "update \(tableName) set \(updateValues.joined(separator: ",")) where \(primaryKey) = '\(primaryValue)'"
        }else {
            //inset
            sql = "insert into \(tableName)(\(columnNames.joined(separator: ","))) values(\(insertValues.joined(separator: ",")))"
        }
        
        return LCASqliteTool.deal(sql: sql, uid: uid)
    }
    
    //MARK:清空整个数据库
    ///清空整个数据库
    /// - Parameter uid: uid唯一标识，如果为空，删除common.sqlite的数据,如果不为空，删除uid.sqlite的数据
    /// - Returns: true 成功 false :失败
    public class func deleteAll(uid:String?)->Bool {
        let selectSql = "select name from sqlite_master where type='table' order by name"
        if let result = LCASqliteTool.query(sql: selectSql, uid: uid) {
            for dict in result {
                LCASqliteTool.beginTransaction(uid: uid)
                let tableName  = dict["name"] as! String
                if !delete(tableName: tableName, whereStr: nil, uid: uid) {
                    LCASqliteTool.rollBackTransaction(uid: uid)
                    return false
                }
            }
            LCASqliteTool.commitTransaction(uid: uid)
        }
        
        return true
    }
    
    //MARK: - 删除
    /// 删除
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereStr: where后面的条件语言
    ///   - uid: uid唯一标识，如果为空，删除common.sqlite的数据,如果不为空，删除uid.sqlite的数据
    /// - Returns: true 成功 false :失败
   public class func delete(tableName:String,whereStr:String?,uid:String?)->Bool {
        var deleteSql = "delete from \(tableName)"
        if (whereStr?.characters.count ?? 0) > 0 {
            deleteSql = "delete from \(tableName) where \(whereStr!)"
        }
        
        return LCASqliteTool.deal(sql: deleteSql, uid: uid)
    }
    
    //MARK - 查询
    // 查询
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereStr: where 条件语句
    ///   - uid: uid唯一标识，如果为空，查询common.sqlite,如果不为空，查询uid.sqlite
    /// - Returns: true 成功 false :失败
   public class func query(tableName:String,whereStr:String?,uid:String?)->[[String:Any]]? {
        var sql = "select * from \(tableName)"
        if (whereStr?.characters.count ?? 0) > 0 {
            sql = "select * from \(tableName) where \(whereStr!)"
        }
        return LCASqliteTool.query(sql: sql, uid: uid)
    }
}
