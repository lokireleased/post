//
//  PostController.swift
//  Post
//
//  Created by tyson ericksen on 11/18/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

enum PostError: LocalizedError {
    case invalidURL
    case communicationError
    case noData
}


class PostController {
    
    var postArray: [Post] = []
    
    func fetchPosts(reset: Bool = true, completion: @escaping (Result<[Post], PostError>) -> Void) {
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : postArray.last?.timestamp ?? Date().timeIntervalSince1970
        
        guard let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts") else { return completion(.failure(.invalidURL)) }
        
        let urlParameters = ["orderBy" : "\"timestamp\"", "endAt" : "\(queryEndInterval)", "limitToLast" : "15"]
        
        let queryItems = urlParameters.compactMap({ URLQueryItem(name: $0.key, value: $0.value) })
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else { return }
        
        let getterEndPoint = url.appendingPathExtension("json")
        
        print(getterEndPoint)
        
        var request = URLRequest(url: getterEndPoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print(error)
                return completion(.failure(.communicationError))
        }
            
            guard let data = data else { return completion(.failure(.noData))}
            
            do {
                let decoder = JSONDecoder()
                let post = try decoder.decode([String: Post].self, from: data)
                var posts = post.compactMap({$0.value})
//                posts.sort(by: { $0.timestamp > $1.timestamp })
                self.postArray = posts
                return completion(.success(posts))
            } catch {
                print(error)
            }
        } .resume()
    }
    
    func addNewPostWith(username: String, text: String, completion: @escaping (Result<Post, PostError>) -> Void) {
        
        //create a new post
        let newPost = Post(text: text, username: username)
        postArray.append(newPost)
        
        var postData = Data()
        
        //encodes the information
        do {
            let jsEncoder = JSONEncoder()
            let post = try jsEncoder.encode(newPost)
            postData = post
        } catch {
            print(error)
        }
        //creates the URL
        guard let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts") else { return completion(.failure(.invalidURL))}
        let postEndPoint = baseURL.appendingPathExtension("json")
        //create the request to the URL
        var request = URLRequest(url: postEndPoint)
        request.httpMethod = "POST"
        request.httpBody = postData
        //connects to the internet
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print(error)
                completion(.failure(.communicationError))
            }
            guard let data = data else { return }
            let dataAsString = String(data: postData, encoding: .utf8)
            print(dataAsString)
            
            do {
                let jsDecoder = JSONDecoder()
                let post = try jsDecoder.decode(Post.self, from: data)
                completion(.success(post))
            } catch {
                print(error, error.localizedDescription)
                return completion(.failure(.communicationError))
            }
        } .resume()
    }
}
