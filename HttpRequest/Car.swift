//
//  Car.swift
//  HttpRequest
//
//  Created by administrator on 4/7/22.
//

import Foundation

class Car : Codable {
    var _id: String
    var brand: String
    var gasType: Int
    var name: String
    var price: Double
    
    var gasName: String {
        switch gasType {
            case 0:
                return "Alcool"
            case 1:
                return "Flex"
        default:
                return "Gasolina"
        }
    }
}
