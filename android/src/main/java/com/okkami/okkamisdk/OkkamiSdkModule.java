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
     * Connect to room. Applicable to downloadable apps
     * on success: connectToRoomPromise.resolve(String coreResponseJSONString )
     * on failure:  connectToRoomPromise.reject(Throwable e)
     * The native module should take care of persisting the device secret and token obtained from core
     * and making sure it is secure/encrypted
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
        /* example  of calling external lib
        try{
            String x = com.okkami.MyOkkamiSDKImplementationLibrary.connectToRoom(xxxx,xxxx);
            connectToRoomPromise.resolve(x);
        }catch (Exception e)
        {
            connectToRoomPromise.reject(e);
        }
        */


    }


    /**
     * Disconnects from the current room. Applicable to downloadable apps.
     * on success: disconnectFromRoomPromise.resolve(String coreResponseJSONString )
     * on failure:  disconnectFromRoomPromise.reject(Throwable e)
     *
     * @param disconnectFromRoomPromise
     */
    @ReactMethod
    public void disconnectFromRoom(Promise disconnectFromRoomPromise) {

    }

    /**
     * Registers the device with a room using the given UID .
     * Applicable to property locked Apps
     * on success: registerPromise.resolve(String coreResponseJSONString )
     * on failure:  registerPromise.reject(Throwable e)
     * The native module should take care of persisting the device secret and token obtained from core
     * and making sure it is secure/encrypted
     *
     * @param registerPromise
     */
    @ReactMethod
    public void registerToCore(String UID,Promise registerPromise) {

    }

    /**
     * Connects to hub using the presets and attempts to login ( send IDENTIFY)
     * If Hub is already connected, reply with  hubConnectionPromise.resolve(true)
     * on success: hubConnectionPromise.resolve(true)
     * on failure:  hubConnectionPromise.reject(Throwable e)
     * Native module should also take care of the PING PONG and reconnect if PING drops
     * @param hubConnectionPromise
     */
    @ReactMethod
    public void connectToHub(Promise hubConnectionPromise) {

    }

    /**
     * Disconnects and cleans up the existing connection
     * If Hub is already connected, reply with  hubDisconnectionPromise.resolve(true) immediately
     * on success: hubDisconnectionPromise.resolve(true)
     * on failure:  hubDisconnectionPromise.reject(Throwable e)
     * @param hubDisconnectionPromise
     */
    @ReactMethod
    public void disconnectFromHub(Promise hubDisconnectionPromise) {

    }

    /**
     * Disconnects and cleans up the existing connection
     * Then attempt to connect to hub again.
     * on success ( hub has been successfully reconnected and logged in ) : hubReconnectionPromise.resolve(true)
     * on failure:  hubReconnectionPromise.reject(Throwable e)
     * @param hubReconnectionPromise
     */
    @ReactMethod
    public void reconnectToHub(Promise hubReconnectionPromise) {

    }

    /**
     * Send command to hub. a command can look like this:
     *                POWER light-1 ON
     *                2311 Default | POWER light-1 ON
     *                1234 2311 Default | POWER light-1 ON
     *
     *                The native module should fill in the missing info based on the command received
     *                such as filling in room , group , none if not provided and skip those if provied already
     * on success ( successful write ) : sendMessageToHubPromise.resolve(true)
     * on failure:  hubDisconnectionPromise.reject(Throwable e)
     * @param sendMessageToHubPromise
     */
    @ReactMethod
    public void sendCommandToHub(String command, Promise sendMessageToHubPromise) {

    }

    /**
     * downloads presets from core.
     *          If force == true, force download from core
     *          If force == false, and there is already presets from core, reply with that
     * on success : downloadPresetsPromise.resolve(coreResponseJSONString)
     * on failure:  downloadPresetsPromise.reject(Throwable e)
     * @param force
     * @param downloadPresetsPromise
     */
    @ReactMethod
    public void downloadPresets(boolean force , Promise downloadPresetsPromise) {

    }

    /**
     * Similar strategy as downloadPresets method
     * @param downloadRoomInfoPromise
     */
    @ReactMethod
    public void downloadRoomInfo(Promise downloadRoomInfoPromise) {

    }

    /**
     * The purpose of this method is to provide general purpose way to call any core endpoint.
     * Internally, the downloadPresets,downloadRoomInfo,connectToRoom all of them should use this method.
     *
     * on success : downloadFromCorePromise.resolve(coreResponseJSONString)
     * on failure:  downloadFromCorePromise.reject(Throwable e)
     * @param endPoint full core url . https://api.fingi.com/devices/v1/register
     * @param getPost
     * @param payload
     * @param downloadFromCorePromise
     */
    @ReactMethod
    public void downloadFromCore(String endPoint, String getPost, String payload, Promise downloadFromCorePromise) {

    }

    /**
     * if hub is currently connected + logged in :
     *      hubLoggedPromise.resolve(true);
     * else
     *       hubLoggedPromise.resolve(false);
     * @param hubLoggedPromise
     */
    @ReactMethod
    public void isHubLoggedIn(Promise hubLoggedPromise) {
        /*
            //ok
            hubLoggedPromise.resolve(true);
            //not ok!
            hubLoggedPromise.resolve(false);
        */
    }

    /**
     * if hub is currently connected ( regardless of logged in ) :
     *      hubConnectedPromise.resolve(true);
     * else
     *       hubConnectedPromise.resolve(false);
     * @param hubConnectedPromise
     */
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
