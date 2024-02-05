import Flutter
import HealthKitReporter

public class SwiftHealthKitReporterPlugin: NSObject, FlutterPlugin {
    
    var reporter: HealthKitReporter?
    
    static var instance: SwiftHealthKitReporterPlugin?
    
    override init() {
        super.init()
        self.reporter = HealthKitReporter()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftHealthKitReporterPlugin() // Create the instance
        self.instance = instance // Assign to static property
        
        let binaryMessenger = registrar.messenger()
        registerMethodChannel(
            registrar: registrar,
            binaryMessenger: binaryMessenger,
            instance: instance
        )
        
        do {
            if let reporter = instance.reporter {
                try registerEventChannel(
                    binaryMessenger: binaryMessenger,
                    reporter: reporter
                )
            }
        } catch {
            print(error)
        }
    }
    private static func registerMethodChannel(
        registrar: FlutterPluginRegistrar,
        binaryMessenger: FlutterBinaryMessenger,
        instance: SwiftHealthKitReporterPlugin
    ) {
        for method in MethodChannel.allCases {
            let methodChannel = FlutterMethodChannel(
                name: method.rawValue,
                binaryMessenger: binaryMessenger
            )
            registrar.addMethodCallDelegate(instance, channel: methodChannel)
        }
    }
    private static func registerEventChannel(
        binaryMessenger: FlutterBinaryMessenger,
        reporter: HealthKitReporter
    ) throws {
        for event in EventChannel.allCases {
            let eventChannel = FlutterEventChannel(
                name: event.rawValue,
                binaryMessenger: binaryMessenger
            )
            let streamHandler = try StreamHandlerFactory.make(with: reporter, for: event)
            eventChannel.setStreamHandler(streamHandler)
        }
    }
    
    @objc public static func detachFromEngineForRegistrar(_ registrar: FlutterPluginRegistrar) {
        instance?.reporter?.observer.disableAllBackgroundDelivery { success, error in
            if let error = error {
                // Handle the error
                print("Error disabling background delivery: \(error.localizedDescription)")
            } else {
                // Success
                print("Successfully disabled all background delivery.")
            }
            instance?.reporter = nil
            
        }
    }
}
