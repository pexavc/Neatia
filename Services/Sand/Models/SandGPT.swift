//
//  SandGPT.swift
//  Sina
//
//  Created by Ritesh Pakala on 5/9/23.
//

import Foundation
import SandKit
import Combine
import Granite
import GPT3_Tokenizer

class SandGPT {
    static let shared: SandGPT = .init()
    
    static var API_KEY: String {
        SandGPT.API_DEV_KEY
        //"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"
    }
    
    static var API_DEV_KEY: String {
        "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"
    }
    
    let client = ChatGPT(apiKey: SandGPT.API_KEY, defaultModel: .custom(modelId: "gpt-3.5-turbo"))
    
    let gpt3Tokenizer = GPT3Tokenizer()
    
    private var currentTask: SandTask? = nil
    private var reqDebounceTimer: Timer? = nil
    private var replyCompletedTimer: Timer? = nil
    
    @Published var isResponding: Bool = false
    
    func ask<E: EventExecutable>(_ prompt: String,
                                 withSystemPrompt systemPrompt: String? = nil,
                                 event: E) {
        print("[SandGPT] prompt token count: \(prompt.components(separatedBy: " ").count)")
        guard prompt.isNotEmpty else { return }
        
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
                
                guard let client = self?.client else {
                    self?.isResponding = false
                    return
                }
                
                print("[SandGPT] creatingTask")
                
                self?.updateCompletedTimer(event)
                
                
                self?.currentTask?.task = Task {
                    
                    var replyDebouncerInit: CGFloat = CFAbsoluteTimeGetCurrent()
                    var reply: String = ""
                    for try await nextWord in try await client.streamedAnswer.ask(prompt,
                                                                                        withSystemPrompt: systemPrompt) {
                        
                        SandGPT.shared.updateCompletedTimer(event)
                        
                        reply += nextWord
                        
                        //print("[SandGPT] streaming // nextWord: \(nextWord)")
                        
                        if CFAbsoluteTimeGetCurrent() - replyDebouncerInit >= 0.24 {
                            replyDebouncerInit = CFAbsoluteTimeGetCurrent()
                            event.send(Response(data: reply, isComplete: false))
                        }
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
                    event.send(Response(data: nil, isComplete: true))
                }
        }
    }
    
    struct Response: GranitePayload {
        var data: String?
        var isComplete: Bool
    }
}
