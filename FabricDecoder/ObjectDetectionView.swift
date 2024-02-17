//
//  ObjectDetectionView.swift
//  FabricDecoder
//
//  Created by Danika Gupta on 2/11/24.
//


import SwiftUI
import CoreML
import Vision
import UIKit
import Roboflow

struct ObjectDetectionView: View {
    @State private var resultText=""
    @State private var resultDesc=""
    @State private var showingImagePicker=false
    @State private var inputImage: UIImage? = UIImage(named:"fabric")
    
    @State var detectedObjects: [String] = []
    @State var items: [LabelCoordinates] = []
    
    
    var body: some View {
        HStack {
            VStack (alignment: .center,
                    spacing: 20){
                Text("Fabric Identifier")
                    .font(.system(size:42))
                    .fontWeight(.bold)
                    .padding(10)
                Text(resultText)
                Image(uiImage: inputImage!).resizable()
                    .aspectRatio(contentMode: .fit)
                Button("Identify fabric"){
                    self.buttonPressed()
                }
                .padding(.all, 14.0)
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(10)
                Text(resultDesc)
                //Text(DataStore.label)
            }
                    .font(.title)
        }.sheet(isPresented: $showingImagePicker, onDismiss: detectObjects) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    func buttonPressed() {
        print("Button pressed")
        self.showingImagePicker = true
    }
    
    func detectObjects() {
        resultText=""
        resultDesc=""
        if FabricInfo.useLocalModel {
            detectObjectsLocal()
        } else {
            detectObjectsRemote()
        }
    }
    
    func parseAndTransform(jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        
        let decoder = JSONDecoder()
        do {
            let detectionData = try decoder.decode(DetectionData.self, from: jsonData)
            print("\n\n Detection data is \(detectionData)\n\n")
            
            // Extracting class names
            let classNames = Set(detectionData.predictions.map { $0.class }).sorted()
            print("Class names is is \(classNames)")
            
            let observations = detectionData.getList()
            print("PauseAndTransform: Seeing list \(observations)")
            self.drawBoundingBoxes(on: &self.inputImage, with: observations)
            print("PauseAndTransform: Complete")
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
    
    
    func detectObjectsRemote() {
        print("Calling detectObjectsRemote\n")
        
        guard let inputImage=inputImage else {
            print("No image selected : detectObjectsRemote")
            return
        }

        let imageData = inputImage.jpegData(compressionQuality: 0.5)
        let fileContent = imageData?.base64EncodedString()
        let postData = fileContent!.data(using: .utf8)

        // Initialize Inference Server Request with API_KEY, Model, and Model Version
        let url = "https://detect.roboflow.com/"+FabricInfo.RF_MODEL_ID+"/1?api_key="+FabricInfo.RF_API_KEY+"&name=YOUR_IMAGE.jpg"
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData

        // Execute Post Request
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            // Parse Response to String
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            // Convert Response String to Dictionary
            do {
                let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
            
            // Print String Response
            let str=String(data: data, encoding: .utf8)!
            print("Showing data in detectObjectsRemote")
            print(str)
            parseAndTransform(jsonString: str)
        }).resume()

    }
    
    func detectObjectsRemoteApi() {
        guard let inputImage=inputImage else {
            print("No image selected : detectObjectsRemote")
            return
        }
        
        let rf = RoboflowMobile(apiKey: FabricInfo.RF_API_KEY)
        var mlModel: RFObjectDetectionModel!
        rf.load(model: FabricInfo.RF_MODEL_ID, modelVersion: 1) { [self] model, error, modelName, modelType in
            mlModel = model
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                model?.configure(threshold: 0.1, overlap: 0.4, maxObjects: 10.0)
            }
        }
        mlModel.detect(image: inputImage) { detections, errorr in
            let detectionResults: [RFObjectDetectionPrediction] = detections!
            print("Detection results remote \(detectionResults)")
            /*
            let objectBoundsAndLabels = detectionResults.map { dr -> (CGRect, String) in
                let drv=dr.getValues()
                let label = drv["classname"]
                let x: CGFloat = drv["x"]
                let y: CGFloat = drv["y"]
                let w: CGFloat = drv["width"]
                let h: CGFloat = drv["height"]
                let objectBounds=CGRect(x: x, y: y, width: drv["width"], height: drv["height"])
                     return (objectBounds, label)
                 }
            self.drawBoundingBoxes(on: &self.inputImage, with: objectBoundsAndLabels)
            */
             print("NOT IN USE Breakpoint")
        }
        
        print("dOR API: TO-DO TO-DO TO-DO")
    }
    
    func detectObjectsLocal() {
        guard let inputImage=inputImage else {
            print("No image selected")
            return
        }
        //let model1=TrashDetectionV1_1_Iteration_10000().model
        let model1=FabricObjectDetector_1().model
        guard let model = try? VNCoreMLModel(for: model1) else {
                fatalError("Failed to load Core ML model.")
            }
            let request = VNCoreMLRequest(model: model) { request, error in
                guard let results = request.results as? [VNRecognizedObjectObservation], !results.isEmpty else {
                    print("Unexpected result type from VNCoreMLRequest.")
                    return
                }
                // Draw bounding boxes around the detected objects
                let imageSize = inputImage.size
                let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -imageSize.height)
                let scale = CGAffineTransform.identity.scaledBy(x: imageSize.width, y: imageSize.height)
                let objectBoundsAndLabels = results.map { observation -> (CGRect, String) in
                         let observationBounds = observation.boundingBox
                         let objectBounds = observationBounds.applying(scale).applying(transform)
                         let label = observation.labels[0].identifier
                    
                         return (objectBounds, label)
                     }
                
                DispatchQueue.main.async {
                    self.inputImage = inputImage
                    self.detectedObjects = results.map { observation in
                        return observation.labels[0].identifier
                    }
                    self.drawBoundingBoxes(on: &self.inputImage, with: objectBoundsAndLabels)
                    //DataStore.updatedImage=self.inputImage
                }
            }
            let handler = VNImageRequestHandler(cgImage: inputImage.cgImage!)
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform detection: \(error.localizedDescription)")
            }
        }
    
    func printLCArray(aList: [LabelCoordinates]) {
        var i=0;
        for a in aList {
            print(a.label,a.x,a.y,separator: " ", terminator: " ")
            i = i+1;
            if(i%3==0) {
                print(" ")
            }
        }
    }
    
    func processItemArray() {
        print("In PIA, Item array is")
        printLCArray(aList: items)
        let minX = items.min(by: { $0.x < $1.x })?.x ?? 0
        let maxX = items.max(by: { $0.x < $1.x })?.x ?? 0
        
        let minY = items.min(by: { $0.y < $1.y })?.y ?? 0
        let maxY = items.max(by: { $0.y < $1.y })?.y ?? 0

        // Avoid division by zero if all x values are the same
        let rangeX = maxX - minX
        let rangeY = maxY - minY
        print(" x = \(minX) -> \(maxX) (\(rangeX)) ; y =  \(minY) -> \(maxY) (\(rangeY)) ")
        
        var scaledItems:[LabelCoordinates]=[]
        for item in items{
            let scaledX = (item.x - minX)*2/rangeX
            let scaledY = (item.y - minY)*2/rangeY
            scaledItems.append(LabelCoordinates(label: item.label, x: scaledX.rounded(), y: scaledY.rounded()))
        }

        
        let sortedLabels = scaledItems.sorted {
            if $0.x == $1.x {
                return $0.y < $1.y
            } else {
                return $0.x < $1.x
            }
        }.map { $0.label }

        // Use the sortedLabels as needed

        
        print("In PIA, scaled Item is\n")
        printLCArray(aList: scaledItems)
        print(sortedLabels)
        if let f = FabricInfo.getMatchingFabric(p: sortedLabels) {
            resultText = f.fabric
            resultDesc = f.desc
        } else {
            resultText = "Sorry. Fabric not found."
        }
    }
    
    
    func drawBoundingBoxes(on image: inout UIImage?, with objectBoundsAndLabels: [(CGRect, String)]) {
        UIGraphicsBeginImageContextWithOptions(image!.size, false, 0.0)
        image?.draw(in: CGRect(origin: CGPoint.zero, size: image!.size))
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(4.0)
        print("Entering the FOR LOOP")
        items=[]
        for (objectBounds, label) in objectBoundsAndLabels {
            context?.setStrokeColor(UIColor.red.cgColor)
            context?.addRect(objectBounds)
            context?.drawPath(using: .stroke)
            
            context?.setFillColor(UIColor.red.cgColor)
            if ["plastic"].contains(label) {
                //DataStore.label=label
                //DataStore.seen=true
            }
            let bx = objectBounds.origin.x
            let by = objectBounds.origin.y
            let w = objectBounds.width
            let h = objectBounds.height
            print("\(label): \(bx) \(by) \(w) \(h)")
            items.append(LabelCoordinates(label: label, x: bx+w/2, y: by+h/2))
            
            /*
            let labelRect = CGRect(x: objectBounds.origin.x, y: max(objectBounds.origin.y - 55,0), width: objectBounds.width, height: 55)
            context?.fill(labelRect)
            
            context?.setFillColor(UIColor.black.cgColor)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let labelFontAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24),
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: UIColor.black,
            ]
            let attributedLabel = NSAttributedString(string: label, attributes: labelFontAttributes)
            attributedLabel.draw(in: labelRect)
             */
        }
        print("Exiting the FOR LOOP")
        print("Item array is \(items)")
        processItemArray()
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    
    
    
}


struct ObjectDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectDetectionView()
    }
}
    
   
