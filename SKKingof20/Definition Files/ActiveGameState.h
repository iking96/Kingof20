//
//  ActiveGameState.h
//  SKKingof20
//
//  Created by Ishmael King on 4/3/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef ActiveGameState_h
#define ActiveGameState_h

typedef NS_ENUM(NSUInteger, ActiveGameState) {
    kGameStateActive  = 0,
    kGameStateParticipantQuit = 1,
    kGameStateOpponentQuit = 2,
    kGameStateDone
};

#endif /* ActiveGameState_h */
