//
//  TremendousAPI.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/24/23.
//

import Foundation

class TremendousAPI {
    enum Endpoints {
        static let apiKey = ""
        static let baseURL = "https://testflight.tremendous.com/api/v2/products"
        case vendorList(searchTerm: String)
        case getDenominations(vendor: String)
        
        
        var URLString: String{
            switch self {
            case .vendorList(let searchTerm):
                return Endpoints.baseURL + ""
            case . getDenominations(let vendor):
                return Endpoints.baseURL + ""
            }
        }
        
        var url: URL{ return URL(string: URLString)!}
        
    }
    
    class func browseProducts(searchTerm: String, completionHandler: @escaping (TremendousProducts?,Error?) -> Void) {
        let url = Endpoints.vendorList(searchTerm: searchTerm).url
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {completionHandler(nil, error)}
                return
            }
            do {
                let collections = try JSONDecoder().decode(TremendousProducts.self, from: data!)
                DispatchQueue.main.async {completionHandler(collections, nil)}
                }
            catch {
                    print("Invalid Response")
                    print("Request failed: \(error)")
                    DispatchQueue.main.async {completionHandler(nil, error)}
                }
            }
        )
        task.resume()
    }
    

    
}




