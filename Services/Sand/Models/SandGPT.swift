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
    
    @SharedObject(SessionManager.id) var session: SessionManager
    
    var CUSTOM_API_KEY: [UInt32]? = nil {
        didSet {
            session.isCustomAPI(CUSTOM_API_KEY != nil)
        }
    }
    
    static var API_KEY: String {
        ""
    }
    
    static var GOOGLE_API_KEY: String {
        ""
    }
    
    static var DEFAULT_ENGINE: String {
        "gpt-3.5-turbo"
    }
    
    private var client: ChatGPT? = nil
    private var lastEngineUsed: String = ""
    
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
        guard prompt.isNotEmpty else { return }
        
        if lastEngineUsed != config.engine {
            useCustomEngine(config.engine)
        }
                
        guard let client = self.client else { return }
        
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
    
    func reset() {
        self.currentTask?.cancel()
        self.reqDebounceTimer?.invalidate()
        self.replyCompletedTimer?.invalidate()
        self.isResponding = false
    }
    
    struct Response: GranitePayload {
        var data: String?
        var isComplete: Bool
        var isStream: Bool
        var isRestoring: Bool = false
    }
}

extension SandGPT {
    func useCustomAPI() {
        print("[SandGPT] Using custom API \(CUSTOM_API_KEY != nil)")
        guard let customAPIKeyData = self.CUSTOM_API_KEY else { return }
        guard let customAPIKey = ConfigService.decode(customAPIKeyData) else { return }
        
        self.client = ChatGPT(apiKey: customAPIKey,
                              defaultModel: .custom(modelId: SandGPT.DEFAULT_ENGINE))
        self.lastEngineUsed = SandGPT.DEFAULT_ENGINE
    }
    
    func useCustomEngine(_ engine: String) {
        print("[SandGPT] Using custom API w/ Custom Engine \(CUSTOM_API_KEY != nil)")
        guard let customAPIKeyData = self.CUSTOM_API_KEY else { return }
        guard let customAPIKey = ConfigService.decode(customAPIKeyData) else { return }
        
        self.client = ChatGPT(apiKey: customAPIKey, defaultModel: .custom(modelId: engine))
        self.lastEngineUsed = engine
    }
    
    func useMainAPI() {
        print("[SandGPT] Using main API \(CUSTOM_API_KEY == nil)")
        guard let apiKey = ConfigService.decode(SandGPT.API_KEY_ENCODED) else { return }
        
        self.client = ChatGPT(apiKey: apiKey, defaultModel: .custom(modelId: SandGPT.DEFAULT_ENGINE))
        self.lastEngineUsed = SandGPT.DEFAULT_ENGINE
    }
}

extension SandGPT {
    static var API_KEY_ENCODED: [UInt32] {
        []
    }
}
