//
//  AppServerConstants.h
//  TeamSync
//
//  Created for SMG Mobile on 3/19/12.
//  
//

typedef enum ServerRequest {
    ServerRequestSignUp,
    ServerRequestLogin,
    ServerRequestSendPlaylistToStartSession,
    ServerRequestMastersList,
    ServerRequestGetMastersPlaylist,
    //ServerRequestItunesSearch,
	ServerRequestCount
}ServerRequest;

#define ITUNES_SEARCH_PREFIX @"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsSearch?entity=song&term="
#define SEND_PLAYLIST_TO_START_SESSION @"http://66.228.33.88/api.php"

