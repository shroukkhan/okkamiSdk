// @flow

import React , {NativeModules} from 'react'
import { ScrollView, Text, KeyboardAvoidingView } from 'react-native'
import { connect } from 'react-redux'
// Add Actions - replace 'Your' with whatever your reducer is called :)
// import YourActions from '../Redux/YourRedux'
import { Metrics } from '../Themes'
// external libs
import Icon from 'react-native-vector-icons/FontAwesome'
import Animatable from 'react-native-animatable'
import { Actions as NavigationActions } from 'react-native-router-flux'
import OkkamiSdk,{OkkamiSdkManager} from 'okkami-sdk';

console.log(OkkamiSdk)
console.log(OkkamiSdkManager)
console.log(OkkamiSdk.getSdkManager())

// Styles
import styles from './Styles/HubConnectionEventDemoIOSStyle'

// I18n
import I18n from 'react-native-i18n'
//const OkkamiSdkManager = NativeModules.OkkamiSdk;
//var {NativeModules} = React;
//const OkkamiSdkManager = NativeModules.OkkamiSdk;

class HubConnectionEventDemoIOS extends React.Component {
   
  constructor(props) {
    super(props);
    this.state = {hubMessages: []};
    console.log("Nat Result " + React);
    
    console.log("OkkamiSDK Result " + OkkamiSdkManager);
    OkkamiSdkManager.on("onHubCommand", this.hubMsgReceived);
  }

  hubMsgReceived(msg) {
    this.setState({
      hubMessages: this.state.hubMessages.push(msg)
    })
  }

  render () {
    return (
      <ScrollView style={styles.container}>
        <KeyboardAvoidingView behavior='position'>
          <Text>HubConnectionEventDemoIOS Container</Text>
        </KeyboardAvoidingView>
      </ScrollView>
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

export default connect(mapStateToProps, mapDispatchToProps)(HubConnectionEventDemoIOS)
