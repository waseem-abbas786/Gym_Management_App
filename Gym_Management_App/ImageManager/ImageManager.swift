//
//  ImageManager.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 26/08/2025.
//

import Foundation
import UIKit
class ImageManager {
    static let instance = ImageManager()
    private init(){ }
    
    func saveImageToFileManager(image: UIImage) -> String {
       let filename = UUID().uuidString + ".jpg"
       let url = getDocumentsDirectory().appendingPathComponent(filename)
       
       if let data = image.jpegData(compressionQuality: 0.8) {
           try? data.write(to: url)
       }
       
       return filename
   }
   
   
   func loadImageFromFileManager(path: String) -> UIImage? {
       let url = getDocumentsDirectory().appendingPathComponent(path)
       if let data = try? Data(contentsOf: url) {
           return UIImage(data: data)
       }
       return nil
   }
   
   
   private func getDocumentsDirectory() -> URL {
       FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
   }
}
