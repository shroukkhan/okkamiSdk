import {NativeModules, DeviceEventEmitter} from 'react-native';
const OkkamiSdkManager = NativeModules.OkkamiSdk;


class OkkamiSdk {
    constructor() {

    }

    /*-------------------------------------- Utility   --------------------------------------------------*/



    /*---------------------------------------------------------------------------------------------------*/
    /*-------------------------------------- Hub & Core -------------------------------------------------*/


    executeCoreRESTCall (endPoint,getPost,payLoad,secret,token) {
        return OkkamiSdkManager.executeCoreRESTCall(endPoint,getPost,payLoad,secret,token);
    }

    connectToHub(secret,token) {
        return OkkamiSdkManager.connectToHub(secret,token);
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

    async isHubLoggedIn() {
        return await OkkamiSdkManager.isHubLoggedIn();
    }

    async isHubConnected() {
        return await OkkamiSdkManager.isHubConnected();
    }

    /*---------------------------------------------------------------------------------------------------*/

    /*-------------------------------------- SIP / PhoneCall --------------------------------------------*/



}
let okkamiSdk = new OkkamiSdk();
export default okkamiSdk;



