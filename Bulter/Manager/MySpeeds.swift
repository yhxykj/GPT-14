//
//  MySpeeds.swift
//  Bulter
//
//  Created by JJK on 2024/4/9.
//

import UIKit
import Speech
import AVFAudio
import AdSupport
import Accelerate
import SVProgressHUD

enum AlisPlayStatus {
    case start
    case end
}

class MySpeeds: NSObject {
    
    let utils: NeoNuiTts = NeoNuiTts.get_instance()
    let voicePlayer: NLSPlayAudio = NLSPlayAudio()
    typealias CompletionHandler = (AlisPlayStatus) -> Void
    var completionHandler: CompletionHandler?
    
    static let shared: MySpeeds = {
        let instance = MySpeeds()
        instance.utils.delegate = instance
        instance.voicePlayer.delegate = instance
        return instance
    }()
    
    func startPlay(fontName: String = "", message: String, completionHandler: CompletionHandler?) {
        
        stopPlay(false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self]  in
            
            self.completionHandler = completionHandler
            
            utils.nui_tts_initialize(getInitParam(), logLevel: NuiSdkLogLevel(0), saveLog: true)

            if fontName == "" {
                if let font_name: String = UserDefaults.standard.object(forKey: "font_name") as? String {
                    utils.nui_tts_set_param("font_name", value: font_name)
                }else {
                    utils.nui_tts_set_param("font_name", value: "zhimiao_emo")
                }
            }else {
                utils.nui_tts_set_param("font_name", value: fontName)
            }
            let d_image = UserDefaults.standard.float(forKey: "rate")
            if d_image > 0 {
                utils.nui_tts_set_param("speed_level", value: String(format: "%0.2f", d_image))
            }
            utils.nui_tts_play("1", taskId: "", text: message)
            
        }
    }
    
    func stopPlay(_ isBlock: Bool = true) {
        
        voicePlayer.stop()
        utils.nui_tts_cancel(nil)
        if isBlock { self.completionHandler?(.end) }
        
    }
}

func createPath() -> String {
       
    let e_count = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let vip = e_count[0]
   
    let tap = FileManager.default
    let cancel = (vip as NSString).appendingPathComponent("voices")
    
    do {
        try tap.createDirectory(atPath: cancel, withIntermediateDirectories: true, attributes: nil)
        print("文件夹创建成功")
    } catch {
        print("文件夹创建失败")
    }
    return cancel
}

func getInitParam() -> String {
       
    guard let strResourcesBundle = Bundle.main.path(forResource: "Resources", ofType: "bundle") else {
        return ""
    }
    
    let rawing = Bundle(path: strResourcesBundle)?.resourcePath ?? ""
    let context = ASIdentifierManager.shared().advertisingIdentifier.uuidString
 
    let find = createPath()
    
    if let token = UserDefaults.standard.string(forKey: "AliToken") {
        
        var param = [String: Any]()
        param["app_key"] = "FwsOLV8DKcHopkcl"
        param["token"] = token
        param["workspace"] = rawing
        param["debug_path"] = find
        param["device_id"] = context
        param["url"] = "wss://nls-gateway.cn-shanghai.aliyuncs.com:443/ws/v1"
        param["mode_type"] = "2"

        do {
            let playing = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
            if let jsonStr = String(data: playing, encoding: .utf8) {
                return jsonStr
            }
        } catch {
            print("JSONSerialization error: \(error)")
        }
    }else {
        SVProgressHUD.showError(withStatus: "阿里Token无效")
    }

    return ""
}

func checkAliToken() {
    
    NetAlamofire.shared.post(urlSuffix: "/app/getAliyunToken") { (result: Result<AppVoicePlay, NetworkError>) in
        switch result {
        case .success(let model):
            if model.code == 200 {
                UserDefaults.standard.setValue(model.data, forKey: "AliToken")
                print("阿里Token\(model.data)")
                UserDefaults.standard.synchronize()
            }
            else if model.code == 401 {
                NotificationCenter.default.post(name: NSNotification.Name("loginFailNotificationName"), object: nil)
            }
            
            break
        case.failure(_):
            SVProgressHUD.showError(withStatus: "获取Token失败");
            break
        }
    }

}


extension MySpeeds: NeoNuiTtsDelegate, NlsPlayerDelegate {
    
    func playerDidFinish() {
        
         stopPlay()
    
    }
    
    func onNuiTtsEventCallback(_ event: NuiSdkTtsEvent, taskId taskid: UnsafeMutablePointer<CChar>!, code: Int32) {
            
       if event == NuiSdkTtsEvent(rawValue: 0) {
           
           do {
               try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)

               try AVAudioSession.sharedInstance().setActive(true)
           } catch {
               print("Failed to set audio session category: \(error)")
           }
           voicePlayer.play()
           self.completionHandler?(.start)

       } else if event == NuiSdkTtsEvent(rawValue: 1) || event == NuiSdkTtsEvent(rawValue: 2) || event == NuiSdkTtsEvent(rawValue: 5) {
           if event == NuiSdkTtsEvent(rawValue: 1) {
               
               voicePlayer.drain()
           } else {
               
           }
           if event == NuiSdkTtsEvent(rawValue: 5) {
               stopPlay(false)
               let json = utils.nui_tts_get_param("error_msg")
               print(json)
           }
       }
    }
    
    func onNuiTtsUserdataCallback(_ info: UnsafeMutablePointer<CChar>!, infoLen info_len: Int32, buffer: UnsafeMutablePointer<CChar>!, len: Int32, taskId task_id: UnsafeMutablePointer<CChar>!) {

        if len > 0 {
            voicePlayer.write(buffer, length: Int32(len))
        }
       
    }
    
    func onNuiTtsVolumeCallback(_ volume: Int32, taskId task_id: UnsafeMutablePointer<CChar>!) {
    
        debugPrint("——————音频波纹：\(volume)")
    
    }
}


class MySpeedsTask: NSObject {
    
    var generateStrExpireList: [Any]!
    var has_Request: Bool = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var voiceCancel: Bool = false
    private var isDetectionEnabled: Bool
    var speakTimer: DispatchSourceTimer?
    private let silenceThreshold: TimeInterval = 3.0
    private let generator = UIImpactFeedbackGenerator(style: .light)

    var resultHandler: ((String) -> Void)?
    var decibelScaleHandler: ((Float) -> Void)?

    init(isDetectionEnabled: Bool = false) {
        self.isDetectionEnabled = isDetectionEnabled
        self.generator.prepare()
    }

    
    private func stopSpeakingTimer() {

        speakTimer?.cancel()
        speakTimer = nil
    }

    func cancelRecording() {
        
        voiceCancel = true
        stopRecording()
    }

    
    func startRecording() {
        
        generator.impactOccurred()
        audioEngine.stop()
        audioEngine.reset()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            
            guard let self = self else { return }

            checkAliToken()
            
            if let recognitionTask = self.recognitionTask {
                recognitionTask.cancel()
                self.recognitionTask = nil
            }

            self.voiceCancel = false
            
            let statues = AVAudioSession.sharedInstance()
            try! statues.setCategory(.record, mode: .measurement, options: .duckOthers)
            try! statues.setActive(true, options: .notifyOthersOnDeactivation)

            self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

            let restore = self.audioEngine.inputNode

            guard let recognitionRequest = self.recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }

            recognitionRequest.shouldReportPartialResults = true
            
            self.recognitionTask = self.speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                var button = false
                
                if let result = result {
                    
                    if self.isDetectionEnabled {
                        self.stopSpeakingTimer()
                        self.startSpeakingTimer()
                    }
                    print("——————说话中: \(result.bestTranscription.formattedString)")
                    button = result.isFinal
                }

                if error != nil || button {
                    self.audioEngine.stop()
                    restore.removeTap(onBus: 0)

                    self.recognitionRequest = nil
                    self.recognitionTask = nil

                    if let result = result {
                        if self.voiceCancel == false {
                            self.resultHandler?(result.bestTranscription.formattedString)
                        }
                    }
                }
            }

            let chat = restore.outputFormat(forBus: 0)
            restore.installTap(onBus: 0, bufferSize: 1024, format: chat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest?.append(buffer)
                
                
                guard let channelData = buffer.floatChannelData else { return }
                
                
                let recordingv = vDSP_Length(buffer.frameLength)
                var userdata: Float = 0
                vDSP_rmsqv(channelData[0], 1, &userdata, recordingv)
                
                
                let query = 20 * log10(userdata)
                
                
                DispatchQueue.main.async {
                    
                    let picker = 1.0 + CGFloat((query + 50) / 50.0)
                    let date = max(1.0, min(picker, 1.5))
                    
                    if date > 1.0 {
                        self.decibelScaleHandler?(Float(date))
                    }
                }
            }
            
            self.audioEngine.prepare()
            try! self.audioEngine.start()
        }
        
    }

    func stopRecording() {
        
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }

            self.stopSpeakingTimer()
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
            let statues = AVAudioSession.sharedInstance()
            try! statues.setCategory(.playback, mode: .default)
            try! statues.setActive(true, options: .notifyOthersOnDeactivation)
        }
        
    }

    private func startSpeakingTimer() {

        if speakTimer == nil {
            speakTimer?.cancel()
            speakTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
            speakTimer?.schedule(deadline: .now() + silenceThreshold, repeating: .never)
            speakTimer?.setEventHandler { [weak self] in
                self?.stopRecording()
            }
            speakTimer?.resume()
        }
    }
    
}

//import UIKit
//import Speech
//import Accelerate
//import SVProgressHUD
//
//class SpeechRecognizer: NSObject {
//
//    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))!
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    private let audioEngine = AVAudioEngine()
//    private var targetView: UIView?
//    private var voiceText: UILabel?
//    private var voiceCancel: Bool = false
//    private var isDetectionEnabled: Bool
//    var isSpeakingTimer: DispatchSourceTimer?
//    private let silenceThreshold: TimeInterval = 3.0
//    private let generator = UIImpactFeedbackGenerator(style: .light)
//
//    var resultHandler: ((String) -> Void)?
//    var dbScaleHandler: ((Float) -> Void)?
//
//    init(targetView: UIView = UIView(), voiceText: UILabel = UILabel(), isDetectionEnabled: Bool = false) {
//        voiceText.text = "请问有什么可以帮到您的？"
//        self.targetView = targetView
//        voiceText.adjustsFontSizeToFitWidth = true
//        self.voiceText = voiceText
//        self.isDetectionEnabled = isDetectionEnabled
//        self.generator.prepare()
//    }
//
//    func startRecording() {
//
//        generator.impactOccurred()
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//
//            guard let self = self else { return }
//
//            checkAliasTTSToken()
//
//            if let recognitionTask = recognitionTask {
//                recognitionTask.cancel()
//                self.recognitionTask = nil
//            }
//
//            voiceCancel = false
//            self.voiceText?.text = "请问有什么可以帮到您的？"
//
//            let audioSession = AVAudioSession.sharedInstance()
//            try! audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//            try! audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//
//            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//
//            let inputNode = audioEngine.inputNode
//
//            guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
//
//            recognitionRequest.shouldReportPartialResults = true
//
//            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
//                var isFinal = false
//
//                if let result = result {
//
//                    if self.isDetectionEnabled {
//                        self.stopSpeakingTimer()
//                        self.startSpeakingTimer()
//                    }
//                    print("——————说话中: \(result.bestTranscription.formattedString)")
//                    self.voiceText?.text = result.bestTranscription.formattedString
//                    isFinal = result.isFinal
//                }
//
//                if error != nil || isFinal {
//                    self.audioEngine.stop()
//                    inputNode.removeTap(onBus: 0)
//
//                    self.recognitionRequest = nil
//                    self.recognitionTask = nil
//
//                    if let result = result {
//                        if self.voiceCancel == false {
//                            self.resultHandler?(result.bestTranscription.formattedString)
//                        }
//                    }
//                }
//            }
//
//            let recordingFormat = inputNode.outputFormat(forBus: 0)
//            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
//                self.recognitionRequest?.append(buffer)
//
//                // 获取音频数据
//                guard let channelData = buffer.floatChannelData else { return }
//
//                // 计算音频数据的平均绝对值
//                let length = vDSP_Length(buffer.frameLength)
//                var rms: Float = 0
//                vDSP_rmsqv(channelData[0], 1, &rms, length)
//
//                // 将音量转换为分贝
//                let dB = 20 * log10(rms)
//
//                // 更新 UI
//                DispatchQueue.main.async {
//                    // 将分贝值映射到 [1, 1.23] 范围内
//                    let scaleValue = 1.0 + CGFloat((dB + 50) / 50.0)
//                    let scale = max(1.0, min(scaleValue, 1.23))
//
//                    if scale > 1.0 {
//                        self.dbScaleHandler?(Float(scale))
//                    }
//                    // 更新大小
//                    UIView.animate(withDuration: 0.1, animations: {
//                        self.targetView?.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
//                    })
//                }
//            }
//
//            audioEngine.prepare()
//            try! audioEngine.start()
//        }
//
//    }
//
//    func cancelRecording() {
//        voiceCancel = true
//        stopRecording()
//    }
//
//    func stopRecording() {
//
//        generator.impactOccurred() // 触感反馈
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//            guard let self = self else { return }
//
//            stopSpeakingTimer()
//            audioEngine.stop()
//            recognitionRequest?.endAudio()
//
//            self.voiceText?.text = "请问有什么可以帮到您的？"
//
//            let audioSession = AVAudioSession.sharedInstance()
//            try! audioSession.setCategory(.playback, mode: .default)
//            try! audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//        }
//
//    }
//
//    private func startSpeakingTimer() {
//        if isSpeakingTimer == nil {
//            isSpeakingTimer?.cancel()
//            isSpeakingTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
//            isSpeakingTimer?.schedule(deadline: .now() + silenceThreshold, repeating: .never)
//            isSpeakingTimer?.setEventHandler { [weak self] in
//                self?.stopRecording()
//            }
//            isSpeakingTimer?.resume()
//        }
//    }
//
//    private func stopSpeakingTimer() {
//        isSpeakingTimer?.cancel()
//        isSpeakingTimer = nil
//    }
//
//}
