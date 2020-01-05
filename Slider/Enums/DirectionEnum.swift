//
//  DirectionEnum.swift
//
//  Copyright (c) 2019 Ramiz Kichibekov (https://t.me/Ramiz69)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

public enum DirectionEnum: DirectionType {
    
    case leftToRight
    case rightToLeft
    
    public var trackMaxColor: UIColor {
        return UIColor(red: 191 / 255, green: 194 / 255, blue: 209 / 255, alpha: 1)
    }
    
    public var trackMinColor: UIColor {
        switch self {
        case .leftToRight:
            return UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
        case .rightToLeft:
            return UIColor(red: 247 / 255, green: 73 / 255, blue: 2 / 255, alpha: 1)
        }
    }
}
