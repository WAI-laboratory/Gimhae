// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum GimhaeStrings {

  public enum Common {
  /// Something went wrong
    public static let error = GimhaeStrings.tr("Localizable", "common.error")
    /// Loading...
    public static let loading = GimhaeStrings.tr("Localizable", "common.loading")
    /// No results
    public static let noResults = GimhaeStrings.tr("Localizable", "common.noResults")
    /// Offline Mode · Showing saved data
    public static let offline = GimhaeStrings.tr("Localizable", "common.offline")
    /// Retry
    public static let retry = GimhaeStrings.tr("Localizable", "common.retry")
    /// Settings
    public static let settings = GimhaeStrings.tr("Localizable", "common.settings")
  }

  public enum Detail {
  /// Address
    public static let address = GimhaeStrings.tr("Localizable", "detail.address")
    /// Fee
    public static let fee = GimhaeStrings.tr("Localizable", "detail.fee")
    /// Get Directions
    public static let getDirections = GimhaeStrings.tr("Localizable", "detail.getDirections")
    /// Hours
    public static let hours = GimhaeStrings.tr("Localizable", "detail.hours")
    /// Nearby Places
    public static let nearby = GimhaeStrings.tr("Localizable", "detail.nearby")
    /// Parking
    public static let parking = GimhaeStrings.tr("Localizable", "detail.parking")
    /// Phone
    public static let phone = GimhaeStrings.tr("Localizable", "detail.phone")
    /// Save
    public static let save = GimhaeStrings.tr("Localizable", "detail.save")
    /// Saved
    public static let saved = GimhaeStrings.tr("Localizable", "detail.saved")
    /// View on Map
    public static let viewOnMap = GimhaeStrings.tr("Localizable", "detail.viewOnMap")
  }

  public enum Explore {
  /// Stays
    public static let accommodation = GimhaeStrings.tr("Localizable", "explore.accommodation")
    /// Attractions
    public static let attraction = GimhaeStrings.tr("Localizable", "explore.attraction")
    /// Bikes
    public static let bicycle = GimhaeStrings.tr("Localizable", "explore.bicycle")
    /// Festivals
    public static let festival = GimhaeStrings.tr("Localizable", "explore.festival")
    /// Heritage
    public static let heritage = GimhaeStrings.tr("Localizable", "explore.heritage")
    /// Parking
    public static let parking = GimhaeStrings.tr("Localizable", "explore.parking")
    /// Restaurants
    public static let restaurant = GimhaeStrings.tr("Localizable", "explore.restaurant")
    /// Explore
    public static let title = GimhaeStrings.tr("Localizable", "explore.title")
    /// WiFi
    public static let wifi = GimhaeStrings.tr("Localizable", "explore.wifi")
  }

  public enum Home {
  /// Gimhae at a Glance
    public static let atAGlance = GimhaeStrings.tr("Localizable", "home.atAGlance")
    /// Happening Now in Gimhae
    public static let happeningNow = GimhaeStrings.tr("Localizable", "home.happeningNow")
    /// Recommended Spots
    public static let recommended = GimhaeStrings.tr("Localizable", "home.recommended")
    /// Today's Air
    public static let todayAir = GimhaeStrings.tr("Localizable", "home.todayAir")
  }

  public enum Map {
  /// Near Me
    public static let nearMe = GimhaeStrings.tr("Localizable", "map.nearMe")
    /// Search places
    public static let search = GimhaeStrings.tr("Localizable", "map.search")
    /// Map
    public static let title = GimhaeStrings.tr("Localizable", "map.title")
  }

  public enum MyTrip {
  /// %d categories explored
    public static func categoriesExplored(_ p1: Int) -> String {
      return GimhaeStrings.tr("Localizable", "myTrip.categoriesExplored",p1)
    }
    /// Trip Checklist
    public static let checklist = GimhaeStrings.tr("Localizable", "myTrip.checklist")
    /// Clear All
    public static let clearAll = GimhaeStrings.tr("Localizable", "myTrip.clearAll")
    /// Offline Cache
    public static let offlineCache = GimhaeStrings.tr("Localizable", "myTrip.offlineCache")
    /// %d places visited
    public static func placesVisited(_ p1: Int) -> String {
      return GimhaeStrings.tr("Localizable", "myTrip.placesVisited",p1)
    }
    /// Saved Places
    public static let savedPlaces = GimhaeStrings.tr("Localizable", "myTrip.savedPlaces")
    /// My Trip
    public static let title = GimhaeStrings.tr("Localizable", "myTrip.title")
    /// Visit History
    public static let visitStats = GimhaeStrings.tr("Localizable", "myTrip.visitStats")
  }

  public enum Settings {
  /// Clear Cache
    public static let clearCache = GimhaeStrings.tr("Localizable", "settings.clearCache")
    /// Request a Feature
    public static let feedback = GimhaeStrings.tr("Localizable", "settings.feedback")
    /// Language
    public static let language = GimhaeStrings.tr("Localizable", "settings.language")
    /// Settings
    public static let title = GimhaeStrings.tr("Localizable", "settings.title")
    /// Version
    public static let version = GimhaeStrings.tr("Localizable", "settings.version")
  }

  public enum Tab {
  /// Explore
    public static let explore = GimhaeStrings.tr("Localizable", "tab.explore")
    /// Home
    public static let home = GimhaeStrings.tr("Localizable", "tab.home")
    /// Map
    public static let map = GimhaeStrings.tr("Localizable", "tab.map")
    /// My Trip
    public static let myTrip = GimhaeStrings.tr("Localizable", "tab.myTrip")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension GimhaeStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = GimhaeResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
