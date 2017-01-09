// @flow

import React from 'react'
import { ScrollView, Text, Image, View, KeyboardAvoidingView } from 'react-native'
import { connect } from 'react-redux'
// Add Actions - replace 'Your' with whatever your reducer is called :)
// import YourActions from '../Redux/YourRedux'
import { Metrics } from '../Themes'
// external libs
import RoundedButton from '../Components/RoundedButton'
import Icon from 'react-native-vector-icons/FontAwesome'
import Animatable from 'react-native-animatable'
import { Actions as NavigationActions } from 'react-native-router-flux'
import OkkamiSdk from 'okkami-sdk';

// Styles
import styles from './Styles/HubConnectionDemoIOSStyle'

// I18n
import I18n from 'react-native-i18n'

class HubConnectionDemoIOS extends React.Component {
  connectToHub(){
    try {
        var result = OkkamiSdk.connectToHub();
//        var hubLoggedIn = await OkkamiSdk.isHubLoggedIn();
        console.log("connectToHub successful..." + result );
        
      } catch (e) {
        console.log("connectToHub failed . error : " + e.message)
      }
  }
  disconnectFromHub(){

  }
  sendCommandToHub(){
    try {
        var result = OkkamiSdk.sendCommandToHub("Power");
//        var hubLoggedIn = await OkkamiSdk.isHubLoggedIn();
        console.log("sendCommandToHub successful..." + result );
        
      } catch (e) {
        console.log("sendCommandToHub failed . error : " + e.message)
      }
  }
  
  isHubLoggedIn(){

  }
  isHubConnected(){

  }
  render () {
    return (
      <View style={styles.mainContainer}>
        <ScrollView style={styles.container}>
          
          <RoundedButton onPress={this.connectToHub}>
            Connect To Hub
          </RoundedButton>

          <RoundedButton onPress={this.disconnectFromHub}>
            Disconnect From Hub
          </RoundedButton>

          <RoundedButton onPress={this.sendCommandToHub}>
            Send Command To Hub
          </RoundedButton>

          <RoundedButton onPress={this.isHubLoggedIn}>
            Is Hub Logged In
          </RoundedButton>

          <RoundedButton onPress={this.isHubConnected}>
            Is Hub Connected
          </RoundedButton>

          <RoundedButton onPress={NavigationActions.HubConnectionEventDemoIOS}>
            Hub Connection Event Demo IOS
          </RoundedButton>

        </ScrollView>
      </View>
    )
  }

}

const mapStateToProps = (state) => {
  return {
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(HubConnectionDemoIOS)
