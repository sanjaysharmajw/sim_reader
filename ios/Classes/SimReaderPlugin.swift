import Flutter
import UIKit
import CoreTelephony

public class SimReaderPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "sim_reader", binaryMessenger: registrar.messenger())
    let instance = SimReaderPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getSimInfo":
      getSimInfo(result: result)
    case "getAllSimInfo":
      getAllSimInfo(result: result)
    case "hasSimCard":
      hasSimCard(result: result)
    case "getNetworkInfo":
      getNetworkInfo(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getSimInfo(result: @escaping FlutterResult) {
    let telephonyInfo = CTTelephonyNetworkInfo()

    if #available(iOS 12.0, *) {
      // Get the first available carrier
      if let carriers = telephonyInfo.serviceSubscriberCellularProviders,
         let firstCarrier = carriers.values.first {
        let simInfo = createSimInfoMap(from: firstCarrier, slotIndex: 0)
        result(simInfo)
        return
      }
    } else {
      // Fallback for older iOS versions
      if let carrier = telephonyInfo.subscriberCellularProvider {
        let simInfo = createSimInfoMap(from: carrier, slotIndex: 0)
        result(simInfo)
        return
      }
    }

    result(nil)
  }

  private func getAllSimInfo(result: @escaping FlutterResult) {
    let telephonyInfo = CTTelephonyNetworkInfo()
    var simInfoList: [[String: Any?]] = []

    if #available(iOS 12.0, *) {
      if let carriers = telephonyInfo.serviceSubscriberCellularProviders {
        var slotIndex = 0
        for (_, carrier) in carriers {
          let simInfo = createSimInfoMap(from: carrier, slotIndex: slotIndex)
          simInfoList.append(simInfo)
          slotIndex += 1
        }
      }
    } else {
      // Fallback for older iOS versions
      if let carrier = telephonyInfo.subscriberCellularProvider {
        let simInfo = createSimInfoMap(from: carrier, slotIndex: 0)
        simInfoList.append(simInfo)
      }
    }

    result(simInfoList)
  }

  private func hasSimCard(result: @escaping FlutterResult) {
    let telephonyInfo = CTTelephonyNetworkInfo()

    if #available(iOS 12.0, *) {
      let hasSimCard = telephonyInfo.serviceSubscriberCellularProviders?.isEmpty == false
      result(hasSimCard)
    } else {
      let hasSimCard = telephonyInfo.subscriberCellularProvider != nil
      result(hasSimCard)
    }
  }

  private func getNetworkInfo(result: @escaping FlutterResult) {
    let telephonyInfo = CTTelephonyNetworkInfo()

    var networkOperatorName: String?
    var networkOperator: String?
    var networkType: String?
    var isNetworkAvailable = false

    if #available(iOS 12.0, *) {
      if let carriers = telephonyInfo.serviceSubscriberCellularProviders,
         let firstCarrier = carriers.values.first {
        networkOperatorName = firstCarrier.carrierName
        networkOperator = "\(firstCarrier.mobileCountryCode ?? "")\(firstCarrier.mobileNetworkCode ?? "")"
        isNetworkAvailable = firstCarrier.carrierName != nil
      }

      if let radioTypes = telephonyInfo.serviceCurrentRadioAccessTechnology,
         let firstRadioType = radioTypes.values.first {
        networkType = getNetworkTypeName(from: firstRadioType)
      }
    } else {
      if let carrier = telephonyInfo.subscriberCellularProvider {
        networkOperatorName = carrier.carrierName
        networkOperator = "\(carrier.mobileCountryCode ?? "")\(carrier.mobileNetworkCode ?? "")"
        isNetworkAvailable = carrier.carrierName != nil
      }

      if let radioType = telephonyInfo.currentRadioAccessTechnology {
        networkType = getNetworkTypeName(from: radioType)
      }
    }

    let networkInfo: [String: Any?] = [
      "networkOperatorName": networkOperatorName,
      "networkOperator": networkOperator,
      "networkType": networkType,
      "isNetworkAvailable": isNetworkAvailable,
      "signalStrength": nil // Not available on iOS without private APIs
    ]

    result(networkInfo)
  }

  private func createSimInfoMap(from carrier: CTCarrier, slotIndex: Int) -> [String: Any?] {
    return [
      "carrierName": carrier.carrierName,
      "countryCode": carrier.isoCountryCode,
      "mobileCountryCode": carrier.mobileCountryCode,
      "mobileNetworkCode": carrier.mobileNetworkCode,
      "phoneNumber": nil, // Not available on iOS without private APIs
      "simSerialNumber": nil, // Not available on iOS without private APIs
      "subscriberId": nil, // Not available on iOS without private APIs
      "simSlotIndex": slotIndex,
      "isNetworkRoaming": false // Would require additional setup
    ]
  }

  private func getNetworkTypeName(from radioAccessTechnology: String) -> String {
    switch radioAccessTechnology {
    case CTRadioAccessTechnologyGPRS:
      return "GPRS"
    case CTRadioAccessTechnologyEdge:
      return "EDGE"
    case CTRadioAccessTechnologyWCDMA:
      return "WCDMA"
    case CTRadioAccessTechnologyHSDPA:
      return "HSDPA"
    case CTRadioAccessTechnologyHSUPA:
      return "HSUPA"
    case CTRadioAccessTechnologyCDMA1x:
      return "CDMA1x"
    case CTRadioAccessTechnologyCDMAEVDORev0:
      return "CDMAEVDORev0"
    case CTRadioAccessTechnologyCDMAEVDORevA:
      return "CDMAEVDORevA"
    case CTRadioAccessTechnologyCDMAEVDORevB:
      return "CDMAEVDORevB"
    case CTRadioAccessTechnologyeHRPD:
      return "eHRPD"
    case CTRadioAccessTechnologyLTE:
      return "LTE"
    default:
      if #available(iOS 14.1, *) {
        if radioAccessTechnology == CTRadioAccessTechnologyNRNSA ||
               radioAccessTechnology == CTRadioAccessTechnologyNR {
          return "5G"
        }
      }
      return "UNKNOWN"
    }
  }
}