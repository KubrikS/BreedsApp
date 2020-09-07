//
//  CodableModel.swift
//  DogBreeds
//
//  Created by Stanislav on 03.09.2020.
//  Copyright © 2020 St. Kubrik. All rights reserved.
//

import UIKit

struct Breeds: Codable {
    let message: [String: [String]]
    let status: String
}

struct BreedsImage: Codable {
    let message: [String]
    let status: String
}
