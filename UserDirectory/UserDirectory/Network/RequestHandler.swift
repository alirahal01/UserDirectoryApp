//
//  RequestHandler.swift
//  UserDirectory
//
//  Created by ali rahal on 10/08/2023.
//

import Foundation

final class RequestHandler: RequestHandling {

    let urlSession: URLSession

    
    private var previousTask: URLSessionDataTask?

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func request<T: Decodable>(route: APIRoute, completion: @escaping (Result<T, DataLoadError>) -> Void) {

        if let previousTask = previousTask {
            previousTask.cancel()
        }

        let task = urlSession.dataTask(with: route.asRequest()) { (data, response, error) in

            // Ignore if this request was cancelled
            // This is to avoid firing multiple requests when user changes slider too fast
            if (error as NSError?)?.code == NSURLErrorCancelled {
               return
            }

            if let error = error {
                if (error as NSError?)?.code == -1009 {
                    completion(.failure(.offline))
                } else {
                    completion(.failure(.genericError(error.localizedDescription)))
                }
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            if let responseCode = (response as? HTTPURLResponse)?.statusCode, responseCode != 200 {
                completion(.failure(.invalidResponseCode(responseCode)))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let responsePayload = try decoder.decode(T.self, from: data)
                completion(.success(responsePayload))
            } catch {
                completion(.failure(.malformedContent))
            }
        }

        task.resume()

        self.previousTask = task
    }
}
