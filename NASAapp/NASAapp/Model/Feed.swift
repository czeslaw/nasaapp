//
//  Drink.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import Foundation

struct Links: DTO {
    let next: String?
    let previous: String?
    let self1: String?
    
    enum CodingKeys: String, CodingKey {
        case next, previous
        case self1 = "self"
    }
}

protocol DTO: Decodable, Codable {
    
}

protocol Describable {
    var shortDesc: String { get }
}

protocol EmptableDTO {
    associatedtype TYPE
    static var empty: TYPE { get }
}

protocol LinkableDTO {
    var links: Links? { get }
}

struct Feed: PropertyLoopable, LinkableDTO, DTO {
    let links: Links?
    let elementCount: Int?
    let nearEarthObjects: [String: [NearEarthObject]]?
    
    enum CodingKeys: String, CodingKey {
        case links
        case elementCount = "element_count"
        case nearEarthObjects = "near_earth_objects"
    }
}

struct Diameter: DTO {
    let min: Double?
    let max: Double?
    
    enum CodingKeys: String, CodingKey {
        case min = "estimated_diameter_min"
        case max = "estimated_diameter_max"
    }
}

struct RelativeVelocity: DTO {
    let kilometersPerSecond: String?
    let kilometersPerHour: String?
    let milesPerHour: String?
    
    enum CodingKeys: String, CodingKey {
        case kilometersPerSecond = "kilometers_per_second"
        case kilometersPerHour = "kilometers_per_hour"
        case milesPerHour = "miles_per_hour"
    }
}

struct MissDistance: DTO {
    let astronomical: String?
    let lunar: String?
    let kilometers: String?
    let miles: String?
    
    enum CodingKeys: String, CodingKey {
        case astronomical, lunar, kilometers, miles
    }
}

struct CloseApproachData: DTO {
    let closeApproachDate: String
    let closeApproachDateFull: String
    let epochDateCloseApproach: Double
    let relativeVelocity: RelativeVelocity?
    let missDistance: MissDistance?
    let orbitingBody: String?
    
    enum CodingKeys: String, CodingKey {
        case closeApproachDate = "close_approach_date"
        case closeApproachDateFull = "close_approach_date_full"
        case epochDateCloseApproach = "epoch_date_close_approach"
        case relativeVelocity = "relative_velocity"
        case missDistance = "miss_distance"
        case orbitingBody = "orbiting_body"
    }
}

struct EstimatedDiameter: DTO {
    let kilometers: Diameter?
    let meters: Diameter?
    let miles: Diameter?
    let feet: Diameter?
    
    enum CodingKeys: String, CodingKey {
        case kilometers, meters, miles, feet
    }
}

struct NearEarthObject: PropertyLoopable, LinkableDTO, DTO {
    let links: Links?
    let id: String?
    let name: String?
    let neoReferenceId: String?
    let nasaJplUrl: String?
    let absoluteMagnitudeH: Double?
    let estimatedDiameter: EstimatedDiameter?
    let isPotentiallyHazardousAsteroid: Bool?
    let isSentryObject: Bool?
    let closeApproachData: [CloseApproachData]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, links
        case neoReferenceId = "neo_reference_id"
        case nasaJplUrl = "nasa_jpl_url"
        case absoluteMagnitudeH = "absolute_magnitude_h"
        case estimatedDiameter = "estimated_diameter"
        case isPotentiallyHazardousAsteroid = "is_potentially_hazardous_asteroid"
        case isSentryObject = "is_sentry_object"
        case closeApproachData = "close_approach_data"
    }
}

extension NearEarthObject: Describable {
    var shortDesc: String {
        let min = String(format: "%.1f", estimatedDiameter?.meters?.min ?? 0)
        let max = String(format: "%.1f", estimatedDiameter?.meters?.max ?? 0)

        return String(localized: "diameter-m-\(String(format: "%@-%@", min, max))")
    }
}

extension Feed: EmptableDTO {
    static let empty: Feed = {
        return Feed(links: nil,
                    elementCount: nil,
                    nearEarthObjects: nil)
    }()
}

extension NearEarthObject: EmptableDTO {
    static let empty: NearEarthObject = {
        return NearEarthObject(links: Links(next: nil,
                                            previous: nil,
                                            self1: nil),
                               id: "123",
                               name: "empty name",
                               neoReferenceId: nil,
                               nasaJplUrl: "https://nasa.gov",
                               absoluteMagnitudeH: nil,
                               estimatedDiameter: nil,
                               isPotentiallyHazardousAsteroid: nil,
                               isSentryObject: nil,
                               closeApproachData: nil)
    }()
}
