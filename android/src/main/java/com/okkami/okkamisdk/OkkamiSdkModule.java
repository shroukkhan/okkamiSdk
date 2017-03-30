package com.okkami.okkamisdk;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

import com.facebook.react.bridge.ReadableArray;
import com.linecorp.linesdk.auth.LineLoginApi;
import com.linecorp.linesdk.auth.LineLoginResult;
import com.okkami.android.sdk.SDK;
import com.okkami.android.sdk.model.BaseAuthentication;
import com.okkami.android.sdk.model.CompanyAuth;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.URL;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Timer;

import io.reactivex.Observer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.smooch.core.InitializationStatus;
import io.smooch.core.Message;
import io.smooch.core.Smooch;
import io.smooch.core.SmoochConnectionStatus;
import io.smooch.ui.ConversationActivity;
import okhttp3.ResponseBody;
import retrofit2.Response;

class OkkamiSdkModule extends ReactContextBaseJavaModule {
    private Application app;
    private Context context;
    private static final String TAG = "OKKAMISDK";
    private static final int LINE_LOGIN_REQUEST_CODE = 10;
    private SDK okkamiSdk;
    private Promise lineLoginPromise = null;

    private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {

        @Override
        public void onActivityResult(Activity activity, int requestCode, int resultCode,
                Intent data) {
            super.onActivityResult(activity, requestCode, resultCode, data);
            Log.d(TAG, "onActivityResult: "+requestCode);
            if (requestCode != LINE_LOGIN_REQUEST_CODE) return;
            LineLoginResult result = LineLoginApi.getLoginResultFromIntent(data);
            String accessToken = result.getLineCredential().getAccessToken().getAccessToken();

            switch (result.getResponseCode()) {

                case SUCCESS:
                    // Login is successful
                    // Do something...
                    JSONObject jObj = new JSONObject();
                    try {
                        jObj.put("accessToken", accessToken);
                        jObj.put("user_id", result.getLineProfile().getUserId());
                        jObj.put("display_name", result.getLineProfile().getDisplayName());
                        jObj.put("picture", result.getLineProfile().getPictureUrl().toString());
                    } catch (JSONException e) {
                        e.printStackTrace();
                        lineLoginPromise.reject("error", e.getMessage());
                    }

                    lineLoginPromise.resolve(jObj.toString());
                    break;
                case CANCEL:
                    // Login was cancelled by the user
                    // Do something...
                    lineLoginPromise.reject("error", "error");
                    break;
                default:
                    // Login was cancelled by the user
                    // Do something...
            }
        }

    };

    public OkkamiSdkModule(ReactApplicationContext reactContext, Application app) {
        super(reactContext);
        this.context = reactContext;
        Log.d(TAG, "OkkamiSdkModule: "+app);
        reactContext.addActivityEventListener(mActivityEventListener);
        okkamiSdk = new SDK().init(reactContext, "https://app.develop.okkami.com"); // TODO : how do we pass the URL dynamically from react??
        this.app = app;
    }

    /**
     * @return the name of this module. This will be the name used to {@code require()} this module
     * from javascript.
     */
    @Override
    public String getName() {
        return "OkkamiSdk";
    }


     /*-------------------------------------- Utility   --------------------------------------------------*/

    @ReactMethod
    public void lineLogin(Promise lineLoginPromise) {
        this.lineLoginPromise = lineLoginPromise;
        Intent loginIntent = LineLoginApi.getLoginIntent(this.context, "1499319131");
        getCurrentActivity().startActivityForResult(loginIntent, LINE_LOGIN_REQUEST_CODE);
    }

    /**
     * Set new the Smooch app token to Okkami SDK for switching channel to let user talk to different hotels
     * @param appToken - an app token provided by Smooch
     */
    @ReactMethod
     public void setSmoochAppToken(String appToken){
        okkamiSdk.setSmoochAppToken(appToken);
     }

     @ReactMethod
     public void showSmoochUI(){
         okkamiSdk.showSmoochUI();
     }


     /*---------------------------Core------------------------------------------------------------------------*/

    /**
     * The purpose of this method is to provide general purpose way to call any core endpoint.
     * Internally, the downloadPresets,downloadRoomInfo,connectToRoom all of them should use this method.
     * <p>
     * on success : downloadFromCorePromise.resolve(coreResponseJSONString)
     * on failure:  downloadFromCorePromise.reject(Throwable e)
     *
     * @param endPoint full core url . https://api.fingi.com/devices/v1/register
     * @param getPost  "GET" or "POST"
     * @param payload  JSON encoded payload if it is POST
     */
    @ReactMethod
    public void executeCoreRESTCall(String endPoint, String getPost, String payload, String secret, String token, Boolean force, final Promise downloadFromCorePromise) {
        try {
//            URL u = new URL(endPoint);
//            String path = u.getPath();
            BaseAuthentication b = new CompanyAuth(token, secret);
            if (getPost.compareTo("POST") == 0) {

                okkamiSdk.getBACKEND_SERVICE_MODULE().doCorePostCall(endPoint, "POST", payload, b)
                        .subscribeOn(io.reactivex.schedulers.Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(new Observer<Response<ResponseBody>>() {
                            @Override
                            public void onSubscribe(Disposable d) {
                                System.out.println("Disposable method.");
                            }

                            @Override
                            public void onNext(Response<ResponseBody> value) {
                                try {
                                    if (value.raw().code() >= 400 || value.body() == null){
                                        downloadFromCorePromise.reject(value.raw().code()+"",value.raw().message());
                                    } else {
                                        String x = value.body().string();
                                        downloadFromCorePromise.resolve(x);
                                    }
                                } catch (Exception e) {
                                    downloadFromCorePromise.reject(e);
                                    // e.printStackTrace();
                                }
                            }

                            @Override
                            public void onError(Throwable e) {
                                downloadFromCorePromise.reject(e);
                            }

                            @Override
                            public void onComplete() {


                                // Nothing for now.
                            }
                        });
            } else if (getPost.compareTo("GET") == 0){
                okkamiSdk.getBACKEND_SERVICE_MODULE().doCoreGetCall(endPoint, "GET", payload, b)
                        .subscribeOn(io.reactivex.schedulers.Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(new Observer<Response<ResponseBody>>() {
                            @Override
                            public void onSubscribe(Disposable d) {
                                System.out.println("Disposable method.");
                            }

                            @Override
                            public void onNext(Response<ResponseBody> value) {
                                try {
                                    String x = value.body().string();
                                    downloadFromCorePromise.resolve(x);
                                } catch (Exception e) {
                                    downloadFromCorePromise.reject(e);
                                    // e.printStackTrace();
                                }
                            }

                            @Override
                            public void onError(Throwable e) {
                                downloadFromCorePromise.reject(e);
                            }

                            @Override
                            public void onComplete() {



                                // Nothing for now.
                            }
                        });
            }
        } catch (Exception e) {
            downloadFromCorePromise.reject(e);


        }

    }

    /*-------------------------------------- Hub -------------------------------------------------*/


    /**
     * Connects to hub using the presets and attempts to login ( send IDENTIFY)
     * If Hub is already connected, reply with  hubConnectionPromise.resolve(true)
     * on success: hubConnectionPromise.resolve(true)
     * on failure:  hubConnectionPromise.reject(Throwable e)
     * Native module should also take care of the PING PONG and reconnect if PING drops
     *
     * @param secrect              secrect obtained from core
     * @param token                token obtained from core
     * @param hubConnectionPromise
     */
    @ReactMethod
    public void connectToHub(String secrect, String token, Promise hubConnectionPromise) {

    }

    /**
     * Disconnects and cleans up the existing connection
     * If Hub is already connected, reply with  hubDisconnectionPromise.resolve(true) immediately
     * on success: hubDisconnectionPromise.resolve(true)
     * on failure:  hubDisconnectionPromise.reject(Throwable e)
     *
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
     *
     * @param hubReconnectionPromise
     */
    @ReactMethod
    public void reconnectToHub(Promise hubReconnectionPromise) {

    }

    /**
     * Send command to hub. a command can look like this:
     * POWER light-1 ON
     * 2311 Default | POWER light-1 ON
     * 1234 2311 Default | POWER light-1 ON
     * <p>
     * The native module should fill in the missing info based on the command received
     * such as filling in room , group , none if not provided and skip those if provied already
     * on success ( successful write ) : sendMessageToHubPromise.resolve(true)
     * on failure:  hubDisconnectionPromise.reject(Throwable e)
     *
     * @param sendMessageToHubPromise
     */
    @ReactMethod
    public void sendCommandToHub(String command, Promise sendMessageToHubPromise) {

    }


    /**
     * if hub is currently connected + logged in :
     * hubLoggedPromise.resolve(true);
     * else
     * hubLoggedPromise.resolve(false);
     *
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
     * hubConnectedPromise.resolve(true);
     * else
     * hubConnectedPromise.resolve(false);
     *
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

    /*---------------------------------------------------------------------------------------------------*/


    /**
     * Returns the list of conversations as shown in : https://projects.invisionapp.com/share/2XAK26Y4G#/screens/223142641
     * returns a Promise which resolves to a json like this:
     * <p>
     * {
     * "OKKAMI_CHAT": [
     * {
     * "unread_messages": "2",
     * "icon": "http://orig15.deviantart.net/4679/f/2009/042/f/8/test_by_kaitoukat.png",
     * "channel_name": "OKKAMI Concierge",
     * "last_message": "We'll be happy to help your find good activities to do tonight",
     * "time_since_last_message": "5 min"
     * }
     * ],
     * "ACTIVE_CHATS": [
     * {
     * "unread_messages": "1",
     * "icon": "http://www.vieuxmontreal.ca/wp-content/uploads/2015/07/Intercontinental_logo_233X2331.png",
     * "channel_name": "Intercontinental Montreal",
     * "last_message": "Your room upgrade can be purchased using the link below",
     * "time_since_last_message": "1 hr 10 min"
     * },
     * {
     * "unread_messages": "3",
     * "icon": "http://orig15.deviantart.net/4679/f/2009/042/f/8/test_by_kaitoukat.png",
     * "channel_name": "Aloft Bangkok",
     * "last_message": "Food and wine at XYZ Bar",
     * "time_since_last_message": "5 hr"
     * }
     * ],
     * "INACTIVE_CHATS": [
     * {
     * "unread_messages": "0",
     * "icon": "http://www.vieuxmontreal.ca/wp-content/uploads/2015/07/Intercontinental_logo_233X2331.png",
     * "channel_name": "Grand President Hotel",
     * "last_message": "",
     * "time_since_last_message": ""
     * },
     * {
     * "unread_messages": "0",
     * "icon": "http://orig15.deviantart.net/4679/f/2009/042/f/8/test_by_kaitoukat.png",
     * "channel_name": "Ambassador Bangkok",
     * "last_message": "",
     * "time_since_last_message": ""
     * }
     * ]
     * }
     *
     * @param getConversationListPromise
     */
    @ReactMethod
    public void getConversationsList(ReadableArray smoochAllAppTokenArray, Promise getConversationListPromise) {
//        Smooch.getConversation().sendMessage(new Message("Hello WWorld!"));
        try {
            final String ALL_CHAT_STR = "ALL_CHAT";
            final String OKKAMI_CHAT_STR = "OKKAMI_CHAT";
            final String ACTIVE_CHATS_STR = "ACTIVE_CHATS";
            final String INACTIVE_CHATS_STR = "INACTIVE_CHATS";
            JSONObject jsonObj = new JSONObject();
//            JSONObject allChatJsonArray = new JSONObject();
            ArrayList<JSONObject> activeChatList = new ArrayList<>();
            ArrayList<JSONObject> inactiveChatList = new ArrayList<>();
//            ArrayList<JSONObject> allChatList = new ArrayList<>();

//            SharedPreferences pref =
//                    PreferenceManager.getDefaultSharedPreferences(this.context);
//            String username = pref.getString(ALL_CHAT_STR, "n/a");

            for (int i = 0; i < smoochAllAppTokenArray.size(); i++) {
                Smooch.init(this.app, smoochAllAppTokenArray.getString(i));
                Thread.sleep(1000);
                List<Message> listMsg = Smooch.getConversation().getMessages();
                int unreadMsgCount = Smooch.getConversation().getUnreadCount();
                if (listMsg.size() == 0 ) continue; // this smooch app token not start conversation yet
                String iconUrl = "";
                String channelName = "";
                for (Message msg : listMsg) {
                    if (!msg.isFromCurrentUser()) {
                        iconUrl = msg.getAvatarUrl();
                        channelName = msg.getName();
                        break;
                    }
                }

                Message lastMsg = listMsg.get(listMsg.size() - 1);
                String lastMsgText = lastMsg.getText();
                Date epTime = lastMsg.getDate();
                Log.d(TAG, "getConversationsList: " + listMsg.toString());


                JSONObject okkamiJsonObj = createConversationJsonObj(unreadMsgCount,
                        iconUrl, channelName,
                        lastMsgText, epTime, smoochAllAppTokenArray.getString(i));

                if (i == 0) {
                    jsonObj.put(OKKAMI_CHAT_STR, new JSONArray().put(okkamiJsonObj));
                } else if (i > 0 && unreadMsgCount > 0) {
                    activeChatList.add(okkamiJsonObj);
                } else { // unactive chat
                    inactiveChatList.add(okkamiJsonObj);
                }
//                allChatList.add(okkamiJsonObj);
            }

//            allChatJsonArray.put(ALL_CHAT_STR, new JSONArray(allChatJsonArray));
//
//            if (!username.equals("n/a")) {
//
//            } else { // create new preference for saving all chat data
//                SharedPreferences.Editor edit = pref.edit();
//                edit.putString(ALL_CHAT_STR, allChatJsonArray.toString());
//                edit.commit();
//            }

            jsonObj.put(ACTIVE_CHATS_STR, new JSONArray(activeChatList));
            jsonObj.put(INACTIVE_CHATS_STR, new JSONArray(inactiveChatList));

            Log.d(TAG, "getConversationsList: "+jsonObj.toString());
            getConversationListPromise.resolve(jsonObj.toString());

        } catch (Exception e) {
            getConversationListPromise.reject(e.getMessage(), e.getMessage());
            e.printStackTrace();
        }
    }

    private static JSONObject createConversationJsonObj(int unreadMsgCount, String iconUrl,
            String channelName, String lastMsgText, Date epTime, String smoochAppToken) throws JSONException {
        JSONObject jsonObj = new JSONObject();
        jsonObj.put("unread_messages", unreadMsgCount);
        jsonObj.put("icon", iconUrl);
        jsonObj.put("channel_name", channelName);
        jsonObj.put("last_message", lastMsgText);
        // TODO: 3/26/2017 AD update proper eplased time string
        jsonObj.put("time_since_last_message", epTime.toString());
        jsonObj.put("app_token", smoochAppToken);
        return jsonObj;
    }

    /**
     * Open the smooch chat window for a particular channel
     * openChatWindowPromise.resolve(true) on success
     * openChatWindowPromise.reject(Exception) on failure
     * @param smoochAppToken
     * @param openChatWindowPromise
     */
   @ReactMethod
    public void openChatWindow(String smoochAppToken, String userId, Promise openChatWindowPromise) {
       Smooch.init(this.app, smoochAppToken);
       try {
           ConversationActivity.show(this.context);
           openChatWindowPromise.resolve(true);
       } catch (Exception e){
           openChatWindowPromise.reject(e);
       }
    }


    /**
     * returns the number of unread message in a channel
     * getUnreadMessageCountPromise.resolve(Int) on success
     * getUnreadMessageCountPromise.reject(Exception) on failure
     * @param smoochAppToken
     * @param getUnreadMessageCountPromise
     */
    @ReactMethod
    public void getUnreadMessageCount(String smoochAppToken, String userId, Promise getUnreadMessageCountPromise){
        try {
            Smooch.init(this.app, smoochAppToken);
            getUnreadMessageCountPromise.resolve(Smooch.getConversation().getUnreadCount());
        } catch (Exception e) {
            getUnreadMessageCountPromise.reject(e.getMessage(), e.getMessage());
        }
    }


    /**
     * Closes the current chat window / destroy
     * logoutChatWindowPromise.resolve(Int) on success
     * logoutChatWindowPromise.reject(Exception) on failure
     * @param logoutChatWindowPromise
     */
    @ReactMethod
    public void logoutChatWindow(Promise logoutChatWindowPromise){
        try {
            if (Smooch.getInitializationStatus() == InitializationStatus.Success &&
                    Smooch.getSmoochConnectionStatus() == SmoochConnectionStatus.Connected) {
                Smooch.logout();
//            Smooch.destroy();
                logoutChatWindowPromise.resolve(1);
            }
        } catch (Exception e) {
            logoutChatWindowPromise.reject(e.getMessage(), e.getMessage());
        }
    }



}
