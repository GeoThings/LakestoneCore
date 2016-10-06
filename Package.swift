//
//  Package.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/20/16.
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



import PackageDescription

#if os(Linux)

let package = Package(
    name: "LakestoneCore",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/GeoThings/Perfect-CURL.git", majorVersion: 0, minor: 100),
        .Package(url: "https://github.com/GeoThings/Perfect-Thread.git", majorVersion: 0, minor: 100)
    ]
)

#else

let package = Package(
    name: "LakestoneCore",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/GeoThings/Perfect-CURL.git", majorVersion: 0, minor: 100),
        .Package(url: "https://github.com/GeoThings/Perfect-Thread.git", majorVersion: 0, minor: 100)
    ]
)
    
#endif
