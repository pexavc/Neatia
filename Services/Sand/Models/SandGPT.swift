//
//  SandGPT.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/9/23.
//

import Foundation
import SandKit
import Combine
import Granite
import MarqueKit
import GPT3_Tokenizer

class SandGPT {
    static let shared: SandGPT = .init()
    
    @SharedObject("nyc.stoic.Neatia.SessionManager") var session: SessionManager
    
    var CUSTOM_API_KEY: [UInt32]? = nil {
        didSet {
            session.isCustomAPI(CUSTOM_API_KEY != nil)
        }
    }
    
    static var API_KEY: String {
        "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"
    }
    
    private var client: ChatGPT? = nil
    
    let gpt3Tokenizer = GPT3Tokenizer()
    
    private var currentTask: SandTask? = nil
    private var reqDebounceTimer: Timer? = nil
    private var replyCompletedTimer: Timer? = nil
    
    @Published var isResponding: Bool = false
    
    func ask<E: EventExecutable>(_ prompt: String,
                                 withSystemPrompt systemPrompt: String? = nil,
                                 withConfig config: PromptConfig,
                                 stream: Bool = false,
                                 event: E) {
        print("[SandGPT] prompt token count: \(prompt.components(separatedBy: " ").count)")
        guard prompt.isNotEmpty, let client = self.client else { return }
        
        currentTask?.cancel()
        currentTask = .init()
        isResponding = true
        
        print("[SandGPT] creating Debounce Timer")
        
        reqDebounceTimer?.invalidate()
        reqDebounceTimer = Timer.scheduledTimer(
            withTimeInterval: 0.8.randomBetween(1.2),
            repeats: false) { [weak self] timer in
                
                print("[SandGPT] invalidating timer")
                
                timer.invalidate()
                
                print("[SandGPT] creatingTask")
                
                if stream {
                    self?.updateCompletedTimer(event)
                }
                
                self?.currentTask?.task = Task {
                    
                    var reply: String = ""
                    
                    if stream {
                        var replyDebouncerInit: CGFloat = CFAbsoluteTimeGetCurrent()
                        for try await nextWord in try await client
                            .streamedAnswer.ask(prompt,
                                                withSystemPrompt: systemPrompt,
                                                withConfig: config) {
                            
                            SandGPT.shared.updateCompletedTimer(event)
                            
                            reply += nextWord
                            
                            //print("[SandGPT] streaming // nextWord: \(nextWord)")
                            
                            if CFAbsoluteTimeGetCurrent() - replyDebouncerInit >= 0.24 {
                                replyDebouncerInit = CFAbsoluteTimeGetCurrent()
                                event.send(Response(data: reply, isComplete: false, isStream: true))
                            }
                        }
                    } else {
                        reply = try await client.ask(prompt, withSystemPrompt: systemPrompt, withConfig: config)
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.isResponding = false
                        }
                        
                        event.send(Response(data: reply, isComplete: true, isStream: false))
                    }
                }
            }
    }
    
    func updateCompletedTimer<E: EventExecutable>(_ event: E) {
        DispatchQueue.main.async { [weak self] in
            self?.replyCompletedTimer?.invalidate()
            self?.replyCompletedTimer = Timer.scheduledTimer(
                withTimeInterval: 2.4,
                repeats: false) { completedTimer in
                    
                    print("[SandGPT] stream isComplete")
                    
                    completedTimer.invalidate()
                    DispatchQueue.main.async { [weak self] in
                        self?.isResponding = false
                    }
                    event.send(Response(data: nil, isComplete: true, isStream: true))
                }
        }
    }
    
    struct Response: GranitePayload {
        var data: String?
        var isComplete: Bool
        var isStream: Bool
    }
}

extension SandGPT {
    func useCustomAPI() {
        print("[SandGPT] Using custom API \(CUSTOM_API_KEY == nil)")
        guard let customAPIKeyData = self.CUSTOM_API_KEY else { return }
        guard let customAPIKey = ConfigService.decode(customAPIKeyData) else { return }
        
//        print("[SandGPT] decoded key: \(customAPIKey)")
        self.client = ChatGPT(apiKey: customAPIKey, defaultModel: .custom(modelId: "gpt-3.5-turbo"))
    }
    
    func useMainAPI() {
        print("[SandGPT] Using main API \(CUSTOM_API_KEY == nil)")
        self.client = ChatGPT(apiKey: SandGPT.API_KEY, defaultModel: .custom(modelId: "gpt-3.5-turbo"))
    }
}
