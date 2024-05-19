//
//  SoundViewController.swift
//  MamaniCruzSoundBoard
//
//  Created by Franklin Junnior on 5/18/24.
//  Copyright © 2024 franklin. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData




class SoundViewController: UIViewController {
    
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            // Detener la grabación
            grabarAudio?.stop()
            // Cambiar el texto del botón grabar
            grabarButton.setTitle("GRABAR", for: .normal)
            // Habilitar el botón de reproducir
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        } else {
            // Empezar a grabar
            grabarAudio?.record()
            // Cambiar el texto del botón grabar a detener
            grabarButton.setTitle("DETENER", for: .normal)
            // Deshabilitar el botón de reproducir
            reproducirButton.isEnabled = false
        }
    }
	
    
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {}
    }
    
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }

    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        

        // Do any additional setup after loading the view.
    }
    
    func configurarGrabacion(){

    do{

    //creando sesion de audio

    let session = AVAudioSession.sharedInstance()

    try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options:[])

    try session.overrideOutputAudioPort(.speaker)

    try session.setActive(true)

    //creando direccion para el archivo de audio

    let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!

    let pathComponents = [basePath,"audio.m4a"]

    audioURL = NSURL.fileURL(withPathComponents: pathComponents)!

    //impresion de ruta donde se guardan los archivos

    print("********************")

    print(audioURL!)

    print("********************")

    //crear opciones para el grabador de audio

    var settings:[String:AnyObject] = [:]

    settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?

    settings[AVSampleRateKey] = 44100.0 as AnyObject?

    settings[AVNumberOfChannelsKey] = 2 as AnyObject?

    //crear el objeto de grabacion de audio

    grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)

    grabarAudio!.prepareToRecord()

    } catch let error as NSError{

    print(error)

    }

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
