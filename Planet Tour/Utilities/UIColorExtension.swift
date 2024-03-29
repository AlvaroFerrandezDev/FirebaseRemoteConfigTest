/* UIColorExtension.swift
 * HEXColor
 *
 * Created by R0CKSTAR on 6/13/14.
 * Copyright (c) 2014 P.D.Q. All rights reserved.
 *
 * The MIT License (MIT)
 * Copyright (c) 2014 R0CKSTAR
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software
 * and associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
 * BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

import UIKit

/**
 MissingHashMarkAsPrefix:   "Invalid RGB string, missing '#' as prefix"
 UnableToScanHexValue:      "Scan hex error"
 MismatchedHexStringLength: "Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8"
 */
public enum UIColorInputError: Error {
  case missingHashMarkAsPrefix,
       unableToScanHexValue,
       mismatchedHexStringLength,
       unableToOutputHexStringForWideDisplayColor
}

public extension UIColor {
  /**
   The shorthand three-digit hexadecimal representation of color.
   #RGB defines to the color #RRGGBB.

   - parameter hex3: Three-digit hexadecimal value.
   - parameter alpha: 0.0 - 1.0. The default is 1.0.
   */
  convenience init(hex3: UInt16, alpha: CGFloat = 1) {
    let divisor = CGFloat(15)
    let red = CGFloat((hex3 & 0xF00) >> 8) / divisor
    let green = CGFloat((hex3 & 0x0F0) >> 4) / divisor
    let blue = CGFloat(hex3 & 0x00F) / divisor
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  /**
   The shorthand four-digit hexadecimal representation of color with alpha.
   #RGBA defines to the color #RRGGBBAA.

   - parameter hex4: Four-digit hexadecimal value.
   */
  convenience init(hex4: UInt16) {
    let divisor = CGFloat(15)
    let red = CGFloat((hex4 & 0xF000) >> 12) / divisor
    let green = CGFloat((hex4 & 0x0F00) >> 8) / divisor
    let blue = CGFloat((hex4 & 0x00F0) >> 4) / divisor
    let alpha = CGFloat(hex4 & 0x000F) / divisor
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  /**
   The six-digit hexadecimal representation of color of the form #RRGGBB.

   - parameter hex6: Six-digit hexadecimal value.
   */
  convenience init(hex6: UInt32, alpha: CGFloat = 1) {
    let divisor = CGFloat(255)
    let red = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
    let green = CGFloat((hex6 & 0x00FF00) >> 8) / divisor
    let blue = CGFloat(hex6 & 0x0000FF) / divisor
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  /**
   The six-digit hexadecimal representation of color with alpha of the form #RRGGBBAA.

   - parameter hex8: Eight-digit hexadecimal value.
   */
  convenience init(hex8: UInt32) {
    let divisor = CGFloat(255)
    let red = CGFloat((hex8 & 0xFF00_0000) >> 24) / divisor
    let green = CGFloat((hex8 & 0x00FF_0000) >> 16) / divisor
    let blue = CGFloat((hex8 & 0x0000_FF00) >> 8) / divisor
    let alpha = CGFloat(hex8 & 0x0000_00FF) / divisor
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  /**
   The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB, throws error.

   - parameter rgba: String value.
   */
  convenience init(rgba_throws rgba: String) throws {
    guard rgba.hasPrefix("#") else {
      throw UIColorInputError.missingHashMarkAsPrefix
    }

    let hexString = String(rgba[String.Index(encodedOffset: 1)...])
    var hexValue: UInt32 = 0

    guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
      throw UIColorInputError.unableToScanHexValue
    }

    switch hexString.count {
    case 3:
      self.init(hex3: UInt16(hexValue))
    case 4:
      self.init(hex4: UInt16(hexValue))
    case 6:
      self.init(hex6: hexValue)
    case 8:
      self.init(hex8: hexValue)
    default:
      throw UIColorInputError.mismatchedHexStringLength
    }
  }

  /**
   The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB, fails to default color.

   - parameter rgba: String value.
   */
  convenience init(_ rgba: String, defaultColor: UIColor = UIColor.clear) {
    guard let color = try? UIColor(rgba_throws: rgba) else {
      self.init(cgColor: defaultColor.cgColor)
      return
    }
    self.init(cgColor: color.cgColor)
  }

  /**
   Hex string of a UIColor instance, throws error.

   - parameter includeAlpha: Whether the alpha should be included.
   */
  func hexStringThrows(_ includeAlpha: Bool = true) throws -> String {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    getRed(&r, green: &g, blue: &b, alpha: &a)

    guard r >= 0, r <= 1, g >= 0, g <= 1, b >= 0, b <= 1 else {
      throw UIColorInputError.unableToOutputHexStringForWideDisplayColor
    }

    if includeAlpha {
      return String(format: "#%02X%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
    } else {
      return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
  }

  /**
   Hex string of a UIColor instance, fails to empty string.

   - parameter includeAlpha: Whether the alpha should be included.
   */
  func hexString(_ includeAlpha: Bool = true) -> String {
    guard let hexString = try? hexStringThrows(includeAlpha) else {
      return ""
    }
    return hexString
  }
}

public extension String {
  /**
   Convert argb string to rgba string.
   */
  func argb2rgba() -> String? {
    guard hasPrefix("#") else {
      return nil
    }

    let hexString = String(self[index(startIndex, offsetBy: 1)...])
    switch hexString.count {
    case 4:
      return "#\(String(hexString[index(startIndex, offsetBy: 1)...]))\(String(hexString[..<index(startIndex, offsetBy: 1)]))"
    case 8:
      return "#\(String(hexString[index(startIndex, offsetBy: 2)...]))\(String(hexString[..<index(startIndex, offsetBy: 2)]))"
    default:
      return nil
    }
  }
}
