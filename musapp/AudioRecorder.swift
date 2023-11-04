import AVFoundation

class AudioRecorder {
    
    let recordingDirName = "mic"
    
    var audioRecorder: AVAudioRecorder?
    
    func startRecording() {
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord)
            
            audioRecorder = try AVAudioRecorder(url: newRecordingFileUrl(), settings: [:])
            audioRecorder!.isMeteringEnabled = true
            audioRecorder!.record()
        } catch {
            print(error)
        }
    }
    
    func stopRecording() -> URL? {
        do {
            audioRecorder?.stop()
            try AVAudioSession.sharedInstance().setActive(false)
            
            return audioRecorder?.url
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func clearFiles() {
        let path = getRecordingsDir().path
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: path)
        
        while let file = enumerator?.nextObject() as? String {
            let filePath = (path as NSString).appendingPathComponent(file)
            
            do {
                try fileManager.removeItem(atPath: filePath)
                print("deleted: \(filePath)")
            } catch {
                print("couldn't delete: \(filePath)")
            }
        }
    }
    
    private func newRecordingName() -> String {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.string(from: currentDate) + ".wav"
        return recordingName
    }
    
    private func getRecordingsDir() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(recordingDirName)
    }
    
    private func newRecordingFileUrl() -> URL {
        let dir = getRecordingsDir()
        try! FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        
        let filePath = dir.appendingPathComponent(newRecordingName())
        let fileUrl = URL(fileURLWithPath: filePath.path)
        
        return fileUrl
    }
}
