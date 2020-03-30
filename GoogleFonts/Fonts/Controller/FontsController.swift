//
//  FontsController.swift
//  GoogleFonts
//
//  Created by Faris Albalawi on 2/20/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit
import CoreData

class FontsController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    

    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.fontController = self
        return mb
    }()
    
    
    let cellId = "cellId"
    let addFontCellId = "addFontCellId"
    let googleCell = "googleFontsCell"
    let titles = ["Downloaded", "Search", "Custom"]

    var FontsArray = [items]()
     var fonts: [NSManagedObject] = []
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = .black
        searchController.searchBar.backgroundColor = topColor
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.placeholder = "Search Fonts"
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchResultsUpdater = self
        searchController.searchBar.backgroundColor = topColor
        searchController.searchBar.clearBackgroundColor()
        searchController.delegate = self
        searchController.searchBar.delegate = self
        if let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField,
                let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
                    glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                    glassIconView.tintColor = UIColor(red: 0.4667, green: 0.4667, blue: 0.4706, alpha: 1.0)
            }
        return searchController
    }()
    
    
    let searchView: UIView = {
        let searchView = UIView()
        searchView.translatesAutoresizingMaskIntoConstraints = false
        searchView.backgroundColor = .clear
        return searchView
        
    }()

    var editeButtonItem: UIBarButtonItem?

      var searchViewHeightAnchor = NSLayoutConstraint()
      var menuBarHeightAnchor = NSLayoutConstraint()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.overrideUserInterfaceStyle = .light
       
        self.view.backgroundColor = topColor
         self.title = "Downloaded"
         self.navigationController?.navigationBar.titleTextAttributes = [
             NSAttributedString.Key.foregroundColor : UIColor.white
         ]
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = topColor
        self.navigationController?.navigationBar.tintColor = .white
        self.setupCollectionView()

       editeButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: Selector(("showEditing:")))
         self.navigationItem.rightBarButtonItem = editeButtonItem
         
        
        self.extendedLayoutIncludesOpaqueBars = true
        definesPresentationContext = true
    }

    

    
    func setupCollectionView() {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
        collectionView.backgroundColor = backgroundColor
        collectionView.register(FontsControllerCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(addFontControllerCell.self, forCellWithReuseIdentifier: addFontCellId)
        collectionView.register(googleFontsCell.self, forCellWithReuseIdentifier: googleCell)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        collectionView.isPagingEnabled = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        menuBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        self.view.addSubview(menuBar)
        self.view.addSubview(searchView)
        self.searchView.addSubview(searchController.searchBar)
        
        searchViewHeightAnchor = self.searchView.heightAnchor.constraint(equalToConstant: 50)
        menuBarHeightAnchor = self.menuBar.heightAnchor.constraint(equalToConstant: 50)
        NSLayoutConstraint.activate([
            self.searchView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.searchView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            searchViewHeightAnchor,
            
            self.menuBar.topAnchor.constraint(equalTo: self.searchView.bottomAnchor),
            self.menuBar.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            menuBarHeightAnchor,
            
            self.collectionView.topAnchor.constraint(equalTo: self.menuBar.bottomAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        
        ])
        
    }


    @objc func showEditing(_ sender: UIBarButtonItem) {
       let indexPath = IndexPath(item: 0, section: 0)
       let cell = self.collectionView.cellForItem(at: indexPath) as! FontsControllerCell
       cell.tableView.setEditing(!cell.tableView.isEditing, animated: true)

       if cell.tableView.isEditing {
           sender.title = "Done"
        self.collectionView.isScrollEnabled = false
        self.searchView.isHidden = true
        self.menuBar.isHidden = true
        searchViewHeightAnchor.constant = 0
        menuBarHeightAnchor.constant = 0
        UIView.animate(withDuration: 0.3) {
          self.view.layoutIfNeeded()
          self.collectionView.layoutIfNeeded()
          self.collectionView.reloadData()
        }
        

        } else {
            sender.title = "Edit"
          self.collectionView.isScrollEnabled = true
          self.searchView.isHidden = false
          self.menuBar.isHidden = false
          self.searchViewHeightAnchor.constant = 50
          self.menuBarHeightAnchor.constant = 50
          UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.collectionView.layoutIfNeeded()
            self.collectionView.reloadData()
          }
        
                           
        }
    }
    
}

extension FontsController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text?.count != 0 {
            let indexPath = IndexPath(item: 1, section: 0)
            let cell = self.collectionView.cellForItem(at: indexPath) as! googleFontsCell
            cell.searchFont(keyWords: searchController.searchBar.text!)
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        let indexPath = IndexPath(item: 1, section: 0)
        let cell = self.collectionView.cellForItem(at: indexPath) as! googleFontsCell
        cell.searchFont(keyWords: "")
        self.collectionView.isScrollEnabled = true
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            self.collectionView.layoutIfNeeded()
            self.collectionView.reloadData()
            
        }
    }
    
    func presentSearchController(_ searchController: UISearchController) {
         self.scrollToMenuIndex(menuIndex: 1)
         self.collectionView.isScrollEnabled = false
         UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            self.collectionView.layoutIfNeeded()
            self.collectionView.reloadData()
            
              
          }
    }

}


extension FontsController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        setTitleForIndex(index: menuIndex)
    }
    
    private func setTitleForIndex(index: Int) {
        if index == 0 {
             self.navigationItem.rightBarButtonItem = editeButtonItem
        } else {
             self.navigationItem.rightBarButtonItem = nil
        }
        self.title = "\(titles[index])"
  
     
    }

    
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 3
    }
    
     func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(targetContentOffset.pointee.x / view.frame.width)
        let indexPath = IndexPath(item: index, section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        setTitleForIndex(index: index)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FontsControllerCell
            cell.layoutIfNeeded()
            cell.updateConstraints()
            return cell
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: googleCell, for: indexPath) as! googleFontsCell
            cell.navigationController = self.navigationController!
            cell.layoutIfNeeded()
            cell.updateConstraints()
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addFontCellId, for: indexPath) as! addFontControllerCell
             cell.layoutIfNeeded()
             cell.updateConstraints()
             cell.viewController = self
            
            return cell
        }

        
        
    }
    
   @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height - 10)
    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension UISearchBar {

    func clearBackgroundColor() {
        guard let UISearchBarBackground: AnyClass = NSClassFromString("UISearchBarBackground") else { return }

        for view in self.subviews {
            for subview in view.subviews {
                if subview.isKind(of: UISearchBarBackground) {
                    subview.alpha = 0
                }
            }
        }
    }
}
