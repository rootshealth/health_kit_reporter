//
//  ObserverQueryStreamHandler.swift
//  health_kit_reporter
//
//  Created by Victor Kachalov on 08.12.20.
//

import Foundation
import HealthKitReporter

public final class ObserverQueryStreamHandler: NSObject {
    public let reporter: HealthKitReporter
    public var activeQueries = Set<Query>()
    public var plannedQueries = Set<Query>()
    
    init(reporter: HealthKitReporter) {
        self.reporter = reporter
    }
}
// MARK: - StreamHandlerProtocol
extension ObserverQueryStreamHandler: StreamHandlerProtocol {
    public func setQueries(arguments: [String: Any], events: @escaping FlutterEventSink) throws {
        guard
            let identifiers = arguments["identifiers"] as? [String]
        else {
            return
        }
        var predicate: NSPredicate?
        if
            let startTimestamp = arguments["startTimestamp"] as? Double,
            let endTimestamp = arguments["endTimestamp"] as? Double {
            predicate = NSPredicate.samplesPredicate(
                startDate: Date.make(from: startTimestamp),
                endDate: Date.make(from: endTimestamp)
            )
        }
        for identifier in identifiers {
            guard let type = identifier.objectType as? SampleType else {
                return
            }
            let query = try reporter.observer.observerQuery(
                type: type,
                predicate: predicate
            ) { (query, identifier, error) in
                guard
                    error == nil,
                    let identifier = identifier
                else {
                    
                    DispatchQueue.main.async {
                        var errorDetails: [String: Any] = ["localizedDescription": error?.localizedDescription ?? "No description available"]
                        
                        var errorCode : String = "ERROR"
                        
                        // If the error is an NSError, add more details.
                        if let nsError = error as NSError? {
                            errorDetails["domain"] = nsError.domain
                            errorDetails["code"] = nsError.code
                            
                            // Add user info dictionary, if you need to pass any specific details.
                            errorDetails["userInfo"] = nsError.userInfo
                            
                            // Check for a specific error code and domain.
                            if nsError.domain == "com.apple.healthkit" && nsError.code == 5 {
                                errorCode = "errorAuthorizationNotDetermined"
                            }
                            
                        }
                        
                        
                        
                        events(FlutterError(code: errorCode, message: "Error or no identifier in observer query", details: errorDetails))
                    }
                    return
                }
                DispatchQueue.main.async {
                    events(["identifier": identifier])
                }
            }
            plannedQueries.insert(query)
        }
    }
    
    public static func make(with reporter: HealthKitReporter) -> ObserverQueryStreamHandler {
        ObserverQueryStreamHandler(reporter: reporter)
    }
}
// MARK: - FlutterStreamHandler
extension ObserverQueryStreamHandler: FlutterStreamHandler {
    public func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        handleOnListen(withArguments: arguments, eventSink: events)
    }
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        handleOnCancel(withArguments: arguments)
    }
}
