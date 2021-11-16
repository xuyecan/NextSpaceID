//
//  PrivateMethod.h
//  NextSpaceID
//
//  Created by xuyecan on 2021/11/15.
//

#ifndef PrivateMethod_h
#define PrivateMethod_h

#import <Foundation/Foundation.h>

int _CGSDefaultConnection();
id CGSCopyManagedDisplaySpaces(int conn);
id CGSCopyActiveMenuBarDisplayIdentifier(int conn);

#endif /* PrivateMethod_h */
