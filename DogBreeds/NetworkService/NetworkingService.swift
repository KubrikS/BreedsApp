//
//  NetworkingService.swift
//  DogBreeds
//
//  Created by Stanislav on 22.08.2020.
//  Copyright © 2020 St. Kubrik. All rights reserved.



import UIKit

class NetworkingService {
    
    public func fetch<T: Decodable>(with request: URLRequest,
                                    decoder: JSONDecoder = JSONDecoder(),
                                    completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(FetchError.noHTTPResponse))
                return
            }
            guard response.statusCode == 200 else {
                completion(.failure(FetchError.unacceptableStatusCode))
                return
            }
            
            guard let data = data else {
                completion(.failure(FetchError.noDataReceived))
                return
            }
            
            do {
                let object = try decoder.decode(T.self, from: data)
                completion(.success(object))
            } catch {
                completion(.failure(error as Error))
            }
        }.resume()
    }
}
