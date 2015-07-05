//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSCommon.h
// Description		:	TSCommon class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "TSNNotificationDisplay.h"

#ifndef BEGIN_BLOCK
#define	BEGIN_BLOCK	do
#define	END_BLOCK	while(false);
#define	LEAVE_BLOCK	break;
#endif

#define TSLocalizedString(key)		[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:@"TSStringsTable"]
#define TSLoadImageResource(path)	[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:path ofType:@"png"]]

#define TSCreateImageResource(path)	[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:path ofType:@"png"]]
#define TSSafeRelease(pointer)		[pointer release]; \
pointer = nil

#define TSString(key)				[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:@"Localizable"]

#define APP_NAME                            @"TeamSync"

#define NOT_CONNECTED_TO_INTERNET           @"Internet connection failed."
#define NETWORK_ERROR                       @"Network Error: Connection failed."
#define UNKNOWN_ERROR                       @"An error has occurred while loading the details."
#define COULD_NOT_CONNECT_TO_SERVER         @"Currently there is no connectivity. Please try later when you have either Wi-Fi or cellphone signals."
#define CONNECTION_FAILED_INFO              @"Network connection failed. "
#define CONNECTION_TIMEOUT                  @"Failed to get a response due to a breakdown in network connectivity. Please retry when it is restored."
//User Defaults
#define kKeyLoggedUser						@"LoggedUserType"


#define RETINA_SCALE                        2.0F
#define RETINA_4_HEIGHT                     568.0F
#define RETINA_4_IMG_FORMAT                 @"-568h@2x"
#define RETINAPOINTS                        88
#define BGIMAGE                             @"bg.png"
#define SPLASHIMAGE                         @"Default.png"
#define MAX_CHAR_COUNT                      25

#define SONG_LIST                           @"SongList"
#define SONG_INDEX                          @"SongIndex"
#define PLAYLISTNAME                        @"PlaylistName"
#define BROADCASTED_PLAYLISTNAME            @"Broadcasted_PlaylistName"
#define MASTER_DEVICE_TIME                  @"MasterDeviceTime"
#define SONG_NAME                           @"SongNames"
#define SONGLIST_VIEW_UNIQUE_ID             @"SongListviewUniqueID"
#define SONGDETAILS_VIEW_UNIQUE_ID          @"SongDetailsviewUniqueID"
#define COMPOSER_NAME                       @"ComposerNames"
#define PLAYER_VOLUME                       @"Playervolume"
#define ENABLE_PREV_BTN                     @"EnablePrevBtn"
#define ENABLE_NEXT_BTN                     @"EnableNextBtn"
#define PLAYING_ITEM_NAME                   @"PlayingItemName"
#define PLAY_STATUS                         @"Playstatus"
#define PLAY_DURATION                       @"PlayDuration"
#define TABLE_YPOS                          @"YPosition"
#define DUMMY_INFO                          @"DummyInfo"

//Alert messages
#define MESSAGE_NOT_IMPLEMENTED             @"Not implemented."
#define MESSAGE_LOADING                     @"Loading..."
#define MESSAGE_MAX_CHARACTER_EXCEEDED      @"Maximum character length exceeded."
#define MESSAGE_INVALID_CHARACTER           @"Invalid character."

//Bonjour Communication Tags
#define COMM_MESSAGE                        @"message"
#define MASTER_NAME                         @"MasterName"
#define SELECTED_VIEWTAG                    @"SelectedView"
#define MESSAGE_DETAILS                     @"MessageDetails"

//ConnectionView Tags
#define kConnectionAcceptance               @"ConnectionAcceptance"
#define kConnectionStatus                   @"ConnectionStatus"
#define kSongListView                       @"SongListDisplay"
#define kSongDetailsView                    @"SongDetails"
#define kSongDetailsInSongList              @"SongDetailsInSongList"
#define kSongStateChanges                   @"SongStateChanges"
#define kSongVolumeChanges                  @"SongVolumeChanges"
#define kSongDurationChanges                @"SongDurationChanges"
#define kDummyInfo                          @"SongDummyInfo"
#define kSongDetailsResetSlider             @"SongDetailsResetSlider"

typedef enum
{
    USERNAME_DATA_TYPE = 0,
    PASSWORD_DATA_TYPE,
    NAME_DATA_TYPE,
    ADDRESS_DATA_TYPE,
    PHONE_DATA_TYPE,
    ZIP_DATA_TYPE,
    EMAIL_DATA_TYPE
    
} DATA_TYPE;

@interface TSCommon : NSObject
+ (void)showAlert:(NSString *)aMessage;
+ (void)hideAlert;
+ (BOOL) doesAlertViewExist;
+ (BOOL)isEmptyString:(NSString *)text;
+ (NSString *)trimWhiteSpaces:(NSString *)text;
+ (UIAlertView *)prepareProcessingAlertView:(NSString *)message;
+ (BOOL) isNetworkConnected;
+ (void)setOnLineStatus:(BOOL)status;
+ (BOOL)isOnLine;
+ (BOOL) isRetina4;
+ (UIImage *) loadImageResource:(NSString *)imageName;
+ (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (void)showProcessViewWithFrame:(CGRect)frame andMessage:(NSString*)message;
+ (void)dismissProcessView;
+ (BOOL) validateString:(NSString *)string withStringType:(DATA_TYPE)type;

@end
