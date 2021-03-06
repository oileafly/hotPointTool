//
//  locationCoordinate.swift
//  hotPointTool
//
//  Created by keney on 2016/12/12.
//  Copyright © 2016年 keney. All rights reserved.
//

import Cocoa

class locationCoordinate: NSObject {
    
    // 地理位置文件转成对象的集合
    var loAry : [location] = []
    
    // 桌面的文件路径
    let deskTopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
    
    
    lazy var fm: FileManager = {
        
        return FileManager.default
    }()
    
    
    override init() {
        
        super.init()
        
    }
    
    // 创建地理编码结构
    func creatLocationFile(filePathS: [String]) {
        
        
        for filePath in filePathS{

            
            let fURL = URL.init(fileURLWithPath: filePath)
            let last = fURL.lastPathComponent
            
            let charset = CharacterSet(charactersIn:".csv")
            let itemName = last.trimmingCharacters(in: charset)
            
            let stream = InputStream(fileAtPath: filePath)!
            
            var rowAry: [CSV.Element] = []
            
            for row in try! CSV(stream: stream) {
                
                rowAry.append(row)
                
            }
            
            // 分离第一行id数据和其他行数据
            var idAry : [String] = []
            var newRowAry : [CSV.Element] = []
            for (index, _) in rowAry.enumerated(){
                
                if index == 0{
                    
                    idAry = rowAry[0]
                    
                }else{
                    
                    newRowAry.append(rowAry[index])
                }
                
            }
            
            
            // 组合行数据成字典数组
            var newDictAry : [AnyObject] = []
            
            for (index, _) in newRowAry.enumerated() {
                
                var dict  =  [String: String]()
                
                for (idIndex, _) in idAry.enumerated() {
                    
                    dict.updateValue(newRowAry[index][idIndex], forKey: idAry[idIndex])
                }
                
                newDictAry.append(dict as [String: String] as AnyObject)
            }
            
            // 字典数组转对象数组
            for (index, _) in newDictAry.enumerated() {
                
                let lo = location()
                lo.address = newDictAry[index].value(forKey: "address")! as! String
                lo.createtime = newDictAry[index].value(forKey: "createtime")! as! String
                lo.id = newDictAry[index].value(forKey: "id")! as! String
                lo.lat = newDictAry[index].value(forKey: "lat")! as! String
                lo.lon = newDictAry[index].value(forKey: "lon")! as! String
                lo.name = newDictAry[index].value(forKey: "name")! as! String
                lo.updatetime = newDictAry[index].value(forKey: "updatetime")! as! String
                
                loAry.append(lo)
            }
            
            
            for (index, _) in loAry.enumerated() {
                
                do {
                    
                    let filePath = deskTopPath.path + "/LocationoutPut" + "/\(itemName)" + "/\(loAry[index].name)"
                    
                    // 1,模块单元创建
                    try fm.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
                    
                    try fm.createDirectory(at: URL.init(fileURLWithPath: filePath), withIntermediateDirectories: true, attributes: nil)
                    
                    // 2,appearance.xml 创建
                    let appearancePath = filePath + "/appearance.xml"
                    
                    let appearance = "<root contentBackgroundTintColor=\"#88e5b02c\" textTintColor=\"#ffffff\" barTintColor=\"#cc6fbe54\">" + "\n" +
                        "<baseAppearance tintColor=\"#cc6fbe54\" borderColor=\"#cc6fbe54\" borderWidth=\"1.\" />" + "\n" + "</root>"
                    
                    fm.createFile(atPath: appearancePath, contents: appearance.data(using: String.Encoding.utf8), attributes: nil)
                    
                    // 3,config.xml 创建
                    let configPath = filePath + "/config.xml"
                    
                    let config = "<root locationCoordinate=\"{\(loAry[index].lat),\(loAry[index].lon)}\"><type>MapAnnotation</type><layout>layout.xml</layout><name>\(loAry[index].name)</name><dataFile>datafile.xml</dataFile><icon>logo.png</icon><appearance>appearance.xml</appearance><subname></subname><resource></resource></root>"
                    
                    fm.createFile(atPath: configPath, contents: config.data(using: String.Encoding.utf8), attributes: nil)
                    
                } catch let error {   print(error)  }
                
            }
            
            
            
        }
        
        
        
    }
    
    
}
