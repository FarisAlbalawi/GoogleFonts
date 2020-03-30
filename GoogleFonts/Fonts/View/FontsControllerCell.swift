//
//  FontsControllerCell.swift
//  GoogleFonts
//
//  Created by Faris Albalawi on 2/20/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit


class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class FontsControllerCell: BaseCell,UITableViewDelegate, UITableViewDataSource {

    
    lazy var tableView: UITableView = {
        let tableview = UITableView()
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.showsVerticalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = backgroundColor
        tableview.dataSource = self
        tableview.delegate = self
        tableview.contentInset = .init(top: 20, left: 0, bottom: 0, right: 0)
        
        return tableview
    }()

    let cellId = "cellId"

    
    override func setupViews() {
        super.setupViews()

        self.addSubview(tableView)
        self.backgroundColor = backgroundColor
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        tableView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: UITableView.ScrollPosition.top, animated: false)
        
    NotificationCenter.default.addObserver(self, selector: #selector(self.reload(_:)), name: NSNotification.Name(rawValue: "reloadFonts"), object: nil)
        
    }
    
    
    @objc func reload(_ notification:Notification) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
         // #warning Incomplete implementation, return the number of sections
         return 1
     }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         // #warning Incomplete implementation, return the number of rows
        return FontManager.myfonts.count
     }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let name = FontManager.myfonts[indexPath.row].value(forKeyPath: "familyName") as! String
         cell.textLabel?.textColor = .white
         cell.textLabel?.numberOfLines = 1
         cell.textLabel?.minimumScaleFactor = 0.7
         cell.textLabel?.text = name
         cell.textLabel?.font = UIFont(name: name, size: 30)
         cell.backgroundColor = backgroundColor
         cell.selectionStyle = .none
         
         return cell
     }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return 70
     }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let name = FontManager.myfonts[indexPath.row].value(forKeyPath: "familyName") as! String
            FontManager.deleteFonts(name: name)
             FontManager.myfonts.remove(at: indexPath.row)
             tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    
    
}

class addFontControllerCell: BaseCell, UIDocumentPickerDelegate {
    
    var viewController = UIViewController()
    
     let img: UIImageView = {
        let img = UIImageView(image: UIImage(named: "AddFontimage")?.withTintColor(UIColor(red: 64/255, green: 69/255, blue: 78/255, alpha: 1.0)))
         img.contentMode = .scaleAspectFit
         img.backgroundColor = .clear
         img.clipsToBounds = true
         img.translatesAutoresizingMaskIntoConstraints = false
         return img
     }()
    
    let tileLab: UILabel = {
        let tileLab = UILabel()
        tileLab.translatesAutoresizingMaskIntoConstraints = false
        tileLab.textAlignment = .center
        tileLab.textColor = .white
        tileLab.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        tileLab.text = "Add your own Fonts"
        return tileLab
    }()
    
    let messageLab: UILabel = {
        let tileLab = UILabel()
        tileLab.translatesAutoresizingMaskIntoConstraints = false
        tileLab.textAlignment = .center
        tileLab.textColor = UIColor(red: 64/255, green: 69/255, blue: 78/255, alpha: 1.0)
        tileLab.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        tileLab.text = "Add your own personall fonts. \nIt's quick & easy"
        tileLab.sizeToFit()
        tileLab.numberOfLines = 0
        return tileLab
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.9686, green: 0.8, blue: 0.2745, alpha: 1.0)
        button.setTitle("Add Fonts", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        button.layer.cornerRadius = 20
        return button
    }()
    
    
    override func setupViews() {
        super.setupViews()
   
        self.addSubview(tileLab)
        self.addSubview(img)
        self.addSubview(messageLab)
        self.addSubview(button)
        self.button.addTarget(self, action:#selector(didPressAddButton(_:)), for: UIControl.Event.touchUpInside)
        
        NSLayoutConstraint.activate([
            self.img.widthAnchor.constraint(equalToConstant: 80),
            self.img.heightAnchor.constraint(equalToConstant: 80),
            self.img.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.img.topAnchor.constraint(equalTo: self.topAnchor,constant: 30),
            
            self.tileLab.topAnchor.constraint(equalTo: self.img.bottomAnchor,constant: 10),
            self.tileLab.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.messageLab.topAnchor.constraint(equalTo: self.tileLab.bottomAnchor,constant: 10),
            self.messageLab.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.button.widthAnchor.constraint(equalToConstant: 140),
            self.button.heightAnchor.constraint(equalToConstant: 40),
            self.button.topAnchor.constraint(equalTo: self.messageLab.bottomAnchor,constant: 10),
            self.button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            
          ])

    }
    

    
    @objc func didPressAddButton(_ sender: UIButton) {
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.truetype-ttf-font", "public.opentype-font"], in: UIDocumentPickerMode.import)
            documentPicker.delegate = self
        self.viewController.present(documentPicker, animated: true, completion: nil)
      }

    // MARK: - UIDocumentPickerDelegate Methods
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
          FontManager.downloadFont(from: urls.first!)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

