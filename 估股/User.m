//
//  User.m
//  UIDemo
//
//  Created by Xcode on 13-6-6.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize id;
@synthesize name;
@synthesize password;
@synthesize email;
@synthesize comId;
@synthesize newId;
@synthesize token;

- (void)dealloc
{
    [name release];
    [password release];
    [email release];
    [token release];
    [super dealloc];
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    
    if(self=[super init]){
        self.id=[aDecoder decodeObjectForKey:@"id"];
        self.name=[aDecoder decodeObjectForKey:@"name"];
        self.password=[aDecoder decodeObjectForKey:@"password"];
        self.email=[aDecoder decodeObjectForKey:@"email"];
        self.comId=[aDecoder decodeObjectForKey:@"comId"];
        self.newId=[aDecoder decodeObjectForKey:@"newId"];
        self.token=[aDecoder decodeObjectForKey:@"toke"];
    }
    
    return self;

}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:id forKey:@"id"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:password forKey:@"password"];
    [aCoder encodeObject:email forKey:@"email"];
    [aCoder encodeObject:comId forKey:@"comId"];
    [aCoder encodeObject:newId forKey:@"newId"];
    [aCoder encodeObject:token forKey:@"token"];
    
}






















@end
