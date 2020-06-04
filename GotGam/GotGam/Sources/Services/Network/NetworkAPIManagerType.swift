//
//  NetworkAPIManagerType.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/31.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import CoreData

enum NetworkAPIManagerError: Error{
  case sync(String)
  case syncTag(String)
  case syncTask(String)
  case download(String)
}

typealias SyncData<T> = (NSManagedObjectID, T)
