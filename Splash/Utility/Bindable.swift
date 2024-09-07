//
//  Bindable.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

class Bindable<T> {
    var value: T {
        didSet {
            observer?(value)
        }
    }
    
    private var observer: ((T) -> Void)?
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(observer: @escaping (T) -> Void) {
        self.observer = observer
        observer(value)
    }
}
