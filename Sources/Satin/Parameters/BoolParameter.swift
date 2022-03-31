//
//  BoolParameter.swift
//  Satin
//
//  Created by Reza Ali on 10/22/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import Foundation

open class BoolParameter: GenericParameter<Bool> {

    public override var string: String { return "bool" }
        
    public init(_ label: String, _ value: Bool = false, _ controlType: ControlType = .unknown, _ action: ((Bool) -> Void)? = nil) {
        super.init(value: value, label: label, controlType: controlType)
        if let a = action {
            actions.append(a)
        }
    }
    
    public init(_ label: String, _ controlType: ControlType = .unknown, _ action: ((Bool) -> Void)? = nil) {
        super.init(value: false, label: label, controlType: controlType)
        if let a = action {
            actions.append(a)
        }
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

}
