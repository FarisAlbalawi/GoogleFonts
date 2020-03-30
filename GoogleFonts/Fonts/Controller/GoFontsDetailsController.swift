//
//  GoFontsDetailsController.swift
//  GoogleFonts
//
//  Created by Faris Albalawi on 2/20/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit
import WebKit

class GoFontsDetailsController: UITableViewController {

    var goFontArray: items!

    var urlsArray = [String]()

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        for i in 0..<FontManager.myfonts.count {
            let url = FontManager.myfonts[i].value(forKeyPath: "url") as! String
            urlsArray.append(url)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = goFontArray.family
        self.view.backgroundColor = backgroundColor
        self.tableView.backgroundColor = backgroundColor
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.register(GoFontsTVCell.self, forCellReuseIdentifier: "GoFontsTVCell")
        self.tableView.reloadData()

    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return goFontArray.variants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoFontsTVCell", for: indexPath) as! GoFontsTVCell
      
        let variant = getVariants(variant: goFontArray.variants[indexPath.row])
        cell.nameLab.text = variant
        DispatchQueue.main.async {
            cell.loadFont(family: self.goFontArray.family, style: self.goFontArray.variants[indexPath.row])
        }
        
        
        let style = self.goFontArray.variants[indexPath.row]
        let url = self.goFontArray.files[style]
        if urlsArray.contains(url!) {
            cell.downloadButton.backgroundColor = .systemFill
            cell.downloadButton.setTitle("Added", for: .normal)
        } else {
            cell.downloadButton.addTarget(self, action:#selector(didPressDownloadButton(_:)), for: UIControl.Event.touchUpInside)
        }
        

        cell.downloadButton.tag = indexPath.row
        cell.backgroundColor = backgroundColor
        cell.selectionStyle = .none
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 220
    }

    
    
    
    @objc func didPressDownloadButton(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
             let generator = UIImpactFeedbackGenerator(style: .heavy)
             generator.impactOccurred()
         }
        
        let indexPath = IndexPath(item: sender.tag, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath) as! GoFontsTVCell
        cell.downloadButtonWidth.constant = 40
        UIView.animate(withDuration: 0.2) {
            cell.layoutIfNeeded()
        }
        cell.activityIndicator.isHidden = false
        cell.activityIndicator.startAnimating()
        sender.isEnabled = false
        sender.setTitle(nil, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            let variant = self.goFontArray.variants[sender.tag]
            let url = self.goFontArray.files[variant]
            print(url!)
            let urls = URL(string: url!)
            FontManager.downloadFont(from: urls!)
            cell.activityIndicator.isHidden = true
            cell.downloadButtonWidth.constant =  cell.frame.width/1.2
            sender.setTitle("Added", for: .normal)
            sender.backgroundColor = .systemFill
            sender.isEnabled = false
            UIView.animate(withDuration: 0.2) {
                  cell.layoutIfNeeded()
              }
        }

     
    }
  
    

    
    func getVariants(variant: String) -> String {
        if variant == "100" {
            return "Thin"
        } else if variant == "100italic" {
            return "Thin Italic"
        } else if variant == "200" {
            return "Extra Light"
        } else if variant == "200italic" {
            return "Extra Light Italic"
        } else if variant == "300" {
            return "Light"
        } else if variant == "300italic" {
            return "Light Italic"
        } else if variant == "regular" {
            return "Regular"
        } else if variant == "italic" {
            return "Regular Italic"
        } else if variant == "500" {
            return "Medium"
        } else if variant == "500italic" {
            return "Medium Italic"
        } else if variant == "600" {
            return "Semi-Bold"
        } else if variant == "600italic" {
            return "Semi-Bold Italic"
        } else if variant == "700" {
            return "Bold"
        } else if variant == "700italic" {
            return "Bold Italic"
        } else if variant == "800" {
            return "Extra-Bold"
        } else if variant == "800italic" {
            return "Extra-Bold Italic"
        } else if variant == "900" {
            return "Black"
        } else if variant == "900italic" {
            return "Black Italic"
        } else {
            return "unknow"
        }
        
    }


}


class GoFontsTVCell: UITableViewCell {
    
       let view: UIView = {
           let view = UIView()
           view.translatesAutoresizingMaskIntoConstraints = false
           view.backgroundColor = topColor
           view.layer.cornerRadius = 10
           return view
       }()
       let webView: WKWebView = {
           let webView = WKWebView()
           webView.scrollView.isScrollEnabled = false
           webView.backgroundColor = topColor
           webView.translatesAutoresizingMaskIntoConstraints = false
           webView.configuration.suppressesIncrementalRendering = true
           webView.isOpaque = false
           return webView
           
       }()
       
       let nameLab: UILabel = {
           let nameLab = UILabel()
           nameLab.translatesAutoresizingMaskIntoConstraints = false
           nameLab.textAlignment = .center
           nameLab.textColor = .white
           nameLab.font = UIFont.systemFont(ofSize: 20, weight: .bold)
           return nameLab
       }()
       
    let downloadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Download", for: .normal)
        button.backgroundColor = .systemBlue
        return button
    }()
       
    let activityIndicator : UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    var downloadButtonWidth = NSLayoutConstraint()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
    
           self.addSubview(view)
           self.view.addSubview(nameLab)
           self.view.addSubview(webView)
           self.view.addSubview(downloadButton)
           self.downloadButton.addSubview(activityIndicator)
           self.activityIndicator.isHidden = true

           downloadButtonWidth = self.downloadButton.widthAnchor.constraint(equalToConstant: self.frame.width/1.2)
           NSLayoutConstraint.activate([
               self.view.topAnchor.constraint(equalTo: self.topAnchor,constant: 5),
               self.view.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -5),
               self.view.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -10),
               self.view.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 10),
               
               self.nameLab.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 10),
               self.nameLab.leftAnchor.constraint(equalTo: self.view.leftAnchor,constant: 10),
          
               self.webView.topAnchor.constraint(equalTo: self.nameLab.bottomAnchor,constant: 10),
               self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -10),
               self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 10),
               self.webView.bottomAnchor.constraint(equalTo: self.downloadButton.topAnchor,constant: -5),
               
               self.activityIndicator.centerYAnchor.constraint(equalTo: self.downloadButton.centerYAnchor),
               self.activityIndicator.centerXAnchor.constraint(equalTo: self.downloadButton.centerXAnchor),
               self.downloadButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,constant: -10),
               self.downloadButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
               self.downloadButtonWidth,
               self.downloadButton.heightAnchor.constraint(equalToConstant: 40)
               
           ])
       }

       
       func loadFont(family: String, style: String) {
           let html = """
                       <!DOCTYPE html>
                       <html>
                       <head>
                       <link href='https://fonts.googleapis.com/css?family=\(family):\(style)' rel='stylesheet'>
                       <style>
                       body {
                         background-color: #2d3139;
                       }
                       .center {
                        text-align: center
                       }

                       body {
                           font-family: '\(family)';font-size: 50px;
                       }
                       </style>
                       </head>
                       <body>

                       <h1 class="center" style="color:white;">Hello word</h1>

                       </body>
                       </html>
                    """
           
           self.webView.loadHTMLString(html, baseURL: nil)
       
       }
       
       
       func webView(_ webView: WKWebView,didFinish navigation: WKNavigation!){
               print("loaded")
            self.webView.isHidden = false
       }
       
    
}
