//
//  FontManager.swift
//  GoogleFonts
//
//  Created by Faris Albalawi on 2/20/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let Vibes = "http://fonts.gstatic.com/s/vibes/v1/QdVYSTsmIB6tmbd3HpbsuBlh.ttf"
let Changa = "http://fonts.gstatic.com/s/changa/v9/2-c79JNi2YuVOUcOarRPgnNGooxCZ62xQjDp9htf1ZM.ttf"
let Amiri = "http://fonts.gstatic.com/s/amiri/v13/J7aRnpd8CGxBHqUpvrIw74NL.ttf"
let Mada = "http://fonts.gstatic.com/s/mada/v8/7Auwp_0qnzeSTTXMLCrX0kU.ttf"
let Rakkas = "http://fonts.gstatic.com/s/rakkas/v7/Qw3cZQlNHiblL3j_lttPOeMcCw.ttf"
let Tajawal = "http://fonts.gstatic.com/s/tajawal/v3/Iura6YBj_oCad4k1rzaLCr5IlLA.ttf"
let ArefRuqaa = "http://fonts.gstatic.com/s/arefruqaa/v8/WwkbxPW1E165rajQKDulEIAiVNo5xNY.ttf"
let Jomhuria = "http://fonts.gstatic.com/s/jomhuria/v7/Dxxp8j-TMXf-llKur2b1MOGbC3Dh.ttf"
let Knewave = "http://fonts.gstatic.com/s/knewave/v8/sykz-yx0lLcxQaSItSq9-trEvlQ.ttf"
let PermanentMarker = "http://fonts.gstatic.com/s/permanentmarker/v9/Fh4uPib9Iyv2ucM6pGQMWimMp004HaqIfrT5nlk.ttf"

let defaultFonts = [
    Vibes,
    Changa,
    Amiri,
    Mada,
    Rakkas,
    Tajawal,
    ArefRuqaa,
    Jomhuria,
    Jomhuria,
    Knewave,
    PermanentMarker,
]

@objc(FontsModel)
class FontsModel: NSManagedObject {
    @NSManaged var fontName: String
    @NSManaged var fontData: Data
    @NSManaged var familyName: String
    @NSManaged var variant: String
}


extension FontsModel {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FontsModel> {
        return NSFetchRequest<FontsModel>(entityName: "Fonts")
    }
}

class GoogleFonts: Decodable {
    var items: [items]?
}


struct items : Decodable {
    var family: String
    var variants: [String]
    var files: [String: String]

}


class FontManager {
    static var myfonts: [NSManagedObject] = []

    static let apiKey = "your api Key here"
    static let url = URL(string: "https://www.googleapis.com/webfonts/v1/webfonts?key=\(apiKey)")!
    static let urlPopular = URL(string: "https://www.googleapis.com/webfonts/v1/webfonts?key=\(apiKey)&sort=popularity")!
    static let urlTrending = URL(string: "https://www.googleapis.com/webfonts/v1/webfonts?key=\(apiKey)&sort=trending")!
    static let urlNewest = URL(string: "https://www.googleapis.com/webfonts/v1/webfonts?key=\(apiKey)&sort=date")!
    
    static func saveFonts(FontData: Data,familyName:String, url: String) {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }

      let managedContext = appDelegate.persistentContainer.viewContext
      let entity = NSEntityDescription.entity(forEntityName: "Fonts", in: managedContext)!
      let font = NSManagedObject(entity: entity, insertInto: managedContext)
      font.setValue(FontData, forKeyPath: "fontData")
      font.setValue(familyName, forKeyPath: "familyName")
      font.setValue(url, forKeyPath: "url")
      do {
        try managedContext.save()
        myfonts.append(font)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    // download Font
    private static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
          URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
       }

    static func downloadFont(from url: URL) -> Void {
        getData(from: url) {
           data, response, error in
           guard let data = data, error == nil else {
              return
           }
            let nsData = NSData(data: data)
            guard let cfData = CFDataCreate(kCFAllocatorDefault, nsData.bytes.assumingMemoryBound(to: UInt8.self), nsData.length),
                let dataProvider = CGDataProvider(data: cfData),
                let cgFont = CGFont(dataProvider) else {
                print("Failed to convert data to CGFont.")
                return
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterGraphicsFont(cgFont, &error) {
                  DispatchQueue.main.async {
                    let fontName = cgFont.postScriptName
                    let urlString = String(describing: url)
                    saveFonts(FontData: data, familyName: fontName! as String, url: urlString)
                    print("font is already installed in familyNames - success loading Font!")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadFonts"), object: nil)
                }
                } else {
                DispatchQueue.main.async {
                    let fontName = cgFont.postScriptName
                    let urlString = String(describing: url)
                    saveFonts(FontData: data, familyName: fontName! as String, url: urlString)
                    print("success loading Font!")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadFonts"), object: nil)
                }

            }
        }
    }
    
    
   static func getFonts() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Fonts")

        do {
          myfonts = try managedContext.fetch(fetchRequest)
          for i in 0..<myfonts.count {
              let fontData = myfonts[i].value(forKeyPath: "fontData") as? Data
              let dataProvider = CGDataProvider(data: fontData! as CFData)
              let cgFont = CGFont(dataProvider!)

              var error: Unmanaged<CFError>?
              if !CTFontManagerRegisterGraphicsFont(cgFont!, &error) {
                      print("Error loading Font!")
              } else {
                      print("success loading Font!")
              }
          }
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    static func deleteFonts(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Fonts")

        do {
            let fonts = try managedContext.fetch(fetchRequest)
            for i in 0..<fonts.count {
            let familyName = myfonts[i].value(forKeyPath: "familyName") as? String
                if familyName == name {
                    managedContext.delete(fonts[i])
                }
            }
  
            
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
}
