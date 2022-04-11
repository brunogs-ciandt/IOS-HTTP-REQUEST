//
//  HttpRequest.swift
//  HttpRequest
//
//  Created by administrator on 4/7/22.
//

import Foundation
import Alamofire

protocol HttpRequestResponse {
    func httpResponse(response: [Codable]?)
}

class HttpRequest {
    var delegate: HttpRequestResponse?
    
    private static let baseUrl = "https://carangas.herokuapp.com/cars"
    private static let httpConfiguration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = false
        config.httpAdditionalHeaders = ["Content-Type:": "application/json"]
        config.timeoutIntervalForRequest = 30.0 // seconds
        config.httpMaximumConnectionsPerHost = 5
        return config
    }()
    
    private static let session = URLSession(configuration: httpConfiguration)
    
    private class func getData<T:Codable>(url: String) -> [T]? {
        guard let url = URL(string: baseUrl) else { return nil }
        
        var returnData: [T]? = nil
        var awaitHttp = true
        
        print("TRACE - main thread \(Thread.current.isMainThread) - Iniciando Http Request \(Date.now)")
        
        session.dataTask(with: url) { data, response, error in
            
            print("TRACE - main thread \(Thread.current.isMainThread) - Finalizado Http Request \(Date.now)")
            
            if let error = error {
                print("Http Error" + error.localizedDescription)
            } else if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
                if let data = data {
                    returnData = try? JSONDecoder().decode([T].self, from: data)
                }
            } else {
                print("Http Error Generic")
            }
            awaitHttp = false
        }.resume()
        
        print("TRACE - main thread \(Thread.current.isMainThread) - Aguardando finalizar Http Request \(Date.now)")
        while awaitHttp {
            print("Aguardando Http Request")
        }
        
        print("TRACE - main thread \(Thread.current.isMainThread) - Finalizado Http Request \(Date.now)")
        return returnData
    }

    private class func getDataAlamofire(url: String, onComplete: @escaping ([Car]?) -> Void) {
        print("TRACE - main thread \(Thread.current.isMainThread) - Iniciando Alamofire Http Request \(Date.now)")
        
        AF.request(baseUrl).response { response in
            print("TRACE - main thread \(Thread.current.isMainThread) - Alamofire Finalizado Http Request \(Date.now)")
            
            if let response = response.data {
                do {
                    let data = try JSONDecoder().decode([Car].self, from: response)
                    onComplete(data)
                } catch {
                    print(error.localizedDescription)
                }
                
            } else {
                print("TRACE - main thread \(Thread.current.isMainThread) - Alamofire Error Http Request \(Date.now)")
                onComplete(nil)
            }
        }
    }
    
    func loadCars() {
        let task = DispatchWorkItem{
            let cars: [Car]? = HttpRequest.getData(url: " ")
            if let delegate = self.delegate {
                print("TRACE - main thread \(Thread.current.isMainThread) - Enviando Http Response \(Date.now)")
                delegate.httpResponse(response: cars)
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 10, execute: task)
    }
    
    func loadCarsWithAlamofire() {
        let task = DispatchWorkItem{
            HttpRequest.getDataAlamofire(url: "") { response in
                self.delegate?.httpResponse(response: response)
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 10, execute: task)
    }
}
