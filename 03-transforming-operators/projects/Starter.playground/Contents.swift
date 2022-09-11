import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "collect") {
    ["A", "B", "C"].publisher
        .collect(2)
        .sink { result in
            switch result {
            case .failure:
                print("failed")
            case .finished:
                print("finished")
            }
        } receiveValue: { string in
            print("received: \(string)")
        }
        .store(in: &subscriptions)

}

example(of: "map") {
    ["A", "B", "C"].publisher
        .map { $0 + " hinnye"}
        .sink(receiveValue: {print("tranformed: \($0)")})
        .store(in: &subscriptions)
}

example(of: "map_keppath") {
    struct TObj {
        let value1: Int
        let value2: String
        var value3: String {
            "\(value1) db \(value2)"
        }
    }

    let publisher = PassthroughSubject<TObj, Never>()
    
    publisher
        .map(\.value1, \.value2, \.value3)
        .sink { v1, v2, v3 in
            print("v1: \(v1)", "v2: \(v2)", "v3: \(v3)")
        }
        .store(in: &subscriptions)
    
    publisher.send(TObj(value1: 10, value2: "value2"))
}

example(of: "flatMap") {
    func decode(_ codes: [Int]) -> AnyPublisher<String, Never> {
        Just(
            codes.compactMap { code in
                guard (32...255).contains(code) else { return nil }
                return String(UnicodeScalar(code) ?? " ")
            }
            .joined()
        )
        .eraseToAnyPublisher()
    }
    
    [72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33].publisher
        .collect()
        .flatMap(decode)
        .sink(receiveValue: { print($0)})
        .store(in: &subscriptions)
}

example(of: "replacenil") {
    ["A", nil, "B"].publisher
        .eraseToAnyPublisher()
        .replaceNil(with: "nemjó")
        .sink(receiveValue: {print($0)})
        .store(in: &subscriptions)
}

example(of: "replaceEmpty(with:)") {
    let empty = Empty<Int, Never>()
    
    empty
        .replaceEmpty(with: 7)
        .sink(receiveCompletion: {print($0)},
              receiveValue: { print($0)})
        .store(in: &subscriptions)
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
