//
//  GenericParamter.swift
//  Satin
//
//  Created by Taylor Holliday on 3/30/22.
//

import Foundation

open class GenericParameter<T>: NSObject, Parameter where T: Equatable, T: Codable {

    private enum CodingKeys: String, CodingKey {
        case controlType
        case label
        case value
    }

    public init(value: T, label: String, controlType: ControlType, action: ((T) -> Void)?) {
        self.value = value
        self.label = label
        self.controlType = controlType
        if let action = action {
            self.actions = [action]
        }
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        controlType = try values.decode(ControlType.self, forKey: .controlType)
        label = try values.decode(String.self, forKey: .label)
        value = try values.decode(T.self, forKey: .value)
    }

    open func encode(to encoder: Encoder) throws {}

    public static var type: ParameterType { fatalError() }

    public weak var delegate: ParameterDelegate?

    public var controlType: ControlType = .button
    public var label: String
    public var string: String { fatalError() }
    public var size: Int { return MemoryLayout<T>.size }
    public var stride: Int { return MemoryLayout<T>.stride }
    public var alignment: Int { return MemoryLayout<T>.alignment }
    public var count: Int { return 1 }
    public var actions: [(T) -> Void] = []

    public func onChange(_ fn: @escaping ((T) -> ())) {
        actions.append(fn)
    }

    public subscript<V>(index: Int) -> V {
        get {
            return value as! V
        }
        set {
            value = newValue as! T
        }
    }

    public dynamic var value: T {
        didSet {
            if oldValue != value {
                emit()
            }
        }
    }

    public func dataType<T>() -> T.Type {
        T.self
    }

    public func alignData(pointer: UnsafeMutableRawPointer, offset: inout Int) -> UnsafeMutableRawPointer {
        var data = pointer
        let rem = offset % alignment
        if rem > 0 {
            let remOffset = alignment - rem
            data += remOffset
            offset += remOffset
        }
        return data
    }

    public func writeData(pointer: UnsafeMutableRawPointer, offset: inout Int) -> UnsafeMutableRawPointer {
        var data = alignData(pointer: pointer, offset: &offset)
        offset += size

        data.storeBytes(of: value, as: T.self)
        data += size

        return data
    }

    func emit() {
        delegate?.updated(parameter: self)
        for action in self.actions {
            action(self.value)
        }
    }
}
