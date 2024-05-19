import UIKit
import AVFoundation
import CoreData

class SoundViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var tiempoGrabacion: UILabel!
    @IBOutlet weak var volumenSlider: UISlider!
    
    
    var grabarAudio: AVAudioRecorder?
    var reproducirAudio: AVAudioPlayer?
    var audioURL: URL?
    var recordingTimer: Timer?
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio?.isRecording == true {
            grabarAudio?.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            stopRecordingTimer()
        } else {
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
            startRecordingTimer()
        }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("REPRODUCIENDO")
        } catch {
            print("Error al reproducir el audio: \(error)")
        }
    }
    
     @IBAction func volumenChanged(_ sender: UISlider) {
         let volumen = sender.value
         
         if volumen < 0.1 {
             mostrarAlerta(mensaje: "El volumen es muy bajo")
         }
        
         if volumen > 0.9 {
             mostrarAlerta(mensaje: "El volumen es muy alto")
         }
         
         if let reproducirAudio = reproducirAudio {
             reproducirAudio.volume = volumen
         }
     }

     func mostrarAlerta(mensaje: String) {
         let alerta = UIAlertController(title: "Advertencia", message: mensaje, preferredStyle: .alert)
         alerta.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         present(alerta, animated: true, completion: nil)
     }
    
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        
        // Obtener la duración del audio desde el archivo
        do {
            let audioFile = try AVAudioFile(forReading: audioURL!)
            let duration = Double(audioFile.length) / audioFile.fileFormat.sampleRate
            grabacion.duracion = duration
        } catch {
            print("Error al obtener la duración del audio: \(error)")
            grabacion.duracion = 0.0
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController?.popViewController(animated: true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        volumenSlider.value = 0.5
    }
    
    func configurarGrabacion() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            var settings: [String: AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio?.delegate = self
            grabarAudio!.prepareToRecord()
        } catch let error as NSError {
            print("Error al configurar la grabación: \(error)")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            stopRecordingTimer()
        } else {
            print("Error en la grabación")
        }
    }
    
    func startRecordingTimer() {
        recordingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRecordingDuration), userInfo: nil, repeats: true)
    }
    
    func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    @objc func updateRecordingDuration() {
        if let currentTime = grabarAudio?.currentTime {
            tiempoGrabacion.text = formatTime(currentTime)
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

