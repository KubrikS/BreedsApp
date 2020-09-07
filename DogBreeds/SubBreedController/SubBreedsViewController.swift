//
//  SubBreedsViewController.swift
//  DogBreeds
//
//  Created by Stanislav on 02.09.2020.
//  Copyright © 2020 St. Kubrik. All rights reserved.
//

import UIKit

class SubBreedsViewController: UIViewController {
    private var breed = ""
    private var subBreeds = [String]().sorted()
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        if let imageVC = segue.destination as? ImageViewController {
            // при переходе на контроллер отображения фото, передаю путь для картинки
            let subBreed = subBreeds[indexPath.row]
            imageVC.setPathToImage(breed + "/\(subBreed)", breed: subBreed)
            
            // устанавливаю title
            imageVC.navigationItem.title = subBreed.localizedCapitalized
        }
    }
    
    // Метод для изменнеия текущей породы и подпороды
    func setBreeds(_ breed: String, subBreed: [String]) {
        self.breed = breed
        self.subBreeds = subBreed
    }
}

extension SubBreedsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subBreeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subBreedCell", for: indexPath) as! SubBreedsTableViewCell
        cell.subBreedLabel.text = subBreeds[indexPath.row].localizedCapitalized
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "imageBreedSegue", sender: nil)
    }
    
}
