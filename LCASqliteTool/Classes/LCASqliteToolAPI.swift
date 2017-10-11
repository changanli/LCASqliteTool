//
//  LCASqliteToolAPI.swift
//  sqlite封装
//
//  Created by lichangan on 2017/10/4.
//  Copyright © 2017年 lichangan. All rights reserved.
//

import Foundation

public enum ColumnNameToValueRelationType:String {
    case greater = ">"
    case less = "<"
    case equal = "="
    case greaterEqual = ">="
    case lessEqual = "<="
}

open class LCASqliteToolAPI {
    //MARK:创建表格
    /// MARK:创建表格
    /// - Parameters:
    ///   - createSql: 创建表格的sql
    ///   - uid: uid唯一标识，如果为空，存储common.sqlite,如果不为空，存储uid.sqlite
    /// - Returns: true 成功 false :失败
    open class func createTable(createSql:String,uid:String?)->Bool {
       return LCASqliteModelTool.createTable(createSql: createSql, uid: uid)
    }
    
    // MARK:判断表是否需要更新
    /// 判断表是否需要更新
    /// - Parameters:
    ///   - model: 模型对象
    ///   - uid:  uid唯一标识，如果为空，存储common.sqlite,如果不为空，存储uid.sqlite
    /// - Returns: true 成功 false :失败
    open class func isTableNeedUpdate(model:LCAModelProtocol,uid:String?)->Bool {
       return LCASqliteModelTool.isTableNeedUpdate(model: model, uid: uid)
    }
    
    //MARK:更新表结构
    ///更新表结构 默认更新model
    /// - Parameters:
    ///   - model: 模型对象
    ///   - uid: uid唯一标识，如果为空，存储common.sqlite,如果不为空，存储uid.sqlite
    /// - Returns: true 成功 false :失败
    open class func updateTable(model:LCAModelProtocol,uid:String?)->Bool{
      return  updateTable(tableName: model.tableName(), model: model, uid: uid)
    }
    // MARK:更新表结构
    /// 更新表结构
    /// - Parameters:
    ///   - tableName: 要更新的表的名字
    ///   - model: 模型对象
    ///   - uid: uid唯一标识，如果为空，存储common.sqlite,如果不为空，存储uid.sqlite
    /// - Returns: true 成功 false :失败
    open class func updateTable(tableName:String,model:LCAModelProtocol,uid:String?)->Bool{
       return LCASqliteModelTool.updateTable(tableName: tableName, model: model, uid: uid)
    }
    
    //MARK:保存或者更新数据
    /// 保存或者更新数据，默认model的表名
    /// - Parameters:
    ///   - model: 模型对象
    ///   - uid: uid唯一标识，如果为空，存储common.sqlite,如果不为空，存储uid.sqlite
    /// - Returns: true 成功 false :失败
    open class func saveOrUpdate(model:LCAModelProtocol,uid:String?)->Bool {
        return saveOrUpdate(tableName: model.tableName(), model: model, uid: uid)
    }
    
    //MARK:保存或者更新数据
    /// 保存或者更新数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - model: 模型对象
    ///   - uid: uid唯一标识，如果为空，存储common.sqlite,如果不为空，存储uid.sqlite
    /// - Returns: true 成功 false :失败
    public class func saveOrUpdate(tableName:String,model:LCAModelProtocol,uid:String?)->Bool {
       return LCASqliteModelTool.saveOrUpdate(tableName: tableName, model: model, uid: uid)
    }
    //MARK:清空整个数据库
    ///清空整个数据库
    /// - Parameter uid: uid唯一标识，如果为空，删除common.sqlite的数据,如果不为空，删除uid.sqlite的数据
    /// - Returns: true 成功 false :失败
    public class func deleteAll(uid:String?)->Bool {
       return LCASqliteModelTool.deleteAll(uid: uid)
    }
    
    //MARK:清空表
    ///清空表
    /// - Parameters:
    ///   - tableName: 表名
    ///   - uid: uid唯一标识，如果为空，删除common.sqlite的数据,如果不为空，删除uid.sqlite的数据
    /// - Returns:  true 成功 false :失败
    open class func deleteAll(tableName:String,uid:String?)->Bool {
      return  LCASqliteModelTool.delete(tableName: tableName, whereStr: nil, uid: uid)
    }
    
    //MARK: - 删除
    /// 删除
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereStr: where后面的条件语言
    ///   - uid: uid唯一标识，如果为空，删除common.sqlite的数据,如果不为空，删除uid.sqlite的数据
    /// - Returns: true 成功 false :失败
    open class func delete(tableName:String,whereStr:String,uid:String?)->Bool {
        return LCASqliteModelTool.delete(tableName: tableName, whereStr: whereStr, uid: uid)
    }
    
    //MARK: - 删除
    /// 删除
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columnName: 字段名
    ///   - relation: 关系
    ///   - value: 字段值
    ///   - uid: uid唯一标识，如果为空，删除common.sqlite的数据,如果不为空，删除uid.sqlite的数据
    /// - Returns: true 成功 false :失败
    open class func delete(tableName:String,columnName:String,relation:ColumnNameToValueRelationType,value:Any,uid:String?)->Bool {
       return delete(tableName: tableName, whereStr: "\(columnName) \(relation.rawValue) '\(value)'", uid: uid)
    }
    
    //MARK - 查询
    /// 查询
    /// - Parameters:
    ///   - tableName: 表名
    ///   - uid: uid唯一标识，如果为空，查询common.sqlite,如果不为空，查询uid.sqlite
    /// - Returns: true 成功 false :失败
    open class func queryAll(tableName:String,uid:String?)->[[String:Any]]? {
        return  LCASqliteModelTool.query(tableName: tableName, whereStr: nil, uid: uid)
    }
    
    //MARK - 查询
    // 查询
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereStr: where 条件语句
    ///   - uid: uid唯一标识，如果为空，查询common.sqlite,如果不为空，查询uid.sqlite
    /// - Returns: true 成功 false :失败
    open class func query(tableName:String,whereStr:String,uid:String?)->[[String:Any]]? {
        return  LCASqliteModelTool.query(tableName: tableName, whereStr: whereStr, uid: uid)
    }
    
    //MARK - 查询
    /// 查询
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columnName: 字段名
    ///   - relation: 关系
    ///   - value: 字段值
    ///   - uid: uid唯一标识，如果为空，查询common.sqlite,如果不为空，查询uid.sqlite
    /// - Returns: true 成功 false :失败
    open class func query(tableName:String,columnName:String,relation:ColumnNameToValueRelationType,value:Any,uid:String?)->[[String:Any]]?{
       return query(tableName: tableName, whereStr: "\(columnName) \(relation.rawValue) '\(value)'", uid: uid)
    }
    
}
