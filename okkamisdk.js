import {NativeModules, DeviceEventEmitter} from 'react-native';
const OkkamiSdkManager = NativeModules.OkkamiSdk;


class OkkamiSdk {
  constructor() {

  }

  /*-------------------------------------- Utility   --------------------------------------------------*/


  /*---------------------------------------------------------------------------------------------------*/
  /*-------------------------------------- Hub & Core -------------------------------------------------*/

  lineLogin() {
    return OkkamiSdkManager.lineLogin();
  }

  executeCoreRESTCall(endPoint, getPost, payLoad, secret, token, force) {
    console.log("executeCoreRESTCall : endpoing = ", endPoint, " ",
      "getPost = ", getPost, " payload = ", payLoad, " secret = ", secret, " token = ", token, " force = ", force)
    return OkkamiSdkManager.executeCoreRESTCall(endPoint, getPost, payLoad, secret, token, force);
  }

  connectToHub(uid, secret, token, hubUrl, hubPort) {
    return OkkamiSdkManager.connectToHub(uid, secret, token, hubUrl, hubPort);
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

  /*-------------------------------------- SMOOCH --------------------------------------------*/


  /**
   * Returns the list of conversations as shown in : https://projects.invisionapp.com/share/2XAK26Y4G#/screens/223142641
   * returns a Promise which resolves to a json like this:
   *
   *  {
  "OKKAMI_CHAT": [
    {
      "unread_messages": "2",
      "icon": "http://orig15.deviantart.net/4679/f/2009/042/f/8/test_by_kaitoukat.png",
      "channel_name": "OKKAMI Concierge",
      "last_message": "We'll be happy to help your find good activities to do tonight",
      "time_since_last_message": "5 min"
    }
  ],
  "ACTIVE_CHATS": [
    {
      "unread_messages": "1",
      "icon": "http://www.vieuxmontreal.ca/wp-content/uploads/2015/07/Intercontinental_logo_233X2331.png",
      "channel_name": "Intercontinental Montreal",
      "last_message": "Your room upgrade can be purchased using the link below",
      "time_since_last_message": "1 hr 10 min"
    },
    {
      "unread_messages": "3",
      "icon": "http://orig15.deviantart.net/4679/f/2009/042/f/8/test_by_kaitoukat.png",
      "channel_name": "Aloft Bangkok",
      "last_message": "Food and wine at XYZ Bar",
      "time_since_last_message": "5 hr"
    }
  ],
  "INACTIVE_CHATS": [
    {
      "unread_messages": "0",
      "icon": "http://www.vieuxmontreal.ca/wp-content/uploads/2015/07/Intercontinental_logo_233X2331.png",
      "channel_name": "Grand President Hotel",
      "last_message": "",
      "time_since_last_message": ""
    },
    {
      "unread_messages": "0",
      "icon": "http://orig15.deviantart.net/4679/f/2009/042/f/8/test_by_kaitoukat.png",
      "channel_name": "Ambassador Bangkok",
      "last_message": "",
      "time_since_last_message": ""
    }
  ]
}
   *
   *
   * @returns {Promise}
   */
  async getConversationsList() {
    return await OkkamiSdkManager.getConversationsList();
  }

  async openChatWindow(smoochAppToken) {
    return await OkkamiSdkManager.openChatWindow(smoochAppToken);
  }



}
let okkamiSdk = new OkkamiSdk();
export default okkamiSdk;



