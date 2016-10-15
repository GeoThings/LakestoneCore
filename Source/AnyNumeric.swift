//
//  AnyNumeric
//  LakestoneRealm
//
//  Created by Taras Vozniuk on 10/13/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//
// --------------------------------------------------------
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#if !COOPER
	
public protocol AnyNumeric {}
extension Int: AnyNumeric {}
extension UInt: AnyNumeric {}
extension Int8: AnyNumeric {}
extension UInt8: AnyNumeric {}
extension Int16: AnyNumeric {}
extension UInt16: AnyNumeric {}
extension Int32: AnyNumeric {}
extension UInt32: AnyNumeric {}
extension Int64: AnyNumeric {}
extension UInt64: AnyNumeric {}
extension Float: AnyNumeric {}
extension Double: AnyNumeric {}
extension Float80: AnyNumeric {}

#endif
