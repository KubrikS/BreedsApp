//
//  ImageViewController.swift
//  DogBreeds
//
//  Created by Stanislav on 23.08.2020.
//  Copyright © 2020 St. Kubrik. All rights reserved.
//

import UIKit
import CoreData

class ImageViewController: UIViewController {
    
    private var pathToImage = "" // путь для фото
    private var currentBreed = "" // текущая порода
    private let networkService = FetchBreed()
    private var image = [UIImage]()
    private var links = [String]()
    private lazy var coreDataStack = CoreDataStack(modelName: "FavouriteBreed")
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBAction func sharedButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Shared Photo", message: nil, preferredStyle: .actionSheet)
        let share = UIAlertAction(title: "Share", style: .default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(share)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    @IBOutlet var button: UIButton!
    @IBAction func addFavouriteBreedButton(_ sender: UIButton) {
        guard let indexPath = collectionView.indexPathsForVisibleItems.first else { return }
        let url = links[indexPath.row] // url текущей картинки
        let request = NSFetchRequest<Breed>(entityName: "Breed")
        
        // получаю массив объектов CoreData
        if var existingBreeds = (try? coreDataStack.managedContext.fetch(request)) {
            
            // если существующие породы не содержат породу с текущим именем
            if !existingBreeds.contains(where: { $0.name == currentBreed}) {
                // то создаю новый объект породы, присваиваю текущее имя и добавляю к существующим
                let breed = Breed(context: coreDataStack.managedContext)
                breed.name = currentBreed
                existingBreeds.append(breed)
            }
        
            // достаю каждую породу из существующих пород
            for breed in existingBreeds {
                if breed.name == currentBreed { // если имя существующей породы совпадает с текушей породой
                    // то создаю объект ссылки
                    let link = Link(context: coreDataStack.managedContext)
                        // и если порода не содержит выбранную ссылку, то добавляю ее к существующей породе
                        if !breed.link.contains(where: { $0.url == url}) {
                            link.url = url
                            breed.link.insert(link)
                            sender.tintColor = .systemPink
                        } else { // в противном случае удалаю это ссылку и существующей породы
                            for link in breed.link {
                                if link.url == url {
                                    breed.link.remove(link)
                                    sender.tintColor = .lightGray
                                }
                            }
                        }

                    // если количество ссылок у существующей породы = 0, то удаляю эту породу из CoreData
                    if breed.link.count == 0 {
                        coreDataStack.managedContext.delete(breed)
                    }
                    
                }
            }
            coreDataStack.saveContext()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchPhoto(pathToImage)
    }
   
    private func fetchPhoto(_ breedName: String) {
        networkService.fetchBreedImage(for: BreedImage(breed: breedName), completion: { result in
            switch result {
            case .success(let response):
                // чтобы не блокировать UI, получаю все ссылки асинхронно на глобальной очереди
                DispatchQueue.global().async {
                    for link in response.message {
                        self.links.append(link) // ссылки для проверки на наличие таких же в CoreData
                        let link = URL(string: link)
                        guard let url = link else { return }
                        guard let data = try? Data(contentsOf: url) else { return }
                        
                        // асинхронно на главной кладу фото в массив фотографий и перезагружаю collectionView и отображаю их
                        DispatchQueue.main.async {
                            self.activityIndicator.startAnimating()
                            guard let imageView = UIImage(data: data) else { return }
                            self.image.append(imageView)
                            self.collectionView.reloadData()
                            self.activityIndicator.stopAnimating()
                        }
                        
                    }
                }
            case .failure(let error as URLError) where error.code == .notConnectedToInternet:
                let alert = UIAlertController(title: "Some server error", message: "Try connect later", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                self.activityIndicator.stopAnimating()
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    func setPathToImage(_ path: String, breed: String) {
        self.pathToImage = path
        self.currentBreed = breed
    }
}



extension ImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return image.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        let url = links[indexPath.row]
        cell.imageLabel.image = image[indexPath.row]
        
        let request = NSFetchRequest<Breed>(entityName: "Breed")
        if let existingBreeds = (try? coreDataStack.managedContext.fetch(request)) {
            for breed in existingBreeds {
                if breed.name == currentBreed {
                    if breed.link.contains(where: { $0.url == url }) {
                            cell.favouriteButton.tintColor = .systemPink
                        } else {
                            cell.favouriteButton.tintColor = .lightGray
                        }
                    }
                }
            }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = UIScreen.main.bounds.size.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top
        let size = CGSize(width: UIScreen.main.bounds.size.width, height: height)
        return size
    }
    
}
