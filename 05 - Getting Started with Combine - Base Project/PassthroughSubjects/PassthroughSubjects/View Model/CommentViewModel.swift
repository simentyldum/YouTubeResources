//
//  CommentViewModel.swift
//  PassthroughSubjects
//
//  Created by Simen Tyldum on 23/11/2021.
//

import Foundation
import Combine

final class CommentViewModel{
    
    private let commentEntered = PassthroughSubject<String, Never>()
    private var subscription = Set<AnyCancellable>()
    
    private let badWords = ["☦️", "☮️"]
    
    private let manager: AccountViewModel
    
    init(manager: AccountViewModel) {
        self.manager = manager
        setupSubscription()
    }
    
    func send (comment: String) {
        commentEntered.send(comment)
    }
}

private extension CommentViewModel {
    
    func setupSubscription(){
        commentEntered
            .filter({  !$0.isEmpty })
            .sink { [weak self] val in
                
                guard let self = self else { return }
                
                if self.badWords.contains(val) {
                    self.manager.increaseWarning()
                } else {
                    print("New comment \(val)")
                }
            }
        
            .store(in: &subscription)
    }
}
