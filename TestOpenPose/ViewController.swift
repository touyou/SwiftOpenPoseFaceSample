//
//  ViewController.swift
//  TestOpenPose
//
//  Created by 藤井陽介 on 2018/05/28.
//  Copyright © 2018 touyou. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var originalImageView: UIImageView!
    @IBOutlet weak var resultImageView: UIImageView!

    let predict = Face()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func selectImage() {

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }

    @IBAction func predictImage() {
        guard let originalImage = originalImageView.image else {

            return
        }

        if let pixelBuffer = originalImage.pixelBuffer(width: 368, height: 368) {

            if let output = try? predict.prediction(image: pixelBuffer) {

                let net_output = output.net_output
                let marray = try! MLMultiArray(shape: [46, 46], dataType: .double)
                for j in 0 ..< 71 {
                    let n = j * marray.count
                    var max_val = -100.0
                    var points = -1
                    for i in 0 ..< marray.count {
                        if net_output[i + n].doubleValue > max_val {
                            points = i
                            max_val = net_output[i + n].doubleValue
                        }
                    }
                    marray[points] = 1.0
                }
                resultImageView.image = marray.image(offset: 0, scale: 255)
            }
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }

        originalImageView.image = image
        dismiss(animated: true, completion: nil)
    }
}
