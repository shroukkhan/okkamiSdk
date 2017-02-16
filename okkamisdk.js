import {NativeModules, DeviceEventEmitter} from 'react-native';
const OkkamiSdkManager = NativeModules.OkkamiSdk;


class OkkamiSdk {
    constructor() {

    }

    /*-------------------------------------- Utility   --------------------------------------------------*/

    start() {
        return OkkamiSdkManager.start();
    }

<<<<<<< HEAD
    getSdkManager()
    {
        return OkkamiSdkManager;
    }
=======
    restart() {
        return OkkamiSdkManager.restart();
    }

    wipeUserData() {
        return OkkamiSdkManager.wipeUserData();
    }

    /*---------------------------------------------------------------------------------------------------*/
    /*-------------------------------------- Hub & Core -------------------------------------------------*/
>>>>>>> develop

    connectToRoom(loginName, password) {
        return OkkamiSdkManager.connectToRoom(loginName, password);
    }

    disconnectFromRoom() {
        return OkkamiSdkManager.disconnectFromRoom();
    }

    registerToCore() {
        return OkkamiSdkManager.registerToCore();
    }

    connectToHub() {
        return OkkamiSdkManager.connectToHub();
    }

    disconnectFromHub() {
        return OkkamiSdkManager.disconnectFromHub();
    }

    reconnectToHub() {
        return OkkamiSdkManager.reconnectToHub();
    }

    sendCommandToHub(command) {
        return OkkamiSdkManager.sendCommandToHub(command);
    }

    downloadPresets(force) {
        return OkkamiSdkManager.downloadPresets(force);
    }

    downloadRoomInfo(force) {
        return OkkamiSdkManager.downloadRoomInfo(force);
    }

    downloadFromCore(endPoint, getPost, payLoad) {
        return OkkamiSdkManager.reconnectToHub(endPoint, getPost, payLoad);
    }

    async isHubLoggedIn() {
        return await OkkamiSdkManager.isHubLoggedIn();
    }

    async isHubConnected() {
        return await OkkamiSdkManager.isHubConnected();
    }

    /*---------------------------------------------------------------------------------------------------*/

    /*-------------------------------------- SIP / PhoneCall --------------------------------------------*/
    dial(calledNumber, preferSip) {
        return OkkamiSdkManager.dial(calledNumber, preferSip);
    }

    receive() {
        return OkkamiSdkManager.receive();
    }

    hangup() {

    }


}
let okkamiSdk = new OkkamiSdk();
export default okkamiSdk;



