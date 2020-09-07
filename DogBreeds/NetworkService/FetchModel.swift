//
//  FetchModel.swift
//  DogBreeds
//
//  Created by Stanislav on 03.09.2020.
//  Copyright © 2020 St. Kubrik. All rights reserved.
//

import UIKit

protocol BreedSource {
    var urlRequest: URLRequest? { get }
}

struct BreedName: BreedSource {
    var url: URL {
        return URL(string: "https://dog.ceo/api/breeds/list/all")!
    }
    var urlRequest: URLRequest? {
        return URLRequest(url: url)
    }
}

struct BreedImage: BreedSource {
    var breed: String
    var url: URL {
        return URL(string: "https://dog.ceo/api/breed/\(breed)/images")!
    }
    var urlRequest: URLRequest? {
        return URLRequest(url: url)
    }
}

struct FetchBreed {
    let networkingService = NetworkingService()
    
    func fetchBreed(for source: BreedSource, completion: @escaping (Result<Breeds, Error>) -> Void) {
        let request = source
        networkingService.fetch(with: request.urlRequest!, completion: completion)
    }
    
    func fetchBreedImage(for source: BreedSource, completion: @escaping (Result<BreedsImage, Error>) -> Void) {
        let request = source
        networkingService.fetch(with: request.urlRequest!, completion: completion)
    }
}
