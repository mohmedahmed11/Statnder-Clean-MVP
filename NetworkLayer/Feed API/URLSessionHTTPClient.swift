//
//  URLSessionHTTPClient.swift
//  NetworkLayer
//
//  Created by Mohamed Ahmed on 3/22/23.
//

import Foundation

public class URLSessionHTTPClient: HTTPClinet {
    private let session: URLSession
    
    private struct UnexpectedValuesRepresentation: Error {}

    public init(session: URLSession = .shared) {
         self.session = session
     }

    public func get(from url: URL, compeletion: @escaping  (HTTPClientResult) -> Void) {
         session.dataTask(with: url) { data, response, error in
             if let error = error {
                 compeletion(.failuer(error))
             }else if let data = data, let response = response as? HTTPURLResponse {
                 compeletion(.success(response, data))
             } else {
                 compeletion(.failuer(UnexpectedValuesRepresentation()))
             }
         }.resume()
     }
 }
