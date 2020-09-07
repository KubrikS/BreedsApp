//
//  FavouriteViewController.swift
//  DogBreeds
//
//  Created by Stanislav on 24.08.2020.
//  Copyright © 2020 St. Kubrik. All rights reserved.
//

import UIKit
import CoreData

class FavouriteViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    private lazy var coreDataStack = CoreDataStack(modelName: "FavouriteBreed")
    private lazy var breedsFetchRequest = NSFetchRequest<Breed>(entityName: "Breed")
    private lazy var fetchedResultsController: NSFetchedResultsController<Breed> = {
            let fetchRequest: NSFetchRequest<Breed> = Breed.fetchRequest()
            let sort = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sort]
            
            let fetchedResultsController = NSFetchedResultsController( fetchRequest: fetchRequest,
                                                                       managedObjectContext: coreDataStack.managedContext,
                                                                       sectionNameKeyPath: nil,
                                                                       cacheName: nil)
            return fetchedResultsController
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Перед каждой загрузкой контроллера делаю запрос на получение объектов из CoreData и перезагружаю таблицу для отображение актуальных данных
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        tableView.reloadData()
    }
    
    // Метод конфигурации ячейки
    private func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? FavouriteTableViewCell else { return }
        let breed = fetchedResultsController.object(at: indexPath)
        
        cell.breedLabel.text = breed.name.localizedCapitalized
        cell.imageCount.text = "\(breed.link.count) photos"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let breed = fetchedResultsController.object(at: indexPath)
        
        if let imageVC = segue.destination as? FavouriteImageViewController {
            var links = [String]()
            
            for link in breed.link {
                guard let url = link.url else { return }
                links.append(url)
            }
            // при переходе на FavouriteImageViewController передаю выбранную породу и все ее ссылки для отображения фото
            imageVC.setBreedAndLinks(breed: breed.name, links: links)
            imageVC.navigationItem.title = breed.name.localizedCapitalized
        }
    }
}



extension FavouriteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let count = fetchedResultsController.sections?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections?[section] else { return 0 }
        return sections.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteCell", for: indexPath) as! FavouriteTableViewCell
        configure(cell: cell, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "FavouriteImageSegue", sender: nil)
    }
}



extension FavouriteViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? FavouriteTableViewCell {
                let breed = fetchedResultsController.object(at: indexPath)
                cell.breedLabel.text = breed.name.localizedCapitalized
                cell.imageCount.text = "\(breed.link.count) photos"
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
