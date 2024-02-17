//
//  ConfigurationView.swift
//  FabricDecoder
//
//  Created by Danika Gupta on 2/11/24.
//

import SwiftUI

struct ConfigurationView: View {
    @State private var isCameraEnabled = false
    @State private var useLocalModel = false
    @State private var currentStatus = "Inactive"
    @State private var currentModel  = "YOLOv8"
    @State private var counter = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Settings")) {
                    
                    Toggle(isOn: $useLocalModel) {
                        Text("Use Local Model")
                    }
                    .onChange(of: useLocalModel) { newValue in
                        currentModel = newValue ? "CreateML" : "YoloV8"
                        FabricInfo.useLocalModel = newValue
                    }
                    
                    Toggle(isOn: $isCameraEnabled) {
                        Text("Use Camera")
                    }
                    .onChange(of: isCameraEnabled) { newValue in
                        currentStatus = newValue ? "Active" : "Inactive"
                        FabricInfo.cameraSource = newValue
                    }
                }
                
                Section(header: Text("Status")) {
                    Text("Feature is \(currentStatus)")
                    Text("Model is : \(currentModel)")
                    if FabricInfo.cameraSource {
                        Text("FI camera source is true")
                    } else {
                        Text("FI camera source is false")
                    }
                    if FabricInfo.useLocalModel {
                        Text("FI use local is true")
                    } else {
                        Text("FI use local is false")
                    }

                }
                
                Section(header: Text("Logs")) {
                    Button("Refresh \(counter)") {
                        counter+=1;
                    }
                    Text(FabricInfo.LOGS)
                }
            }
            .navigationTitle("Configuration")
        }
    }
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView()
    }
}
