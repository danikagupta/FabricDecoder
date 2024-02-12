//
//  ConfigurationView.swift
//  FabricDecoder
//
//  Created by Danika Gupta on 2/11/24.
//

import SwiftUI

struct ConfigurationView: View {
    @State private var isCameraEnabled = false
    @State private var currentStatus = "Inactive"
    @State private var counter = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Settings")) {
                    /*
                    HStack {
                        Text("Option A")
                            .foregroundColor(isOptionASelected ? .blue : .secondary)
                        Spacer()
                        Toggle("", isOn: $isOptionASelected)
                            .labelsHidden() // Hide default labels
                            .onChange(of: isOptionASelected) { newValue in
                                // Handle the change if needed
                            }
                        Spacer()
                        Text("Option B")
                            .foregroundColor(isOptionASelected ? .secondary : .blue)
                    }
                    .padding()
                    
                    // Use the toggle state to modify other views or display additional information
                    Text("Selected: \(isOptionASelected ? "Option A" : "Option B")")
                    */
                    
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
                    Text("Counter: \(counter)")
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
