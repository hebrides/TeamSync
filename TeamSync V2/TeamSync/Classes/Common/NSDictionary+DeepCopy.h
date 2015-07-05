//
//  NSDictionary+DeepCopy.h
//  UKSyntaxColoredDocument
//
//  Created by Uli Kusterer on Tue May 18 2004.
//  Copyright (c) 2004 M. Uli Kusterer.
//
//	This software is provided 'as-is', without any express or implied
//	warranty. In no event will the authors be held liable for any damages
//	arising from the use of this software.
//
//	Permission is granted to anyone to use this software for any purpose,
//	including commercial applications, and to alter it and redistribute it
//	freely, subject to the following restrictions:
//
//	   1. The origin of this software must not be misrepresented; you must not
//	   claim that you wrote the original software. If you use this software
//	   in a product, an acknowledgment in the product documentation would be
//	   appreciated but is not required.
//
//	   2. Altered source versions must be plainly marked as such, and must not be
//	   misrepresented as being the original software.
//
//	   3. This notice may not be removed or altered from any source
//	   distribution.
//

/*
	This category adds a method to NSDictionary that performs a deep copy of all
	instead of the usual shallow copy. For any objects inside it, it calls deepCopy
	again, unless they don't implement that selector, then a regular copy will
	be done.
*/

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import <Foundation/Foundation.h>


// -----------------------------------------------------------------------------
//	Interface:
// -----------------------------------------------------------------------------

@interface NSDictionary (UKDeepCopy)

-(NSDictionary*)  deepCopy;							// Call deepCopy on anything that understands it, copy on anything else.

-(NSMutableDictionary*)  deepMutableContainerCopy;	// Call deepMutableContainerCopy on anyone that understands it, copy on anything else.
-(NSMutableDictionary*)  deepMutableCopy;			// Call deepMutableCopy on anyone that understands it, mutableCopy on anything else.

@end
