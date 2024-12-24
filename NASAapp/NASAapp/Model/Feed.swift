//
//  Drink.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//


import Foundation

struct Links: Decodable {
    let next: String?
    let previous: String?
    let self1: String?
}

protocol DTO: Decodable {
    
}

protocol Describable {
    var shortDesc: String { get }
}

protocol EmptableDTO {
    associatedtype T
    static var empty: T { get }
}

protocol LinkableDTO {
    var links: Links? { get }
}

struct Feed: PropertyLoopable, LinkableDTO, DTO {
    let links: Links?
    let element_count: Int?
    let near_earth_objects: [String: [NearEarthObject]]?
}

struct NearEarthObject: PropertyLoopable, LinkableDTO, DTO {
    let links: Links?
    
    struct Diameter: Decodable {
        let estimated_diameter_min: Double?
        let estimated_diameter_max: Double?
        var avg: Double? {
            guard let min = estimated_diameter_min,
                  let max = estimated_diameter_min else {
                return nil
            }
            
            return (min+max)/2
        }
    }
    
    struct CloseApproachData: Decodable {
        struct RelativeVelocity: Decodable {
            let kilometers_per_second: String?
            let kilometers_per_hour: String?
            let miles_per_hour: String?
        }
        struct MissDistance: Decodable {
            let astronomical: String?
            let lunar: String?
            let kilometers: String?
            let miles: String?
        }
        
        let close_approach_date: String
        let close_approach_date_full: String
        let epoch_date_close_approach: Double
        let relative_velocity: RelativeVelocity?
        let miss_distance: MissDistance?
        let orbiting_body: String?
    }
    
    let id: String?
    let neo_reference_id: String?
    let name: String?
    let nasa_jpl_url: String?
    let absolute_magnitude_h: Double?

    let kilometers: Diameter?
    let meters: Diameter?
    let miles: Diameter?
    let feet: Diameter?
    let is_potentially_hazardous_asteroid: Bool?
    let is_sentry_object: Bool?
    let close_approach_data: [CloseApproachData]?
}

extension NearEarthObject: Describable {
    var shortDesc: String {
        return String(localized: "diameter-km-\(String(format: "%.1f", kilometers?.avg ?? "-"))")
    }
}

extension Feed: EmptableDTO {
    static let empty: Feed = {
        return Feed(links: nil,
                    element_count: nil,
                    near_earth_objects: nil)
    }()
}

extension NearEarthObject: EmptableDTO {
    static let empty: NearEarthObject = {
        return NearEarthObject(links: Links(next: nil,
                                            previous: nil,
                                            self1: nil),
                               id: nil,
                               neo_reference_id: nil,
                               name: nil,
                               nasa_jpl_url: nil,
                               absolute_magnitude_h: nil,
                               kilometers: nil,
                               meters: nil,
                               miles: nil,
                               feet: nil,
                               is_potentially_hazardous_asteroid: nil,
                               is_sentry_object: nil,
                               close_approach_data: nil)
    }()
}
