//
//  FavouriteImageViewController.swift
//  DogBreeds
//
//  Created by Stanislav on 05.09.2020.
//  Copyright © 2020 St. Kubrik. All rights reserved.
//

import UIKit
import CoreData

class FavouriteImageViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    private var links = [String]()
    private var currentBreed = ""
    private var images = [UIImage]()
    private lazy var coreDataStack = CoreDataStack(modelName: "FavouriteBreed")
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBAction func sharedButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Shared Photo", message: nil, preferredStyle: .actionSheet)
        let share = UIAlertAction(title: "Share", style: .default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(share)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteFavouriteButton(_ sender: UIButton) {
        guard let indexPath = collectionView.indexPathsForVisibleItems.first else { return }
        let url = links[indexPath.row]
        let request = NSFetchRequest<Breed>(entityName: "Breed")
        
        if let existingBreeds = (try? coreDataStack.managedContext.fetch(request)) {
            for breed in existingBreeds {
                if breed.name == currentBreed {
                    
                    if !breed.link.contains(where: { $0.url == url }) {
                        let link = Link(context: coreDataStack.managedContext)
                        link.url = url
                        breed.link.insert(link)
                        sender.tintColor = .systemPink
                    } else {
                        for link in breed.link {
                            if link.url == url {
                                breed.link.remove(link)
                                sender.tintColor = .lightGray
                            }
                        }
                    }
                    
                    if breed.link.count == 0 {
                        coreDataStack.managedContext.delete(breed)
                    }
                }
            }
        }
        coreDataStack.saveContext()
    }
    
    private func setImage() {
        for link in links {
            DispatchQueue.global().async {
                let link = URL(string: link)
                guard let url = link else { return }
                guard let data = try? Data(contentsOf: url) else {
                    let alert = UIAlertController(title: "Some server error", message: "Try connect later", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                    self.activityIndicator.stopAnimating()
                    return
                }
                
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
                    guard let image = UIImage(data: data) else { return }
                    self.images.append(image)
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    // Метод получения текущей породы и массива ссылок
    func setBreedAndLinks(breed: String, links: [String]) {
        self.currentBreed = breed
        self.links = links
    }

}

extension FavouriteImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! FavouriteImageViewCell
        cell.imageLabel.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = UIScreen.main.bounds.size.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top
        let size = CGSize(width: UIScreen.main.bounds.size.width, height: height)
        return size
    }
}


