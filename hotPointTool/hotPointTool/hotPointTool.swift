//
//  hotPointTool.swift
//  hotPointTool
//
//  Created by keney on 2016/10/27.
//  Copyright © 2016年 keney. All rights reserved.
//

import Cocoa


class hotPointTool: NSObject {
    
    var filePath: String
    
    var newfilePath : String
    
    var fileAry : [String]
    
    var imagePath : [String]
    
    var pngAry : [String]
    
    let hotspots = "hotspots"
    
    let imageFile = "images"
    
    let xmlName = "hotspotdatafile.xml"
    
    let pngName = "icon@2x.png"
    
    var imageWidth : Double!
    
    var imageheight : Double!
    
    lazy var fm: FileManager = {
        
        return FileManager.default
    }()
    
    
    var canClick : Int = 0
    
    override init() {
        
        self.fileAry = []
        
        self.imagePath = []
        
        self.pngAry = []
        
        self.filePath = ""
        
        self.newfilePath = self.filePath + "/\(hotspots)"
        
    }
    
    
    // hasSuffix's file
    func foundItemInDirector(fileType:String) -> [String] {
        
        var fileAry : [String] = []
        
        do {
            
            let contentFiles = try self.fm.contentsOfDirectory(atPath: self.filePath)
            
            
            for item in contentFiles{
                
                
                if item.components(separatedBy: "camera").count > 1{
                    
                    // 包含camera.xml 文件
                    
                }else{
                
                    switch fileType {
                    case "xml":
                        if item.hasSuffix("xml"){
                            
                            fileAry.append(item)
                        }
                        
                    case "png":
                        
                        if item.hasSuffix("png"){
                            
                            fileAry.append(item)
                            
                        }
                        
                    case "other":
                        if fileType == "other"{
                            
                            fileAry.append(item)
                            
                        }
                        
                    default: break
                    }
                    
                }
                
            }
            
        } catch {}
        
        
        return fileAry
        
    }
    
    // no Suffix's files
    func getFileNameAryInDirector(fileType: String) -> [String] {
        
        var ary : [String] = []

            
            let itemAry = self.foundItemInDirector(fileType:"\(fileType)")
        
            for item in itemAry {
                
                let charset = CharacterSet(charactersIn:".\(fileType)")
                let itemName = item.trimmingCharacters(in: charset)
                
                if fileType == "xml"{
                
                    if(itemName == "camera" || itemName == "DS_Store" || itemName == "\(hotspots)"){}else{
                        
                        ary.append(itemName)
                        
                    }
                }else if fileType == "png"{
                    
                    if(itemName == "camera" || itemName == "DS_Store" || itemName == "\(hotspots)"){}else{
                        
                        ary.append(itemName)
                        
                    }
                }
                
            }
        
        
        self.fileAry = ary
        
        return self.fileAry
    }
    
    
    // Stitching path
    func getObjectUrlPath(fileType: String) -> [String] {
        
        var upAry : [String] = []
        
        let fileNameAry = self.getFileNameAryInDirector(fileType: "\(fileType)")
        
        switch fileType {
            
        case "xml":
            for item in fileNameAry {
                
                let subXmlPath = self.newfilePath + "/\(item)/" + "\(xmlName)"
                
                upAry.append(subXmlPath)
                
            }
            
        case "png":
            
            for item in fileNameAry {
                
                let subXmlPath = self.newfilePath + "/\(item)/\(imageFile)/" + "\(pngName)"
                
                upAry.append(subXmlPath)
                
            }
            
        default: break
        }
        
        return upAry
        
    }
    
    // get filePath
    func getItemUrlPath(fileType: String) -> [String] {
        
        var itemUrl : [String] = []
            
            do {
                
                let url : URL = URL.init(fileURLWithPath: self.filePath)
                
                let newUrls = try self.fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                
                for item in newUrls {
                    
                    
                    if item.path.components(separatedBy: "camera").count > 1{
                        
                        // 包含camera.xml 文件
                        
                    }else{
                    
                        // 过滤camera文件
                        
                        switch fileType {
                            
                        case "xml":
                            if item.absoluteString.hasSuffix("xml"){
                                
                                itemUrl.append(item.path)
                                
                            }
                            
                        case "png":
                            
                            if item.absoluteString.hasSuffix("png"){
                                
                                itemUrl.append(item.path)
                            }
                            
                        case "hotspots":
                            
                            if !item.absoluteString.hasSuffix("png") || !item.absoluteString.hasSuffix("xml"){
                                
                                itemUrl.append(item.path)
                                
                            }
                            
                            
                        default: break
                        }
                        
                    }
            
                }
                
            } catch {}
        
        return itemUrl
        
    }
    
    func checkFile()-> Bool{

        
        
        // 删除旧的 hotspots 文件夹
        do {
            
            
            if self.fm.fileExists(atPath: self.newfilePath){
                
                try self.fm.removeItem(atPath: self.newfilePath)
            }
            
            
        } catch{ }
        
        
        // 检查文件名称是否对称
        let xmlFiles = self.getFileNameAryInDirector(fileType:"xml")
        let pngFiles = self.getFileNameAryInDirector(fileType:"png")
    
    
        for (index, _) in xmlFiles.enumerated() {
            
            if xmlFiles[index] != pngFiles[index]{
                
                let alert = NSAlert.init()
                alert.messageText.append("温馨提醒：")
                alert.informativeText = "请保持:  \(xmlFiles[index]).xml与对应的png名称的统一"
                alert.showsSuppressionButton = true
                alert.runModal()
                
                return false
            }
            
            
        }
        
        
        return true
    }
    
    func creatFile(){
        
        self.fileAry = self.getFileNameAryInDirector(fileType:"xml")
        
        for fileName in self.fileAry {
            
            let xmlFilePath = newfilePath +  "/" + fileName
            let imageFilePath = xmlFilePath + "/\(imageFile)"
            
            do{
                
                try self.fm.createDirectory(atPath: self.newfilePath, withIntermediateDirectories: true, attributes: nil)
                
                try self.fm.createDirectory(atPath: xmlFilePath, withIntermediateDirectories: true, attributes: nil)
                
                try self.fm.createDirectory(atPath: imageFilePath, withIntermediateDirectories: true, attributes: nil)
                
            }catch{}
        }
        
    }
    
    
    func copyFileToObject(){
        
        
        let itemUrl = self.getItemUrlPath(fileType: "xml")
        
        let objUrl = self.getObjectUrlPath(fileType: "xml")
        
        // get png files
        let pngUrl = self.getItemUrlPath(fileType: "png")
        
        let pngObUlr = self.getObjectUrlPath(fileType: "png")
        
        for (index, _) in itemUrl.enumerated(){
            
            let atPath = itemUrl[index]
            let toPath = objUrl[index]
            
            let atPng = pngUrl[index]
            let toPng = pngObUlr[index]
            
            do {
                
                try self.fm.copyItem(atPath: atPath, toPath: toPath)
                
                try self.fm.copyItem(atPath: atPng, toPath: toPng)
                
            }catch{}
            
        }
        
    }
    
    // get png's messges
    func getPngMessges(){
        
        let pngAry = self.getObjectUrlPath(fileType: "png")
        
        var data: Data?
        
        do {
            
            data = try Data.init(contentsOf: URL.init(fileURLWithPath: pngAry[0], isDirectory: false))
            
        } catch {}
        
        if #available(OSX 10.12, *) {
            
            let image = NSImageView.init(image: NSImage.init(data: data!)!)
            
            self.imageWidth = Double(image.image!.size.width * 0.5)
            
            self.imageheight = Double(image.image!.size.height * 0.5)
            
        }else{
            
            let image = NSImage.init(data:data!)
            
            self.imageWidth = Double(image!.size.width * 0.5)
            
            self.imageheight = Double(image!.size.height * 0.5)
            
        }
    }
    
    func getXMLOriginSize(){
        
        let firtXml = self.getObjectUrlPath(fileType: "xml")
        
        let xmlStr = firtXml[0]
        
        do {
            
            let str = try String.init(contentsOfFile: xmlStr, encoding: String.Encoding.isoLatin2)
            
            let originSize = str.substring(with: str.index(str.startIndex, offsetBy: 22)..<str.index(str.startIndex, offsetBy: 36))
            
            // 模版 头部 xml
            let newStr  =  "<hotspot bounds=\"{{0., 0.}, {\(self.imageWidth!), \(self.imageheight!)}}\"" + " anchorPoint=\"{.5, .928}\"" +  " originSize=\"{\(originSize)}\"" +  " center=\"{0., 0.}\">" + "\n" + "<backgroundImage state=\"0\" value=\"images/icon.png\" /> \n"
            
            for item in firtXml{
                
                var str = try String.init(contentsOfFile: item, encoding: String.Encoding.isoLatin2)
                
                // 移除头部信息
                str.removeSubrange(str.index(str.startIndex, offsetBy: 0)...str.index(str.startIndex, offsetBy: 39))
                
                // 保存 frame 的数据
                let strFrame = str.data(using: String.Encoding.isoLatin2)!
                
                // 拼接完整 xml 数据
                let newData = newStr.data(using: String.Encoding.utf8)! + strFrame
                
                // 写入 覆盖
                let fm = FileHandle.init(forWritingAtPath: item as String!)
                fm?.seek(toFileOffset: 0)
                fm?.write(newData as Data!)
                fm?.closeFile()
                
            }
            
        } catch let error{
            
            
            print(error)
            
        }
        
    }
    
    
    
    // 纯xml文件， 创建热点结构
    func getOnlyXmlFiles(){
        
        let paths = getItemUrlPath(fileType:"xml")
        
        self.fileAry = self.getFileNameAryInDirector(fileType:"xml")
        
        // datafile.xml 文件
        let bundle = Bundle.main.path(forResource: "datafile", ofType: "xml")


        do {
            
            try self.fm.createDirectory(atPath: self.newfilePath, withIntermediateDirectories: true, attributes: nil)
            
            
        }catch{}
        
        for (index, _) in paths.enumerated(){
        
             let xmlObjectPath = self.newfilePath +  "/\(fileAry[index])"
            
             do{
             
                // 创建项目文件夹
                try self.fm.createDirectory(atPath: xmlObjectPath, withIntermediateDirectories: true, attributes: nil)
                
                // 创建placemarklayout.xml文件
                try self.fm.copyItem(atPath: paths[index], toPath: "/\(xmlObjectPath)/" + "placemarklayout.xml")
                
               // 创建config.xml 模块文件
                let rootConfig = "<root/>"
                
                 self.fm.createFile(atPath: "/\(self.newfilePath)/config.xml", contents: rootConfig.data(using: String.Encoding.utf8), attributes: nil)

                // 不可点击图标
                if self.canClick == 0{
                    
                    // 创建config.xml文件
                    let config = "<root>" + "\n" +
                        "<type>AnimationGenerator</type>" + "\n" +
                        "<name>\(fileAry[index])</name>" + "\n" +
                        "<dataFile>scripts/沙盘不可点图标/datafile.xml</dataFile>" + "\n" +
                    "</root>"
                    
                    self.fm.createFile(atPath: "/\(xmlObjectPath)/" + "config.xml", contents: config.data(using: String.Encoding.utf8), attributes: nil)
                    
                    
                    let datafilePath = "/\(self.newfilePath)/scripts/沙盘不可点图标"
                    try self.fm.createDirectory(atPath: "\(datafilePath)", withIntermediateDirectories: true, attributes: nil)
                    try self.fm.copyItem(atPath: bundle!, toPath:  "\(datafilePath)/" + "datafile.xml")
                    
                }else{
                
                    // 可点击
                    
                    
                    // 创建config.xml文件
                    let configStr = "<root>" + "\n" +
                        "<type>AnimationGenerator</type>" + "\n" +
                        "<name>\(fileAry[index])</name>" + "\n" +
                        "<dataFile>datafile.xml</dataFile>" + "\n" +
                    "</root>"
                    
                    self.fm.createFile(atPath: "/\(xmlObjectPath)/" + "config.xml", contents: configStr.data(using: String.Encoding.utf8), attributes: nil)
                    
                    
                    try self.fm.copyItem(atPath: bundle!, toPath:  "/\(xmlObjectPath)/" + "datafile.xml")
                    
                }
                
             }catch let error{

                print(error)
            }
            
            
            

        }
    }
    
}


