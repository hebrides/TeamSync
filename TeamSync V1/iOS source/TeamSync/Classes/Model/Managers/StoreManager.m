//
//  StoreManager.m
//  App_iphoneim
//
//  Created for SMG Mobile on 12/22/11.
//  
//

#import "StoreManager.h"
#import "Foundation+Common.h"

#import "DataManager.h"
#import "DataProvider.h"
#import "AppLogicManager.h"
#import "Common.h"

@interface StoreManager(Private)

- (NSMutableDictionary*)removeEmptyFields:(NSDictionary*)dic;
- (void)removeAllObjectsForKey:(NSString*)key;
- (void)removeObjectsFrom:(NSSet*)set;

@end

@implementation StoreManager

#pragma mark -
#pragma mark Singleton method
+ (StoreManager*) sharedInstance {
	static StoreManager *sharedStoreManager = nil;
	if (sharedStoreManager == nil) {
		sharedStoreManager = [[StoreManager alloc] init];
	}
    return sharedStoreManager;
}

#pragma mark -
#pragma mark Helper methods

- (NSMutableDictionary*)removeEmptyFields:(NSDictionary*)dic {
	NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
	NSArray *keys = [newDic allKeys];
	for (int i = [keys count] - 1; i >= 0; i--) {
		NSString *key = [keys objectAtIndex:i];
		if ([[newDic objectForKey:key] isKindOfClass:[NSNull class]]) {
			[newDic removeObjectForKey:key];
		}
	}
	return newDic;
}

- (void)removeAllObjectsForKey:(NSString*)key {
	NSArray *objects = [[DataManager sharedInstance] getObjectsForName:key sortDescriptorsKey:nil];
	for (int i = [objects count] - 1; i >= 0; i--) {
		[[DataManager sharedInstance].managedObjectContext deleteObject:[objects objectAtIndex:i]];
	}
	[[DataManager sharedInstance] save];
	
}

- (void)removeObjectsFrom:(NSSet*)set {
    NSArray *objects = [set allObjects];
	for (int i = [objects count] - 1; i >= 0; i--) {
		[[DataManager sharedInstance].managedObjectContext deleteObject:[objects objectAtIndex:i]];
	}
}

- (void)deleteCoreDataObject:(NSManagedObject*)coreDataObject {
	[[DataManager sharedInstance].managedObjectContext deleteObject:coreDataObject];
    
	[[DataManager sharedInstance] save];
}

- (NSDate*)dateWithFormat:(NSString*)format fromString:(NSString*)text{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:format];
	NSDate *resultDate = [dateFormatter dateFromString:text];
	return resultDate;
}

- (NSDate*)dateFromString:(NSString*)string forKey:(NSString*)key class:(Class)class {
    NSDate *date = nil;

    if ([key isEqualToString:@"pubDate"]) {
        
        NSLocale *loc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:loc];
        [dateFormatter setDateFormat:@"ccc, dd MMM yyyy HH:mm:ss"];
        NSDate *resultDate = [dateFormatter dateFromString:string];
        date = resultDate;

    } else if ([key isEqualToString:@"eventdate"] || [key isEqualToString:@"track_ReleaseDate"]) {
        date = [self dateWithFormat:@"dd/MM/yyyy" fromString:string];
        
    } else if ([key isEqualToString:@"start_time"] || [key isEqualToString:@"end_time"]) {
        string = [string stringByReplacingOccurrencesOfString:@" AM" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@" PM" withString:@""];
        date = [self dateWithFormat:@"MM-dd-yyyy HH:mm ss" fromString:string];
        
    } else if ([key isEqualToString:@"releaseDate"]) {
        string = [string stringByReplacingOccurrencesOfString:@"Z" withString:@""];
		string = [string stringByReplacingOccurrencesOfString:@"T" withString:@""];
        date = [self dateWithFormat:@"yyyy-MM-ddHH:mm:ss" fromString:string];		
	}
    else if ([key isEqualToString:@"release_date"]) {
        string = [string stringByReplacingOccurrencesOfString:@"Z" withString:@""];
		string = [string stringByReplacingOccurrencesOfString:@"T" withString:@""];
        date = [self dateWithFormat:@"yyyy-MM-dd HH:mm:ss  ssss" fromString:string];		
	}
    
    return date;
}


- (NSManagedObject*)updateObject:(NSManagedObject*)object withInfo:(NSDictionary*)info {
    if ([info isKindOfClass:[NSDictionary class]] == NO) {
        NSLog(@"ERROR!!! Incorrect savind for class: [%@] with info [%@]", NSStringFromClass([object class]), info);
        return object;
    }
    NSArray *keys = [info allKeys];
    for (NSString *key in keys) {
        if ([key length] == 0) {
            continue;
        }
        NSString *firstLowChar = [[key substringToIndex:1] lowercaseString];
        NSString *propertyKey = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstLowChar];
        if ([[key lowercaseString] isEqualToString:@"description"]) {
            propertyKey = @"desc";
        }
        
        NSString *value = [info objectForKey:key];
        
        NSEntityDescription *desc = [object entity];
        NSAttributeDescription *atrDesc = [[desc attributesByName] objectForKey:propertyKey];
        
        if (atrDesc == nil) {
            continue;
        }
        
        if ([[atrDesc attributeValueClassName] isEqualToString:@"NSNumber"]) {
			if ([value isKindOfClass:[NSNumber class]]) {
				[object setValue:value forKey:propertyKey];
			} else if ([value isKindOfClass:[NSString class]]) {
				if ([value rangeOfString:@"."].location == NSNotFound) {
					int num = [value intValue];
						[object setValue:[NSNumber numberWithInt:num] forKey:propertyKey];
				} else {
					float num = [value floatValue];
					[object setValue:[NSNumber numberWithFloat:num] forKey:propertyKey];
				}
			} else {
				NSLog(@"ERROR inserting value for key: [%@] into object: [%@]", 
					  propertyKey, NSStringFromClass([object class]));
			}

        } else if ([[atrDesc attributeValueClassName] isEqualToString:@"NSDate"]) {
            NSDate *date = [self dateFromString:value forKey:key class:[object class]];
            [object setValue:date forKey:propertyKey];
        } else {
            [object setValue:value forKey:propertyKey];
        }
    }    
    return object;
}


- (void)defaultUpdateForObjectsNamed:(NSString*)name items:(NSArray*)items removeOld:(BOOL)removeOld {
    if (removeOld) {
        [self removeAllObjectsForKey:name];
    }
    for (NSDictionary *itemInfo in items) {
        NSManagedObject *item = [NSEntityDescription insertNewObjectForEntityForName:name 
                                                              inManagedObjectContext:[DataManager sharedInstance].managedObjectContext];		
        [self updateObject:item withInfo:itemInfo];
    }
    
}


#pragma Custom methods

- (User*)createNewUserWith:(NSString*)username {
    User *user = [NSEntityDescription insertNewObjectForEntityForName:kCDOUser 
                                               inManagedObjectContext:[DataManager sharedInstance].managedObjectContext];		
    user.username = username;
    return user;
}

- (Playlist*)createPlaylistWithTitle:(NSString*)title deacription:(NSString*)desc {
    Playlist *playlist = [NSEntityDescription insertNewObjectForEntityForName:kCDOPlaylist 
                                                       inManagedObjectContext:[DataManager sharedInstance].managedObjectContext];		
    playlist.title = title;
    playlist.desc = desc;
    playlist.user = [DataProvider currentActiveUser];
    playlist.imageUrl = @"noimage";
    playlist.isIPodOwner = [NSNumber numberWithBool:NO];
    
    return playlist;
}
/*
- (void)updateDetectedItunesTracksWith:(NSArray*)array {

	[self removeDetecredTracks];
    
	int count = [array count];
    
	for (int i = 0; i < count; i++) {
        
        NSDictionary *itemInfo = [array objectAtIndex:i];
                
        if ([[itemInfo objectForKey:@"kind"] isEqual:@"song"] == NO) {
            continue;
        }
            
        Track *track = [NSEntityDescription insertNewObjectForEntityForName:kCDOTrack
                                                     inManagedObjectContext:[DataManager sharedInstance].managedObjectContext];
        
        track.order = [NSNumber numberWithInt:i];
        
        int millis = [[itemInfo objectForKey:@"trackTimeMillis"] intValue];
        float length = (millis / 1000.0) / 60.0;
        track.length = [NSNumber numberWithFloat:length];
        
        
        track.audioUrl = [itemInfo objectForKey:@"previewUrl"];
        track.title = [itemInfo objectForKey:@"trackName"];
        track.artistName = [itemInfo objectForKey:@"artistName"];
        track.imageUrl = [itemInfo objectForKey:@"artworkUrl60"];
        track.genreName = [itemInfo objectForKey:@"primaryGenreName"];
        track.itunesid = [NSNumber numberWithInt:[[itemInfo objectForKey:@"trackId"] intValue]];
        track.releaseDate = [self dateFromString:[itemInfo objectForKey:@"releaseDate"] 
                                          forKey:@"releaseDate" 
                                           class:[Track class]];
    }
}
*/
- (void)updateDetectedTracksWith:(NSArray*)tracks {
    
	[self removeDetecredTracks];
    
    for (int i = 0; i < [tracks count]; i++) {
        MPMediaItem *mediaItem = [tracks objectAtIndex:i];
        
        Track *track = [self createTrackWithIPodTrack:mediaItem];        
        track.order = [NSNumber numberWithInt:i];
    }
}

- (void)removeDetecredTracks {
    NSArray *tracks = [DataProvider allDetectedTracks];
    for (int i = [tracks count] - 1; i >= 0; i--) {
        NSManagedObject *track = [tracks objectAtIndex:i];
        [track deleteObject];
    }
}

- (void)updateMastersListWith:(NSArray*)array {
    
    //NSLog(@"array: %@", array);
    [self removeAllObjectsForKey:kCDOMaster];
    int count = [array count];
    
	for (int i = 0; i < count; i++) {
        
        NSDictionary *itemInfo = [array objectAtIndex:i];
        
        
        Master *master = [NSEntityDescription insertNewObjectForEntityForName:kCDOMaster
                                                     inManagedObjectContext:[DataManager sharedInstance].managedObjectContext];
        
        [self updateObject:master withInfo:itemInfo];
        
        NSString *ip = [itemInfo objectForKey:@"server_url"];
        if ([ip rangeOfString:@"http://"].location == 0) {
            ip = [ip substringFromIndex:7];
        }
        master.ip = ip;
    }
    
}

- (void)updatePlaylist:(NSDictionary*)playlistInfo forMaster:(Master*)master {
        
    master.playlist = nil;
    
    Playlist *playlist = [self createPlaylistWithTitle:[playlistInfo objectForKey:@"title"] 
                                           deacription:[playlistInfo objectForKey:@"description"]];
    playlist.order = [NSNumber numberWithInt:[[playlistInfo objectForKey:@"id"] intValue]];
    master.playlist = playlist;
    playlist.master = master;
    
    NSArray *tracksInfo = [playlistInfo objectForKey:@"tracks"];
    
    for (int i = 0; i < [tracksInfo count]; i++) {
        NSDictionary *trackInfo = [tracksInfo objectAtIndex:i];
        Track *track = [NSEntityDescription insertNewObjectForEntityForName:kCDOTrack
                                                     inManagedObjectContext:[DataManager sharedInstance].managedObjectContext];
        
        track.order = [NSNumber numberWithInt:i];
        
        track.length = [NSNumber numberWithFloat:[[trackInfo objectForKey:@"length"] floatValue]];
        
        
        track.audioUrl = [trackInfo objectForKey:@"audio_url"];
        track.title = [trackInfo objectForKey:@"title"];
        track.artistName = [trackInfo objectForKey:@"artist_name"];
        track.imageUrl = [trackInfo objectForKey:@"image_url"];
        NSString *genre = [trackInfo objectForKey:@"genre_name"];
        if ([genre isKindOfClass:[NSString class]]) {
            track.genreName = genre;
        }
        
        track.itunesid = [NSNumber numberWithInt:[[trackInfo objectForKey:@"itunesid"] intValue]];
        track.releaseDate = [self dateFromString:[trackInfo objectForKey:@"release_date"] 
                                          forKey:@"release_date" 
                                           class:[Track class]];

        track.playlist = playlist;
        [playlist addTracksObject:track];
    }
}




#pragma mark - iPod

- (Track*)createTrackWithIPodTrack:(MPMediaItem*)mediaItem {    
    Track *track = [NSEntityDescription insertNewObjectForEntityForName:kCDOTrack
                                                 inManagedObjectContext:[DataManager sharedInstance].managedObjectContext];
    
    NSNumber *length = [mediaItem valueForKey:MPMediaItemPropertyPlaybackDuration];
    if ([length isKindOfClass:[NSNumber class]]) {
        track.length = length;
    } else {
        track.length = [NSNumber numberWithInt:0];
    }
    
    NSString *title = [mediaItem valueForKey:MPMediaItemPropertyTitle];
    if ([title isKindOfClass:[NSString class]]) {
        track.title = title;
    } else {
        track.title = @"Unknown track";
    }

    NSString *artistName = [mediaItem valueForKey:MPMediaItemPropertyArtist];
    if ([artistName isKindOfClass:[NSString class]]) {
        track.artistName = artistName;
    } else {
        track.artistName = @"Unknown artist";
    }
    
    NSString *genreName = [mediaItem valueForKey:MPMediaItemPropertyGenre];
    if ([genreName isKindOfClass:[NSString class]]) {
        track.genreName = genreName;
    } else {
        track.genreName = @"Unknown genre";
    }

    NSDate *releaseDate = [mediaItem valueForKey:MPMediaItemPropertyReleaseDate];
    if ([releaseDate isKindOfClass:[NSDate class]]) {
        track.releaseDate = releaseDate;
    } else {
        track.releaseDate = [NSDate date];
    }
    
    NSURL *url = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    if ([url isKindOfClass:[NSURL class]]) {
        track.audioUrl = [url absoluteString];
    } else {
        track.audioUrl = @"";
    }
    
    track.imageUrl = @"hasn't image";
    
    return track;
}

- (void)updateIPodsPlaylists {
    
    NSArray *oldPlaylists = [DataProvider allPlaylistsFromIPod];
    for (Playlist *oldPl in oldPlaylists) {
        [oldPl deleteObject];
    }
//    for (int pl = [oldPlaylists count] - 1; pl >= 0; pl--) {
//        pl
//    }
    
    
    MPMediaQuery *playlistsQuery = [MPMediaQuery playlistsQuery];
    NSArray *playlists = [playlistsQuery collections];
    
    for (int p = 0; p < [playlists count]; p++) {
        MPMediaPlaylist *playlistIPod = [playlists objectAtIndex:p];
        
        NSNumber *value = [playlistIPod valueForProperty:MPMediaPlaylistPropertyPlaylistAttributes];
        BOOL isPurchased = ! [value boolValue];

        NSArray *tracks = [playlistIPod items];
        
        if (isPurchased || [tracks count] == 0) {
            continue;
        }

        
        NSString *plTitle = [playlistIPod valueForProperty:MPMediaPlaylistPropertyName];
        
        Playlist *playlist = [self createPlaylistWithTitle:plTitle 
                                               deacription:@"iPod"];
        playlist.order = [NSNumber numberWithInt:p];
        playlist.isIPodOwner = [NSNumber numberWithBool:YES];
        
        for (int i = 0; i < [tracks count]; i++) {
            MPMediaItem *mediaItem = [tracks objectAtIndex:i];
            
            Track *track = [self createTrackWithIPodTrack:mediaItem];

            track.playlist = playlist;
            [playlist addTracksObject:track];
            track.order = [NSNumber numberWithInt:i];
        }
    }

}


@end
