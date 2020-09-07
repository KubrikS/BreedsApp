//
//  FetchError.swift
//  DogBreeds
//
//  Created by Stanislav on 22.08.2020.
//  Copyright © 2020 St. Kubrik. All rights reserved.
//

import Foundation

enum FetchError: Error {
    case noHTTPResponse
    case noDataReceived
    case unacceptableStatusCode
}
