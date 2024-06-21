//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Mustafa DANIŞAN on 30.05.2024.
//

import UIKit
import CoreData

class DetailsVC: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!

    // Seçilen ögeyi diğerlerinden ayırmak için
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            
            // Save button'unu gizlemek için
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let artsist = result.value(forKey: "artist") as? String {
                            artistText.text = artsist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }catch {
                print("ERROR")
            }
            
        }else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        // Image'yi tıklanabilir yapmak için
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectİmage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    // Kullanıcıya cihazdan image seçtirmek için
    @objc func selectİmage () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // İmage seçimindeki fotoğraf düzenlemesi için
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    // Herhangi bir yere tıklandığında klavyeyi kapatmak için
    @objc func hideKeyboard () {
        view.endEditing(true)
    }
    
    // Değerleri girilmiş ögeleri CoreData'ya kaydetmek için ayarlanmış kaydetme buttonu
    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(nameText.text!, forKey: "name")
        
        newPainting.setValue(artistText.text!, forKey: "artist")
        
        if let year = Int(yearText.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("SUCCESS")
        }catch {
            print("ERROR")
        }
        // Kaydetme işleminden sonra bilgilerin tableView bileşenine ve diğer sayfaya göndermek için ayarlanmış navigation sistemi
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    

}
