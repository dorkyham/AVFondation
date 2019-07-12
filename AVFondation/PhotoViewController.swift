//
//  PhotoViewController.swift
//  AVFondation
//
//  Created by Annisa Nabila Nasution on 08/07/19.
//  Copyright © 2019 Annisa Nabila Nasution. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    var takenPhoto : UIImage?
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let availableImage = takenPhoto {
            imageView.image = availableImage
        }
    }
    
    
    @IBAction func savePhoto(_ sender: Any) {
        guard let selectedImage = imageView.image else {
            print("Image not found!")
            return
        }
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            print("save error")
        } else {
            print("Your image has been saved to your photos.")
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
