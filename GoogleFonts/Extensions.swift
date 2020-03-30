//
//  Extensions.swift
//  GoogleFonts
//
//  Created by Faris Albalawi on 2/20/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

let backgroundColor = UIColor(red: 0.1569, green: 0.1725, blue: 0.2039, alpha: 1.0)
let barColor = UIColor(red: 0.1294, green: 0.1451, blue: 0.1686, alpha: 1.0)
let sideColor = UIColor(red: 0.2, green: 0.2196, blue: 0.2588, alpha: 1.0)
let pinkColor = UIColor(red: 0.5059, green: 0.3412, blue: 0.5765, alpha: 1.0)
let redColor = UIColor(red: 0.7529, green: 0.3804, blue: 0.4157, alpha: 1.0)
let greenColor = UIColor(red: 0.5961, green: 0.7647, blue: 0.4745, alpha: 1.0)
let yellowColor = UIColor(red: 0.9412, green: 0.7373, blue: 0.3686, alpha: 1.0)
let blueColor = UIColor(red: 0.3373, green: 0.5843, blue: 0.7922, alpha: 1.0)
let ButtonColor = UIColor(red: 0.5843, green: 0.6157, blue: 0.6706, alpha: 1.0)
let topColor = UIColor(red: 0.1725, green: 0.1922, blue: 0.2275, alpha: 1.0)


extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIView {
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
