//
//  LCASqliteCache.swift
//  LCASqliteTool
//
//  Created by mac on 2017/10/12.
//

import Foundation

public class LCASqliteCache {
    
    //MARK:获取占用的缓存大小
    /// 获取占用的缓存大小
    /// - Parameter uid: uid
    /// - Returns: 名字为uid.sqlite的数据库占用的缓存大小，单位字节
    public class func cacheSize(uid:String?)->Int64 {
        //1.获取文件管理对象
        let fileManager = FileManager.default
        //2.获取文件路径
        let filePath = kCachePath + "/\(uid ?? "common").sqlite"
        //4.获取文件属性
        var attributes:[FileAttributeKey:Any]?
        do{
            attributes = try fileManager.attributesOfItem(atPath: filePath)
        }catch {
            return 0
        }
        //5.获得缓存字节
        guard let dict = attributes else {
            return 0
        }
        let size = dict[FileAttributeKey.size] as! Int64
        return size
    }
    
    //MARK:删除缓存
    /// 删除缓存
    /// - Parameter uid: uid
    /// - Returns: true 成功 false失败
    public class func deleteCache(uid:String?)->Bool{
        //1.获取文件管理对象
        let fileManager = FileManager.default
        //2.获取Cache路径
        let fileCachePath = kCachePath + "/\(uid ?? "common").sqlite"
        do{
            try fileManager.removeItem(atPath: fileCachePath)
            return true
        }catch{
            return false
        }
    }
}
