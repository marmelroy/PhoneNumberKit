//
//  Characters+asciiIntValue.swift
//  PhoneNumberKit
//
//  Created by Emeric Spiroux on 15/03/2017.
//  Copyright © 2017 Roy Marmelstein. All rights reserved.
//

import Foundation

extension Character
{
	var asciiIntValue:UInt32{
		get{
			let characterString = String(self)
			let scalars = characterString.unicodeScalars
			
			return scalars[scalars.startIndex].value
		}
	}
}
