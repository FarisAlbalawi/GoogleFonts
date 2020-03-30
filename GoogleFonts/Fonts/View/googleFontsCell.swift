//
//  googleFontsCell.swift
//  GoogleFonts
//
//  Created by Faris Albalawi on 2/20/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation
import UIKit
import WebKit



class googleFontsCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = backgroundColor
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

     let img: UIImageView = {
        let img = UIImageView(image: UIImage(named: "FontNoSearch")?.withTintColor(UIColor(red: 64/255, green: 69/255, blue: 78/255, alpha: 1.0)))
         img.contentMode = .scaleAspectFit
         img.backgroundColor = .clear
         img.clipsToBounds = true
         img.translatesAutoresizingMaskIntoConstraints = false
         return img
     }()
    
    
    let errorLab: UILabel = {
        let errorLab = UILabel()
        errorLab.translatesAutoresizingMaskIntoConstraints = false
        errorLab.textAlignment = .center
        errorLab.textColor = .systemFill
        errorLab.text = "No data found - Try again :("
        errorLab.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return errorLab
    }()
    
    
    var navigationController = UINavigationController()
    
    
    
    let cellId = "cellId"

    var FontsArray = [items]()
    var searchFont = [items]()
    let activityIndicator = UIActivityIndicatorView()
    
    override func setupViews() {
        super.setupViews()

        backgroundColor = backgroundColor
        addSubview(collectionView)
     
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(goFontsCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        collectionView.isHidden = true
        activityIndicator.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        addSubview(activityIndicator)
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        
        self.addSubview(self.img)
        self.addSubview(self.errorLab)
        self.errorLab.isHidden = true
        self.img.isHidden = true
        NSLayoutConstraint.activate([
            self.img.widthAnchor.constraint(equalToConstant: 120),
            self.img.heightAnchor.constraint(equalToConstant: 120),
            self.img.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.img.topAnchor.constraint(equalTo: self.topAnchor,constant: 50),
            
            self.errorLab.topAnchor.constraint(equalTo: self.img.bottomAnchor,constant: 10),
            self.errorLab.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            self.convertGoogleFontsJson()
        }
       
    }
    
    
    func searchFont(keyWords: String) {
        if keyWords.count != 0 {
            let matchingFonts = FontsArray.filter({
                $0.family.range(of: keyWords, options: .caseInsensitive) != nil
            })
            self.searchFont = matchingFonts
            self.collectionView.reloadData()
            
            if matchingFonts.count == 0 {
                self.errorLab.isHidden = false
                self.img.isHidden = false
                self.collectionView.isHidden = true
            } else {
                self.errorLab.isHidden = true
                self.img.isHidden = true
                self.collectionView.isHidden = false
            }

        } else {
            self.searchFont = FontsArray
            self.collectionView.reloadData()
        }


    }

    
     // MARK: convert Google FontsJson
     func convertGoogleFontsJson() {
         var request = URLRequest(url: FontManager.urlTrending)
         request.httpMethod = "GET"
         URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
             if let data = data {
                 if let decodedResponse = try? JSONDecoder().decode(GoogleFonts.self, from: data) {
                     DispatchQueue.main.async {
                        self.FontsArray = decodedResponse.items!
                        self.searchFont = decodedResponse.items!
                        self.collectionView.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.collectionView.isHidden = false
                       
              
                     }
                     return
                 }
             }
             
             // if we're still here it means there was a problem
             self.activityIndicator.stopAnimating()
             self.activityIndicator.isHidden = true
             print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
    
         }).resume()
     }
        
   @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.searchFont.count
    }
    
   @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! goFontsCell
        let fonts =  self.searchFont[indexPath.row]
        DispatchQueue.main.async {
             cell.loadFont(family: fonts.family, style: fonts.variants[0])
        }
       
        cell.nameLab.text = fonts.family
        cell.stylesLab.text = "Styles (\(fonts.variants.count))"
        return cell
    }
    
   @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: frame.width, height: 200)
    }
    
   @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
   @objc func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let aVC = GoFontsDetailsController()
        aVC.goFontArray = self.searchFont[indexPath.row]
        self.navigationController.pushViewController(aVC, animated: true)
    }
    
    
}



class goFontsCell: BaseCell {

    let view: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = topColor
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
    
    let stylesLab: UILabel = {
        let stylesLab = UILabel()
        stylesLab.translatesAutoresizingMaskIntoConstraints = false
        stylesLab.textAlignment = .center
        stylesLab.textColor = UIColor(red: 0.4667, green: 0.4667, blue: 0.4706, alpha: 1.0)
        stylesLab.font = UIFont.systemFont(ofSize: 18, weight: .light)
        return stylesLab
    }()
    
    
    override func setupViews() {
 
        self.addSubview(view)
        self.view.addSubview(nameLab)
        self.view.addSubview(stylesLab)
        self.view.addSubview(webView)

        NSLayoutConstraint.activate([
            self.view.topAnchor.constraint(equalTo: self.topAnchor,constant: 5),
            self.view.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -5),
            self.view.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -10),
            self.view.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 10),
            
            self.nameLab.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 10),
            self.nameLab.leftAnchor.constraint(equalTo: self.view.leftAnchor,constant: 10),
            self.stylesLab.topAnchor.constraint(equalTo: self.nameLab.bottomAnchor,constant: 10),
            self.stylesLab.leftAnchor.constraint(equalTo: self.view.leftAnchor,constant: 10),
            
            self.webView.topAnchor.constraint(equalTo: self.stylesLab.bottomAnchor,constant: 10),
            self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -10),
            self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 10),
            self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,constant: -5),
            
        ])
    }

    
    func loadFont(family: String, style: String) {
        let html = """
                    <!DOCTYPE html>
                    <html>
                    <head>
                    <link href='https://fonts.googleapis.com/css?family=\(family):400' rel='stylesheet'>
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
