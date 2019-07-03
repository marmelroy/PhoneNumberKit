//
//  Metadata.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

final class MetadataManager {

    var territories = [MetadataTerritory]()
    var territoriesByCode = [UInt64: [MetadataTerritory]]()
    var mainTerritoryByCode = [UInt64: MetadataTerritory]()
    var territoriesByCountry = [String: MetadataTerritory]()

    // MARK: Lifecycle

    /// Private init populates metadata territories and the two hashed dictionaries for faster lookup.
    ///
    /// - Parameter metadataCallback: a closure that returns metadata as JSON Data.
    public init (metadataCallback: MetadataCallback) {
        territories = populateTerritories(metadataCallback: metadataCallback)
        for item in territories {
            var currentTerritories: [MetadataTerritory] = territoriesByCode[item.countryCode] ?? [MetadataTerritory]()
            currentTerritories.append(item)
            territoriesByCode[item.countryCode] = currentTerritories
            if mainTerritoryByCode[item.countryCode] == nil || item.mainCountryForCode == true {
                mainTerritoryByCode[item.countryCode] = item
            }
            territoriesByCountry[item.codeID] = item
        }
    }

    deinit {
        territories.removeAll()
        territoriesByCode.removeAll()
        territoriesByCountry.removeAll()
    }

    /// Populates the metadata from a metadataCallback.
    ///
    /// - Parameter metadataCallback: a closure that returns metadata as JSON Data.
    /// - Returns: array of MetadataTerritory objects
    fileprivate func populateTerritories(metadataCallback: MetadataCallback) -> [MetadataTerritory] {
        var territoryArray = [MetadataTerritory]()
        do {
            let jsonData: Data?  = try metadataCallback()
            let jsonDecoder = JSONDecoder()
            if let jsonData = jsonData, let metadata: PhoneNumberMetadata = try? jsonDecoder.decode(PhoneNumberMetadata.self, from: jsonData) {
                territoryArray = metadata.territories
            }
        } catch {}
        return territoryArray
    }

    // MARK: Filters

    /// Get an array of MetadataTerritory objects corresponding to a given country code.
    ///
    /// - parameter code:  international country code (e.g 44 for the UK).
    ///
    /// - returns: optional array of MetadataTerritory objects.
    internal func filterTerritories(byCode code: UInt64) -> [MetadataTerritory]? {
        return territoriesByCode[code]
    }

    /// Get the MetadataTerritory objects for an ISO 639 compliant region code.
    ///
    /// - parameter country: ISO 639 compliant region code (e.g "GB" for the UK).
    ///
    /// - returns: A MetadataTerritory object.
    internal func filterTerritories(byCountry country: String) -> MetadataTerritory? {
        return territoriesByCountry[country.uppercased()]
    }

    /// Get the main MetadataTerritory objects for a given country code.
    ///
    /// - parameter code: An international country code (e.g 1 for the US).
    ///
    /// - returns: A MetadataTerritory object.
    internal func mainTerritory(forCode code: UInt64) -> MetadataTerritory? {
        return mainTerritoryByCode[code]
    }

}
