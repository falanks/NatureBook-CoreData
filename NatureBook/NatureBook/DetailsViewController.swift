//
//  DetailsViewController.swift
//  NatureBook
//
//  Created by Muhammed Sağlam on 23.10.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var placeTF: UITextField!
    @IBOutlet weak var yearTF: UITextField!
    
    var targetName = ""
    var targetId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if targetName != "" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Gallery")
            //filtreleme
            let idString = targetId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false

            do {
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        nameTF.text = name
                    }
                    if let place = result.value(forKey: "place") as? String {
                        placeTF.text = place
                    }
                    if let year = result.value(forKey: "year") as? Int {
                        yearTF.text = String(year)
                    }
                    if let imageData = result.value(forKey: "image") as? Data {
                        let image = UIImage(data: imageData)
                        imageView.image = image
                    }
                }
            } catch {
                print("error!")
            }

        } else {
            nameTF.text = ""
            placeTF.text = ""
            yearTF.text = ""
        }

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage))
        imageView.addGestureRecognizer(gestureRecognizer)
    }

    @objc func pickImage() {
        //print("image tiklandi")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let gallery = NSEntityDescription.insertNewObject(forEntityName: "Gallery", into: context)
        gallery.setValue(nameTF.text, forKey: "name")
        gallery.setValue(placeTF.text, forKey: "place")
     
        if let year = Int(yearTF.text!) {
            gallery.setValue(year, forKey: "year")
        }
       
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        gallery.setValue(data, forKey: "image")
       
        gallery.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("kayit tamamlandi")
        } catch {
            print("hata")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.init("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}
