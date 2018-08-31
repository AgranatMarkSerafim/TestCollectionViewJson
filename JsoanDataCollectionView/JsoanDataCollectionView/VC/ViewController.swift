//
//  ViewController.swift
//  JsoanDataCollectionView
//  Created by Вячеслав Лойе on 25.01.2018.
//  Copyright © 2018 Вячеслав Лойе. All rights reserved.

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate  {

    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: Properties
     var imageView: UIImageView!
    private var heroes = [Heros]()
    private var searchResult = [Heros]()
    private let indetifire = "customCell"

    private var searchController: UISearchController!
    private var refreshControll: UIRefreshControl!

    // MARK: Overriden funcs viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControllSpiner()
        searchBar()
        parsJson()
    }

    // MARK: SearchBar (private func)
    private func searchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for tools and resources" // Поиск троллей
        searchController.searchBar.sizeToFit()
        searchController.searchBar.becomeFirstResponder()
        navigationItem.titleView = searchController.searchBar
        searchController.searchResultsUpdater = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    //MARK: - RefreshControl (private funcs)
    private func refreshControllSpiner() {
        refreshControll = UIRefreshControl()
        collectionView.addSubview(refreshControll)
        refreshControll.backgroundColor = UIColor.clear
        refreshControll.tintColor = UIColor.red
        refreshControll.endRefreshing()
        //reloadData()
    }

    //MARK: - RefreshControl (private funcs)
    private func spinnerImageRefresh() {
            let spinnerImage = UIImage(named: "download-1")
            imageView = UIImageView(frame: CGRect(x: imageView.center.x, y: 10, width: 116, height: 116))
            imageView.contentMode = .scaleAspectFill
            imageView.image = spinnerImage
            refreshControll.addSubview(imageView)
        }

    //MARK: - JSON_Decodable (func)
    func parsJson()  {
        let url = URL(string: URL_SESSION)
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if error == nil {
                do {
                    self.heroes = try JSONDecoder().decode([Heros].self, from: data!)
                } catch {
                    print("Parse Error")
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    print("Pars Json")
                }
            }
        }.resume()
    }

    //MARK: - UpdateSearch (func)
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(searchText: searchText)
            collectionView.reloadData()
        }
    }

    //MARK: - FilterContent (fileprivate func)
    fileprivate func filterContent(searchText: String) {
        searchResult = heroes.filter({(newsHeroes: Heros) -> Bool in
            let nameMatch = newsHeroes.localized_name.range(of: searchText, options: String.CompareOptions.caseInsensitive)
            let locationMath = newsHeroes.img.range(of: searchText, options: String.CompareOptions.caseInsensitive)
            return nameMatch != nil || locationMath != nil
        })
    }

    //MARK: - UICollectionViewDataSource (func)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchController.isActive {
            return searchResult.count
        } else {
            return heroes.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: indetifire, for: indexPath) as! CustomCollectionViewCell
        let newHeroes = (searchController.isActive) ? searchResult[indexPath.row] : heroes[indexPath.row]
        cell.labelCl.text = newHeroes.localized_name.capitalized
        let defaultLink  = OPEN_DOTA
        let completeLink = defaultLink + newHeroes.img
        cell.imageView.downloadedFrom(link: completeLink)
        cell.imageView.tintColor = UIColor.black
        cell.imageView.tintColorDidChange()
        cell.imageView.layer.borderWidth = 4
        cell.imageView.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.cornerRadius = cell.imageView.bounds.height / 2
        cell.imageView.contentMode = .scaleAspectFill

        return cell
    }
    // MARK: Private func (collectionView)
    private func collectionView(_ collectionView: UICollectionView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        if searchController.isActive {
            return false
        } else {
            return true
        }
    }
}

	//MARK: - Extension UIImageView (private extension)
private extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }

    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
