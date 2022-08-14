import Foundation
import Combine
import _Concurrency

var subscriptions = Set<AnyCancellable>()

example(of: "Publisher") {
    let myNotification = Notification.Name("MyNotification")
    
    let center = NotificationCenter.default
    
    let observer = center.addObserver(forName: myNotification,
                                      object: nil,
                                      queue: nil) { notification in
        print("Notification received")
    }
    
    center.post(name: myNotification, object: nil)
    
    center.removeObserver(observer)
}

example(of: "Subscriber") {
    let myNoti = Notification.Name("MyNoti")
    let center = NotificationCenter.default
    let publisher = center.publisher(for: myNoti, object: nil)
    
    let subscription = publisher.sink { _ in
        print("Notification received from publisher")
    }

    center.post(name: myNoti, object: nil)
    
    subscription.cancel()
}

example(of: "Just") {
    let just = Just("Hello world")
    
    _ = just.sink(receiveCompletion: {
        print("Received completion", $0)
    }, receiveValue: {
        print("Received value", $0)
    })
    
    _ = just.sink(receiveCompletion: {
        print("Received (another) completion", $0)
    }, receiveValue: {
        print("Received (another) value", $0)
    })
}

example(of: "assign(to:on:)") {
    class SomeObject {
        var value: String = "" {
            didSet {
                print(value)
            }
        }
    }
    
    let object = SomeObject()
    
    let publisher = ["Hello", "world"].publisher
    
    _ = publisher.assign(to: \.value, on: object)
}

example(of: "assign(to:)") {
    class SomeObject {
        @Published var value = -1
    }
    
    let object = SomeObject()
    
    object.$value.sink { recVal in
        print("received: \(recVal)")
    }
    
    (0..<10).publisher.assign(to: &object.$value)
}

example(of: "Custom Subscriber") {
    let publisher = (1...6).publisher
    
    final class IntSubscriber: Subscriber {
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)
            return .none
        }
    
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion", completion)
        }
        
        typealias Failure = Never
        
        typealias Input = Int
    }
    
    let subscriber = IntSubscriber()
    publisher.subscribe(subscriber)
}

/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
