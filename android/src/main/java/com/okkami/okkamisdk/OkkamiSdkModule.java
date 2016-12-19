package com.okkami.okkamisdk;

import android.content.Context;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

class OkkamiSdkModule extends ReactContextBaseJavaModule {
    private Context context;
    private static final String TAG = "OKKAMISDK";

    public OkkamiSdkModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.context = reactContext;
    }

    /**
     * @return the name of this module. This will be the name used to {@code require()} this module
     * from javascript.
     */
    @Override
    public String getName() {
        return "OkkamiSdk";
    }

    /**
     * Connect to room.
     * on success: connectToRoomPromise.resolve(String coreResponseJSONString )
     * on failure:  connectToRoomPromise.resolve(Throwable e)
     *
     * @param username
     * @param password
     * @param connectToRoomPromise
     */
    @ReactMethod
    public void connectToRoom(String username, String password, Promise connectToRoomPromise) {
        /*
            //example success response
            connectToRoomPromise.resolve("{}");
            //example failure response
            connectToRoomPromise.reject(new Throwable());
        */
    }

    @ReactMethod
    public void disconnectFromRoom(Promise disconnectFromRoomPromise) {

    }

    @ReactMethod
    public void register(Promise registerPromise) {

    }

    @ReactMethod
    public void connectToHub(Promise hubConnectionPromise) {

    }

    @ReactMethod
    public void disconnectFromHub(Promise hubDisconnectionPromise) {

    }

    @ReactMethod
    public void reconnectToHub(Promise hubReconnectionPromise) {

    }

    @ReactMethod
    public void sendCommandToHub(String command, Promise sendMessageToHubPromise) {

    }

    @ReactMethod
    public void downloadPresets(Promise downloadPresetsPromise) {

    }

    @ReactMethod
    public void downloadRoomInfo(Promise downloadRoomInfoPromise) {

    }

    @ReactMethod
    public void downloadFromCore(String endPoint, String getPost, String payload, Promise downloadFromCorePromise) {

    }

    @ReactMethod
    public void isHubLoggedIn(Promise hubLoggedPromise) {
        /*
            //ok
            hubLoggedPromise.resolve(true);
            //not ok!
            hubLoggedPromise.resolve(false);
        */
    }

    @ReactMethod
    public void isHubConnected(Promise hubConnectedPromise) {
        /*
            //connected
            hubConnectedPromise.resolve(true);
            //not connected
            hubConnectedPromise.resolve(false);
        */
    }


    //Events emission
    /*
    *  onHubCommand
    *            WritableMap map = Arguments.createMap();
     *            map.putString("command", "1234 2311 Default | POWER light-1 ON");
     *            this.sendEventToJs("onHubCommand", map);
    *  onHubConnected
    *             this.sendEventToJs("onHubConnected", null);
    *  onHubLoggedIn ( when IDENTIFIED is received )
    *             this.sendEventToJs("onHubLoggedIn", null);
    *  onHubDisconnected
     *            WritableMap map = Arguments.createMap();
     *            map.putString("command", "DISCONNECT_REASON");
     *            this.sendEventToJs("onHubDisconnected", map);
    * */

}
