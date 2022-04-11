//
//  ViewController.swift
//  HttpRequest
//
//  Created by administrator on 4/7/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    let httpRequestManager = HttpRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        httpRequestManager.delegate = self
    }

    @IBAction func invokeHttp(_ sender: UIButton) {
        loading.startAnimating()
        
        lblStatus.text = "Enviando Http"
        print("TRACE - main thread \(Thread.current.isMainThread) - Disparando http request \(Date.now)")
        httpRequestManager.loadCars()
        print("TRACE - main thread \(Thread.current.isMainThread) - Evento Button click finished \(Date.now)")
        lblStatus.text = "Http Enviado"
    }
    
    
    @IBAction func invokeHttpAlamofire(_ sender: Any) {
        loading.startAnimating()
        
        lblStatus.text = "Enviando Http Alamofire"
        print("TRACE - main thread \(Thread.current.isMainThread) - Disparando http request Alamofire \(Date.now)")
        httpRequestManager.loadCarsWithAlamofire()
        print("TRACE - main thread \(Thread.current.isMainThread) - Evento Alamofire Button click finished \(Date.now)")
        lblStatus.text = "Http Enviado"
    }
}

extension ViewController : HttpRequestResponse {
    func httpResponse(response: [Codable]?) {
        print("TRACE - main thread \(Thread.current.isMainThread) - Http response API \(Date.now)")
        guard let response = response else {
            DispatchQueue.main.async {
                self.loading.stopAnimating()
                self.lblStatus.text = "Request Finalizada - 0 Itens Carregados"
            }
            
            print("Null Http Response")
            return
        }
        
        print("TRACE - main thread \(Thread.current.isMainThread) - Http response API result \(Date.now) - \(response)")
        
        DispatchQueue.main.async {
            self.loading.stopAnimating()
            self.lblStatus.text = "Request Finalizada - \(response.count) Itens Carregados"
        }
    }
}

