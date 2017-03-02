//
//  DWMacro.h
//  hgfd
//
//  Created by Wicky on 2017/2/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#ifndef DWMacro_h
#define DWMacro_h

#define DWIndexPath(section,row) [NSIndexPath indexPathForRow:row inSection:section]

#define NSStringFromIndexPath(idxP) [NSString stringWithFormat:@"S%ldR%ld",idxP.section,idxP.row]

#endif /* DWMacro_h */
