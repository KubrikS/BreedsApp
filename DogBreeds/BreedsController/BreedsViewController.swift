//
//  ViewController.swift
//  DogBreeds
//
//  Created by Stanislav on 22.08.2020.
//  Copyright © 2020 St. Kubrik. All rights reserved.
//

import UIKit

class BreedsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    private let networkService = FetchBreed()
    private var model = BreedsModel()
    private var allBreeds = [BreedsModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Отправляю запрос на сервер
        fetchBreeds()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        
        // При переходе на следующий контроллер передаю данные для отображения
        if let subBreedVC = segue.destination as? SubBreedsViewController {
            // при переходе на SubBreedsViewController передаю породу и подпороду с выбранной ячейки
            let breed = allBreeds[indexPath.row].breed
            let subBreed = allBreeds[indexPath.row].subBreed
            subBreedVC.setBreeds(breed, subBreed: subBreed)
            
            // устанавливаю title
            subBreedVC.navigationItem.title = breed.localizedCapitalized
        }
        
        if let imageVC = segue.destination as? ImageViewController {
            // При переходе на ImageViewController передаю путь для картинки
            let breed = allBreeds[indexPath.row].breed
            imageVC.setPathToImage(breed, breed: breed)
            
            // устанавливаю title
            imageVC.navigationItem.title = breed.localizedCapitalized
        }
    }
    
}

extension BreedsViewController {
    private func fetchBreeds() {
        networkService.fetchBreed(for: BreedName(), completion: { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    for breedName in response.message.keys {
                        // полученные данные присваиваю экземпляру модели породы и добавляю ко всем породам
                        self.model.breed = breedName
                        self.model.subBreed = response.message[breedName] ?? []
                        self.allBreeds.append(self.model)
                        self.allBreeds.sort(by: {first, second  in first.breed < second.breed}) // сортирую все породы по алфавиту
                    }
                    self.tableView.reloadData()
                }
            case .failure(let error as URLError) where error.code == .notConnectedToInternet:
                let alert = UIAlertController(title: "Some server error", message: "Try connect later", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
}

extension BreedsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allBreeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "breedCell", for: indexPath) as! BreedsTableViewCell
        cell.breedLabel.text = allBreeds[indexPath.row].breed.localizedCapitalized
        
        // Если у породы нет подпороды, то прячу лейбл с количеством подпород. Если подпороды есть, то отображаю лейбл
        if allBreeds[indexPath.row].subBreed.count == 0 {
            cell.subBreedLabel.isHidden = true
        } else {
            cell.subBreedLabel.text = "\(allBreeds[indexPath.row].subBreed.count) subbreeds"
            cell.subBreedLabel.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let breed = allBreeds[indexPath.row]
        
        // Если кол-во подпород = 0, то перехожу сразу на экран отображения картинок, в противном случае на экран подпород
        if breed.subBreed.count == 0 {
            performSegue(withIdentifier: "imageBreedSegue", sender: nil)
        } else {
            performSegue(withIdentifier: "subBreedsSegue", sender: nil)
        }
    }
}

