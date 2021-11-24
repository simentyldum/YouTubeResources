//
//  ImageDownloaderViewModel.swift
//  Multi Threading
//
//  Created by Simen Tyldum on 23/11/2021.
//

import Foundation
import UIKit
import Combine

final class ImageDownloaderViewModel {
    
    let image = PassthroughSubject<UIImage?, Never>()
    
    private var subscriptions = Set<AnyCancellable>()
    
    func download(url: String) {
        
        URLSession
            .shared
            .dataTaskPublisher(for: URL(string: url)!)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .handleEvents(receiveSubscription: { _ in
                print("Starting subscripting on the main thread: \(Thread.isMainThread)")
                DispatchQueue
                    .main
                    .async {
                        self.image.send(UIImage(named: "placeholder"))
                        print("Setting Placeholder on the main thread: \(Thread.isMainThread)")
                    }
                
            })
            .map({ UIImage(data: $0.data) })
            .receive(on: DispatchQueue.main)
            .sink { (res) in
                print("Finished subscription on the main thread: \(Thread.isMainThread)")
            } receiveValue:  { [weak self] (val) in
                self?.image.send(val)
                self?.image.send(completion: .finished)
                print("Recived subscription on the main thread: \(Thread.isMainThread)")
            }
            .store(in: &subscriptions)
            
    }
    
}
