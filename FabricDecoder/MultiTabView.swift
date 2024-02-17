//
//  MultiTabView.swift
//  FabricDecoder
//
//  Created by Danika Gupta on 2/11/24.
//

import SwiftUI

struct MultiTabView: View {
    
    var body: some View {
        
        ZStack {
            Color.blue.opacity(0.2).ignoresSafeArea()
            TabView{
                ObjectDetectionView()
                    .tabItem{
                        Label("ID Fabric",systemImage: "eye.circle.fill")
                    }
                /*
                WebView(url:URL(string:"https://sites.google.com/view/myfirstaiontheweb/home")!)
                    .tabItem{
                        Label("Information",systemImage: "info")
                    }
                 */
                ConfigurationView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}

struct Tab1View: View {
    var body: some View {
        Text("Page 1")
    }
}

struct Tab2View: View {
    var body: some View {
        Text("Page 2")
    }
}

struct Tab3View: View {
    @AppStorage("lat") var lat=0.0
    @AppStorage("lon") var lon=0.0
    var body: some View {
        ZStack {
            Color.blue.opacity(0.20).ignoresSafeArea()
            WebView(url:URL(string:"https://forecast.weather.gov/MapClick.php?textField1=\(lat)&textField2=\(lon)")!)
        }
    }
}

struct MultiTabView_Previews: PreviewProvider {
    static var previews: some View {
        MultiTabView()
    }
}


