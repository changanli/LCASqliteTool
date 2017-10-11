# LCASqliteTool

[![CI Status](http://img.shields.io/travis/931985308@qq.com/LCASqliteTool.svg?style=flat)](https://travis-ci.org/931985308@qq.com/LCASqliteTool)
[![Version](https://img.shields.io/cocoapods/v/LCASqliteTool.svg?style=flat)](http://cocoapods.org/pods/LCASqliteTool)
[![License](https://img.shields.io/cocoapods/l/LCASqliteTool.svg?style=flat)](http://cocoapods.org/pods/LCASqliteTool)
[![Platform](https://img.shields.io/cocoapods/p/LCASqliteTool.svg?style=flat)](http://cocoapods.org/pods/LCASqliteTool)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
在创建模型时，需要继承自LCAObject,并且遵守协议LCAModelProtocol,实现协议方法
```
//MARK:让用户指定主键 必须是字段，不能是字段中不存在的
func primaryKey()->String
//MARK:表名
func tableName()->String
//MARK:字段:类型
func columnNameAndType()->[String:String]
//MARK:修改字段名称
func replaceOldNameWithNewName()->[String:String]?
```
注意:字典和数组只能是基本类型，不支持数组里包含自定义类型，也不支持属性是自定义类型的和Data，数组和字典被转换为文本类型存储在sqilte里面。
## Requirements
Xcode 8.0以上 Swift 3.0
## Installation

LCASqliteTool is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LCASqliteTool'
```

## Author

931985308@qq.com, lichangan

## License

LCASqliteTool is available under the MIT license. See the LICENSE file for more info.
