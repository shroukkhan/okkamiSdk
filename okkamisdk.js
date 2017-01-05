import React from 'react-native';
var {NativeModules} = React;
const OkkamiSdkManager = NativeModules.OkkamiSdk;


class OkkamiSdk {
    constructor() {
        //bleh!
    }

    getSdkManager()
    {
        return OkkamiSdkManager;
    }

    connectToRoom(loginName, password) {
        return OkkamiSdkManager.connectToRoom(loginName, password);
    }

    disconnectFromRoom() {
        return OkkamiSdkManager.disconnectFromRoom();
    }

    registerToCore(){
        return OkkamiSdkManager.registerToCore();
    }

    connectToHub(){
        return OkkamiSdkManager.connectToHub();
    }

    disconnectFromHub(){
        return OkkamiSdkManager.disconnectFromHub();
    }

    reconnectToHub(){
        return OkkamiSdkManager.reconnectToHub();
    }

    sendCommandToHub(command){
        return OkkamiSdkManager.sendCommandToHub(command);
    }

    downloadPresets(){
        return OkkamiSdkManager.downloadPresets();
    }

    downloadRoomInfo(){
        return OkkamiSdkManager.downloadRoomInfo();
    }

    downloadFromCore(endPoint,getPost,payLoad){
        return OkkamiSdkManager.reconnectToHub(endPoint,getPost,payLoad);
    }

    async isHubLoggedIn(){
        return await OkkamiSdkManager.isHubLoggedIn();
    }

    async isHubConnected(){
        return await OkkamiSdkManager.isHubConnected();
    }



}
let okkamiSdk = new OkkamiSdk();
export default okkamiSdk;



