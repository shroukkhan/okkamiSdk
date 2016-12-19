import React from 'react-native';
var {NativeModules} = React;
const OkkamiSdkManager = NativeModules.OkkamiSdk;


class OkkamiSdk {
    constructor() {
        //bleh!
    }

    connectToRoom(loginName, password) {
        return OkkamiSdkManager.connectToRoom(loginName, password);

    }

    isHubLoggedIn(){
        return OkkamiSdkManager.isHubLoggedIn();
    }

    disconnectFromRoom() {
        return OkkamiSdkManager.disconnectFromRoom(loginName, password);
    }


}
let okkamiSdk = new OkkamiSdk();
export default okkamiSdk;



